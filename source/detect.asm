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
;     none
; Output
;     AL - 0 = 8-bit, 1 = 16-bit
; Preserves:
;     FLAGS
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
;     AX - IDE Interface Base Address
;     BX - IDE Interface Controll Address
;     CL - Master/Slave
; Output
;     AL - 0 = success; 1 = error
;     IDE_DEVICE_DATA - is filled
; Preserves:
;     FLAGS, DX, SI, DI, DS
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

	mov word [bp-2],ax		; IDE Interface Base Address
	mov word [bp-4],bx		; IDE Interface Controll Address
	mov word [bp-6],cx		; Master/Slave

	xor ax,ax
	mov ds,ax			; DS:SI = 0000h:SI

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
	jz .checkDRDY

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
	jnz .sendIdentifyCommand

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
	jz .checkDRQ

	mov dx,[bp-2]			; IDE Interface Base Address
	add dx,DATA_REGISTER

	mov di,IDE_DEVICE_DATA
	mov cx,256

	; TODO : Optimize this part.

	cld

	rep insw			; fill the buffer with device data

	sti

	call processIDEDeviceData

	xor al,al			; assume success

	jmp .exit

.clearIDEDeviceData:
	mov di,IDE_DEVICE_DATA
	mov ax,00h
	mov cx,256

	cld

	rep stosw			; fill the buffer with device data

	call processIDEDeviceData

	mov al,1			; assume error

.exit:
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
;     AX - IDE Interface Base Address
;     BX - IDE Interface Controll Address
;     CL - Master/Slave
; Output
;     AL - 0 = success; 1 = error
;     IDE_DEVICE_DATA - is filled
; Preserves:
;     DS
; ---------------------------------------------------------------------------
processIDEDeviceData:
	; TODO : is DS required?
	push ds
	push cs
	pop ds				; DS:SI = CS:SI

	mov si,IDE_DEVICE_DATA

.copyParameters:
	mov ax,[si+IDE_DEVICE_DATA_CYLINDERS_OFFSET]
	mov word [IDE_DEVICE_CYLINDERS],ax
	mov word [IDE_DEVICE_LDZONE],ax

	mov ax,[si+IDE_DEVICE_DATA_HEADS_OFFSET]
	mov word [IDE_DEVICE_HEADS],ax

	mov ax,[si+IDE_DEVICE_DATA_SECTORS_OFFSET]
	mov word [IDE_DEVICE_SECTORS],ax

	mov word [IDE_DEVICE_WPCOMP],WPCOMP_VALUE

.copyTypeAndFeatures:
	mov ax,[si+IDE_DEVICE_DATA_GENERAL_OFFSET]
	mov byte [IDE_DEVICE_GENERAL_HIGH],ah
	mov byte [IDE_DEVICE_GENERAL_LOW],al

	mov ax,[si+IDE_DEVICE_DATA_FEATURES_OFFSET]
	mov byte [IDE_DEVICE_FEATURES],ah

	; TODO : Extract constants separately.

.fillSerial:
	add si,20
	mov di,IDE_DEVICE_SERIAL

	mov cx,10			; read 20 characters (10 words)
	call copyWordsExchangeBytes

.fillRevision:
	add si,6
	mov di,IDE_DEVICE_REVISION

	mov cx,4			; read 8 characters (4 words)
	call copyWordsExchangeBytes

.fillModel:
	mov di,IDE_DEVICE_MODEL

	mov cx,10			; read 40 characters (20 words)
	call copyWordsExchangeBytes

	pop ds

	ret

; Copies a number of words from SI to DI. Exchanges high and low bytes.
; Input:
;     SI - source strig
;     DI - destination string
;     CX - number of words
; Output
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
copyWordsExchangeBytes:
	cld

.nextByte:
	lodsw
	xchg ah,al
	stosw

	loop .nextByte

	xor al,al			; null-terminated string
	stosb

	ret

; Autodetection of an IDE device.
; Input:
;     AX - IDE Interface Base Address
;     BX - IDE Interface Controll Address
;     CL - Master/Slave
; Output
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
autodetectDevice:
	call identifyDevice

	or al,al
	jnz .detectNone

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

	ret
