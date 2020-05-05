; ---------------------------------------------------------------------------
; - Detection Routines (detect.asm)                                         -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

; Detection of (8-bit) 8086/8088 CPU.
; Technically, the I/O Interface ISA card could work with 8-bit machines.
; But by design, the IDE interfaces are hard-wired for 16-bit ISA slots.
; Input:
;   none
; Output
;   AL - 0 = 8-bit, 1 = 16-bit
; ---------------------------------------------------------------------------
check8bitCPU:
	pushf

	xor al,al			; 8-bit CPU

	pushf
	pop bx				; flags in bx
	and bx,00FFFh			; mask off bits 12-15
	push bx				; save on stack

	popf				; restore flags
	pushf				; save flags again

	pop bx				; flags in bx
	and bx,0F000h			; mask off all bits, besides 12-15
	cmp bx,0F000h			; bits 12-15 are still set?
	je .exit

	inc al				; 16-bit CPU

.exit:
	popf

	ret

; Identification of an IDE device.
; Input:
;   AX - IDE Interface Base Address
;   BX - IDE Interface Controll Address
;   CL - Master/Slave
; Output
;   AL - 0 = success; 1 = error
;   IDE_DEVICE_DATA - is filled
; ---------------------------------------------------------------------------
identifyDevice:
	push bp
	mov bp,sp

	sub sp,6			; allocate 6 bytes

	pushf
	push dx
	push si
	push di
	push ds
	push es

	mov word [bp-2],ax		; IDE Interface Base Address
	mov word [bp-4],bx		; IDE Interface Controll Address
	mov word [bp-6],cx		; Master/Slave

	xor ax,ax
	mov ds,ax			; DS = 0000h

.wait400ns:
	mov dx,[bp-4]			; IDE Interface Control Address
	add dx,ALTERNATE_STATUS_REGISTER

	mov cl,3
.nextRead:
	in al,dx			; takes 100ns
	dec cl
	jnz .nextRead

.checkBSY:
	mov dx,[bp-2]			; IDE Interface Base Address
	add dx,STATUS_REGISTER

	mov ax,18			; 18 Hz
	shl ax,1			; multiply by 2 seconds
	xchg ax,cx			; result in cx
	mov bx,[46Ch]			; BIOS timer count is updated at 18.2 Hz

.waitBSY:
	in al,dx			; read
	and al,STATUS_REGISTER_BSY
	je .checkDRDY

	mov ax,[46Ch]			; BIOS timer count is updated at 18.2 Hz
	cmp ax,bx			; same timer count?
	je .waitBSY
	mov bx,ax			; store the new compare value
	loop .waitBSY			; continue until time-out

	jmp .clearIDEDeviceData		; time-out, assume error

.checkDRDY:
	mov dx,[bp-2]			; IDE Interface Base Address
	add dx,STATUS_REGISTER

	mov ax,18			; 18 Hz
	shl ax,1			; multiply by 2 seconds
	xchg ax,cx			; result in cx
	mov bx,[46Ch]			; BIOS timer count is updated at 18.2 Hz

.waitDRDY:
	in al,dx			; read
	and al,STATUS_REGISTER_DRDY
	jne .sendIdentifyCommand

	mov ax,[46Ch]			; BIOS timer count is updated at 18.2 Hz
	cmp ax,bx			; same timer count?
	je .waitDRDY
	mov bx,ax			; store the new compare value
	loop .waitDRDY			; continue until time-out

	jmp .clearIDEDeviceData		; time-out, assume error

.sendIdentifyCommand:
	cli

	mov dx,[bp-2]			; IDE Interface Base Address
	add dx,SELECT_DRIVE_AND_HEAD_REGISTER
	mov al,[bp-6]			; Master/Slave
	out dx,al

	mov dx,[bp-2]			; IDE Interface Base Address
	add dx,COMMAND_REGISTER
	mov al,ATA_IDENTIFY_DEVICE_COMMAND
	out dx,al

.waitDRQ:
	mov dx,[bp-2]			; IDE Interface Base Address
	add dx,STATUS_REGISTER

.checkDRQ:
	in al,dx
	and al,STATUS_REGISTER_DRQ
	je .checkDRQ

	mov dx,[bp-2]			; IDE Interface Base Address
	add dx,DATA_REGISTER

	mov ax,cs
	mov es,ax			; ES:DI = CS:IDE_DEVICE_DATA

	mov di,IDE_DEVICE_DATA
	mov cx,256

	cld

	rep insw			; fill the buffer with device data

	sti

	call processIDEDeviceData

	xor al,al			; assume success

	jmp .exit

.clearIDEDeviceData:
	mov ax,cs
	mov es,ax			; ES:DI = CS:IDE_DEVICE_DATA

	mov di,IDE_DEVICE_DATA
	mov ax,00h
	mov cx,256

	cld

	rep stosw			; fill the buffer with device data

	call processIDEDeviceData

	mov al,1			; assume error

.exit:
	pop es
	pop ds
	pop di
	pop si
	pop dx
	popf

	mov sp,bp
	pop bp

	ret

; Identification of an IDE device.
; Input:
;   AX - IDE Interface Base Address
;   BX - IDE Interface Controll Address
;   CL - Master/Slave
; Output
;   AL - 0 = success; 1 = error
;   IDE_DEVICE_DATA - is filled
; ---------------------------------------------------------------------------
processIDEDeviceData:
	push si
	push ds

	mov ax,cs
	mov ds,ax			; DS:SI = CS:SI

	mov si,IDE_DEVICE_DATA

	add si,2
	lodsw
	mov word [IDE_DEVICE_CYLINDERS],ax
	mov word [IDE_DEVICE_LDZONE],ax

	add si,2
	lodsw
	mov word [IDE_DEVICE_HEADS],ax

	add si,4
	lodsw
	mov word [IDE_DEVICE_SECTORS],ax

	mov word [IDE_DEVICE_WPCOMP],WPCOMP_VALUE

	pop ds
	pop si

	ret

; Autodetection of an IDE device.
; Input:
;   AX - IDE Interface Base Address
;   BX - IDE Interface Controll Address
;   CL - Master/Slave
; Output
;   none
; ---------------------------------------------------------------------------
autodetectDevice:
	push si
	push di
	push ds
	push es

	call identifyDevice

	or al,al
	jnz .detectNone

	mov ax,cs
	mov ds,ax			; DS:SI = CS:DS
	mov es,ax			; ES:DS = CS:DS

	; TODO : Refactor this code and continue the implementation.

.printATAInformation:
	mov si,IDE_DEVICE_DATA
	add si,54

	mov di,IDE_DEVICE_MODEL

	mov cx,10			; read 20 characters (10 words)

	cld

.nextByte:
	lodsw
	xchg ah,al
	stosw

	loop .nextByte

	xor al,al			; null-terminated string
	stosb

	mov ah,HIGHLIGHT_TEXT_COLOR
	mov si,IDE_DEVICE_MODEL
	call directWrite

	jmp .exit

.detectNone:
	mov ah,HIGHLIGHT_TEXT_COLOR
	mov si,sIDEDeviceTypeNone
	call directWrite

.exit:
	call CRLF

	pop es
	pop ds
	pop di
	pop si

	ret

section .bss
	IDE_DEVICE_DATA			RESB	256

	IDE_DEVICE_MODEL		RESB	21
	IDE_DEVICE_CYLINDERS		RESW	1
	IDE_DEVICE_HEADS		RESW	1
	IDE_DEVICE_SECTORS		RESW	1
	IDE_DEVICE_WPCOMP		RESW	1
	IDE_DEVICE_LDZONE		RESW	1
