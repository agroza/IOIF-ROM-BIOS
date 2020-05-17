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
; Output:
;     AL - 0 = 8-bit, 1 = 16-bit
; Affects:
;     BX
; Preserves:
;     FLAGS
; ---------------------------------------------------------------------------
check8bitCPU:
	pushf

	xor al,al				; 8-bit CPU

	pushf
	pop bx					; flags in bx
	and bx,00FFFh				; mask off bits 12-15
	push bx					; save on stack

	popf					; restore flags
	pushf					; save flags again

	pop bx					; flags in bx
	and bx,0F000h				; mask off all bits, besides 12-15
	cmp bx,0F000h				; bits 12-15 are still set?
	je .exit

	inc al					; 16-bit CPU

.exit:
	popf

	ret

; Clears the IDE_DEVICES_DATA memory array.
; Input:
;     none
; Output:
;     none
; Affets:
;     AX, CX, DI
; Preserves:
;     none
; ---------------------------------------------------------------------------
clearIDEDevicesData:
	mov di,IDE_DEVICES_DATA
	xor ax,ax
	mov cx,IDE_DEVICES_DATA_SIZE * IDE_DEVICES_DATA_DEVICES_COUNT

	cld

	rep stosb

	ret

; Returns the position within IDE_DEVICES_DATA, based on the given Device ID.
; Input:
;     BL - IDE Device ID
; Output:
;     AX - position within IDE_DEVICES_DATA
; Affects:
;     FLAGS, BH
; Preserves:
;     DX
; ---------------------------------------------------------------------------
calculateIDEDevicesDataOffset:
	push dx

	xor ah,ah
	mov ax,IDE_DEVICES_DATA_SIZE
	xor bh,bh
	mul bx
	add ax,IDE_DEVICES_DATA

	pop dx

	ret

; Returns the position within IDE_DEVICES_STORED_DATA, based on the given Device ID.
; Input:
;     SI - pointer to IDE_INTERFACE_DEVICE array
; Output:
;     AX - position within IDE_DEVICES_STORED_DATA
; Affects:
;     FLAGS
; Preserves:
;     BX, DX
; ---------------------------------------------------------------------------
calculateIDEDevicesStoredDataOffset:
	push bx
	push dx

	xor ah,ah
	mov ax,IDE_DEVICES_STORED_DATA_SIZE
	xor bh,bh
	mov byte bl,[si + IDE_INTERFACE_DEVICE + 1]
	mul bx
	add ax,IDE_DEVICES_STORED_DATA

	pop dx
	pop bx

	ret

; Copies a number of words from SI to DI. Exchanges high and low bytes. Writes null at the end.
; Input:
;     SI - source strig
;     DI - destination string
;     CX - number of words
; Output:
;     none
; Affects:
;     FLAGS, AX, SI, DI
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

	xor ax,ax				; null-terminated string
	stosw

	ret

; Identification of an IDE device.
; Input:
;     SI - pointer to IDE_INTERFACE_DEVICE array
; Output:
;     AL - 0 = success; 1 = error
;     ATA_IDENTIFY_DEVICE_DATA - filled with data if sucess, zeroes if error
; Affects:
;     FLAGS, AX, BX, CX
; Preserves:
;     DX, SI, DI, DS
; ---------------------------------------------------------------------------
identifyIDEDevice:
	push bp
	mov bp,sp

	push word [si + IDE_INTERFACE_BASE_ADDRESS]
	push word [si + IDE_INTERFACE_CONTROL_ADDRESS]
	push word [si + IDE_INTERFACE_DEVICE]

	push cx
	push dx
	push si
	push di
	push ds

	xor ax,ax
	mov ds,ax				; DS:SI = 0000h:SI

	cld

.wait400ns:
	mov dx,[bp - 4]				; IDE Interface Control Address
	add dx,ALTERNATE_STATUS_REGISTER

	mov cl,3
.nextRead:
	in al,dx				; takes 100ns
	dec cl
	jnz .nextRead

.checkBSY:
	mov dx,[bp - 2]				; IDE Interface Base Address
	add dx,STATUS_REGISTER

	mov ax,18				; 18 Hz
	shl ax,1				; multiply by 2 seconds
	xchg ax,cx				; result in cx
	mov bx,[46Ch]				; BIOS timer count is updated at 18.2 Hz

.waitBSY:
	in al,dx				; read
	and al,STATUS_REGISTER_BSY
	jz .checkDRDY

	mov ax,[46Ch]				; BIOS timer count is updated at 18.2 Hz
	cmp ax,bx				; same timer count?
	je .waitBSY
	mov bx,ax				; store the new compare value
	loop .waitBSY				; continue until time-out

	jmp .clearATAIdentifyDeviceData		; time-out, assume error

.checkDRDY:
	mov dx,[bp - 2]				; IDE Interface Base Address
	add dx,STATUS_REGISTER

	mov ax,18				; 18 Hz
	shl ax,1				; multiply by 2 seconds
	xchg ax,cx				; result in cx
	mov bx,[46Ch]				; BIOS timer count is updated at 18.2 Hz

.waitDRDY:
	in al,dx				; read
	and al,STATUS_REGISTER_DRDY
	jnz .sendIdentifyCommand

	mov ax,[46Ch]				; BIOS timer count is updated at 18.2 Hz
	cmp ax,bx				; same timer count?
	je .waitDRDY
	mov bx,ax				; store the new compare value
	loop .waitDRDY				; continue until time-out

	jmp .clearATAIdentifyDeviceData		; time-out, assume error

.sendIdentifyCommand:
	cli

	mov dx,[bp - 2]				; IDE Interface Base Address
	add dx,SELECT_DRIVE_AND_HEAD_REGISTER
	mov al,[bp - 6]				; Device (Master/Slave)
	out dx,al

	mov dx,[bp - 2]				; IDE Interface Base Address
	add dx,COMMAND_REGISTER
	mov al,ATA_IDENTIFY_DEVICE_COMMAND
	out dx,al

.waitDRQ:
	mov dx,[bp - 2]				; IDE Interface Base Address
	add dx,STATUS_REGISTER

.checkDRQ:
	in al,dx
	and al,STATUS_REGISTER_DRQ
	jz .checkDRQ

	mov dx,[bp - 2]				; IDE Interface Base Address
	add dx,DATA_REGISTER

.fillATAIdentifyDeviceData:
	mov di,ATA_IDENTIFY_DEVICE_DATA
	mov cx,256

	rep insw				; fill the buffer with device data

	sti

	jmp .processATAIdentifyDeviceData

.clearATAIdentifyDeviceData:
	mov di,ATA_IDENTIFY_DEVICE_DATA
	mov ax,00h
	mov cx,256

	rep stosw				; fill the buffer with device data

.processATAIdentifyDeviceData:
	pop ds					; DS:SI = CS:SI

	mov bl,[bp - 5]				; IDE Device ID
	call calculateIDEDevicesDataOffset

	mov si,ATA_IDENTIFY_DEVICE_DATA
	mov di,ax

.copyParameters:
	mov ax,[si + ATA_IDENTIFY_DEVICE_CYLINDERS_OFFSET]
	mov word [di + IDE_DEVICES_DATA_CYLINDERS_OFFSET],ax
	mov word [di + IDE_DEVICES_DATA_LDZONE_OFFSET],ax

	mov ax,[si + ATA_IDENTIFY_DEVICE_HEADS_OFFSET]
	mov word [di + IDE_DEVICES_DATA_HEADS_OFFSET],ax

	mov ax,[si + ATA_IDENTIFY_DEVICE_SECTORS_OFFSET]
	mov word [di + IDE_DEVICES_DATA_SECTORS_OFFSET],ax

	or ax,ax				; no sectors?
	jnz .copyWPCOMP
	mov byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_NONE
	mov word [di + IDE_DEVICES_DATA_WPCOMP_OFFSET],ax
	jmp .copyGeneralAndFeatures

.copyWPCOMP:
	mov byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_USER
	mov word [di + IDE_DEVICES_DATA_WPCOMP_OFFSET],IDE_PARAMETER_CHS_WPCOMP_MAX

.copyGeneralAndFeatures:
	mov ax,[si + ATA_IDENTIFY_DEVICE_GENERAL_OFFSET]
	mov word [di + IDE_DEVICES_DATA_GENERAL_HIGH_OFFSET],ax

	mov ax,[si + ATA_IDENTIFY_DEVICE_FEATURES_OFFSET]
	mov byte [di + IDE_DEVICES_DATA_FEATURES_OFFSET],ah

.fillSerial:
	add si,ATA_IDENTIFY_DEVICE_SERIAL_OFFSET
	add di,IDE_DEVICES_DATA_SERIAL_OFFSET

	mov cx,IDE_DEVICES_DATA_SERIAL_LENGTH	; read 20 characters (10 words)
	call copyWordsExchangeBytes

.fillRevision:
	add si,ATA_IDENTIFY_DEVICE_REVISION_OFFSET - ATA_IDENTIFY_DEVICE_SERIAL_OFFSET - 2 * IDE_DEVICES_DATA_SERIAL_LENGTH

	mov cx,IDE_DEVICES_DATA_REVISION_LENGTH	; read 8 characters (4 words)
	call copyWordsExchangeBytes

.fillModel:
	mov cx,IDE_DEVICES_DATA_MODEL_LENGTH	; read 40 characters (20 words)
	call copyWordsExchangeBytes

	pop di
	pop si
	pop dx
	pop cx

	mov sp,bp
	pop bp

	ret

; Autodetection of an IDE device.
; Input:
;     BX - pointer to string; current IDE Device (Primary/Secondary; Master/Slave)
;     SI - pointer to IDE_INTERFACE_DEVICE array
; Output:
;     none
; Affects:
;     FLAGS, AX
; Preserves:
;     BX, CX, SI
; ---------------------------------------------------------------------------
autodetectIDEDevice:
	push bx
	push cx
	push si

	call calculateIDEDevicesStoredDataOffset
	mov di,ax
	cmp byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_AUTO
	jne .exit

	push si					; save pointer to IDE_INTERFACE_DEVICE

	mov ah,NORMAL_TEXT_COLOR
	mov si,sDetectingIDE
	call directWrite
	mov si,bx				; which IDE Device string (Primary/Secondary; Master/Slave)
	call directWrite

	pop si					; restore pointer to IDE_INTERFACE_DEVICE

	mov bl,[si + IDE_INTERFACE_DEVICE + 1]	; get device ID
	call calculateIDEDevicesDataOffset

	push ax					; save IDE_DEVICES_DATA offset

	call identifyIDEDevice

	pop si					; restore IDE_DEVICES_DATA offset

	mov ah,HIGHLIGHT_TEXT_COLOR
	add si,IDE_DEVICES_DATA_MODEL_OFFSET
	cmp byte [si],0
	je .detectNone

	jmp .writeModel

.detectNone:
	mov si,sIDEDeviceTypeNone

.writeModel:
	call directWrite

	call CRLF

.exit:
	pop si
	pop cx
	pop bx

	ret
