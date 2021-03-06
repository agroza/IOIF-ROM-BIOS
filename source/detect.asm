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
;     BL - IDE Device ID
; Output:
;     AX - position within IDE_DEVICES_STORED_DATA
; Affects:
;     FLAGS
; Preserves:
;     DX
; ---------------------------------------------------------------------------
calculateIDEDevicesStoredDataOffset:
	push dx

	xor ah,ah
	mov ax,IDE_DEVICES_STORED_DATA_SIZE
	xor bh,bh
	mul bx
	add ax,IDE_DEVICES_STORED_DATA

	pop dx

	ret

; Loads SI with the position within IDE_DEVICES_STORED_DATA, based on the given drive.
; Input:
;     DL - drive
; Output:
;     SI - position within IDE_DEVICES_STORED_DATA
; Affects:
;     BL
; Preserves:
;     AX
; ---------------------------------------------------------------------------
loadIDEDevicesStoredData:
	push ax

	mov bl,dl
	sub bl,IDE_DEVICES_FIRST_HARD_DRIVE
	call calculateIDEDevicesStoredDataOffset
	mov si,ax

	pop ax

	ret

; Returns whether the given drive identifier points to an existing device.
; Input:
;     DL - drive
; Output:
;     AL - 0 = IDE Device does not exist, 1 = IDE Device does exist
; Affects:
;     FLAGS
; Preserves:
;     CX, SI
; ---------------------------------------------------------------------------
verifyIDEDeviceExists:
	push si

	xor al,al				; IDE Device does not exist

	cmp dl,IDE_DEVICES_FIRST_HARD_DRIVE	; skip floppy disk drives
	jb .exit
	cmp dl,IDE_DEVICES_FOURTH_HARD_DRIVE	; skip hard disk drives not attached to I/O Interface
	ja .exit

	; TODO : In case of type = AUTO and no detection, this needs to be signalled.

	call loadIDEDevicesStoredData

	ds cmp byte [si + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_USER
	jne .exit

	inc al					; IDE Device does exist

.exit:
	pop si

	ret

; Returns the number of hard disk drives installed on primary interface.
; Input:
;     none
; Output:
;     DL - number of hard disk drives on first interface
; Affects:
;     FLAGS
; Preserves:
;     CX
; ---------------------------------------------------------------------------
primaryInterfaceIDEDevicesCount:
	push cx

	mov dl,IDE_DEVICES_FIRST_HARD_DRIVE

	mov cx,IDE_DEVICES_PER_INTERFACE

.nextDevice:
	call verifyIDEDeviceExists
	or al,al
	jz .noDevice

	inc dl

.noDevice:
	loop .nextDevice

	sub dl,IDE_DEVICES_FIRST_HARD_DRIVE

	pop cx

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

; Identification of an IDE Device.
; Input:
;     SI - pointer to IDE_INTERFACE_DEVICE array
; Output:
;     ATA_IDENTIFY_DEVICE_DATA - filled with data if sucess, zeroes if error
; Affects:
;     FLAGS, AX, BX
; Preserves:
;     CX, DX, SI, DI, DS
; ---------------------------------------------------------------------------
identifyIDEDevice:
	push cx
	push dx
	push si
	push di
	push ds

	cld

	mov di,ATA_IDENTIFY_DEVICE_DATA
	mov cx,ATA_IDENTIFY_DEVICE_DATA_SIZE

	call sendATACommand
	jc .clearATAIdentifyDeviceData

.fillATAIdentifyDeviceData:
	rep insw				; fill the buffer with device data

	jmp .processATAIdentifyDeviceData

.clearATAIdentifyDeviceData:
	xor ax,ax

	rep stosw				; fill the buffer with zeroes

.processATAIdentifyDeviceData:
	mov byte bl,[si + IDE_INTERFACE_DEVICE + 1]
	call calculateIDEDevicesDataOffset

	mov si,ATA_IDENTIFY_DEVICE_DATA
	mov di,ax

.copyParameters:
	push es
	pop ds					; DS:SI = ES:SI

	ds mov ax,[si + ATA_IDENTIFY_DEVICE_CYLINDERS_OFFSET]
	es mov word [di + IDE_DEVICES_DATA_CYLINDERS_OFFSET],ax
	es mov word [di + IDE_DEVICES_DATA_LDZONE_OFFSET],ax

	ds mov ax,[si + ATA_IDENTIFY_DEVICE_HEADS_OFFSET]
	es mov word [di + IDE_DEVICES_DATA_HEADS_OFFSET],ax

	ds mov ax,[si + ATA_IDENTIFY_DEVICE_SECTORS_OFFSET]
	es mov word [di + IDE_DEVICES_DATA_SECTORS_OFFSET],ax

	or ax,ax				; no sectors?
	jnz .copyWPCOMP

	es mov byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_NONE
	es mov word [di + IDE_DEVICES_DATA_WPCOMP_OFFSET],ax

	jmp .copyGeneralAndFeatures

.copyWPCOMP:
	es mov byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_USER
	es mov word [di + IDE_DEVICES_DATA_WPCOMP_OFFSET],IDE_PARAMETER_CHS_WPCOMP_MAX

.copyGeneralAndFeatures:
	ds mov ax,[si + ATA_IDENTIFY_DEVICE_GENERAL_OFFSET]
	es mov word [di + IDE_DEVICES_DATA_GENERAL_HIGH_OFFSET],ax

	ds mov ax,[si + ATA_IDENTIFY_DEVICE_FEATURES_OFFSET]
	es mov byte [di + IDE_DEVICES_DATA_FEATURES_OFFSET],ah

.setIdentified:
	es inc byte [di + IDE_DEVICES_DATA_IDENTIFIED_OFFSET]

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

	pop ds
	pop di
	pop si
	pop dx
	pop cx

	ret

; Autodetection of an IDE Device.
; Input:
;     BX - pointer to string; current IDE Device (Primary/Secondary; Master/Slave)
;     SI - pointer to IDE_INTERFACE_DEVICE array
; Output:
;     none
; Affects:
;     FLAGS, AX
; Preserves:
;     BX, CX, SI, DS
; ---------------------------------------------------------------------------
autodetectIDEDevice:
	push bx
	push cx
	push si
	push ds

	push bx

	mov byte bl,[si + IDE_INTERFACE_DEVICE + 1]
	call calculateIDEDevicesStoredDataOffset
	mov di,ax

	pop bx

	ds cmp byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_AUTO
	jne .exit

	push si					; save pointer to IDE_INTERFACE_DEVICE

	mov ah,NORMAL_TEXT_COLOR
	mov si,sDetectingIDE
	call directWrite
	mov si,bx				; which IDE Device string (Primary/Secondary; Master/Slave)
	call directWrite

	pop si					; restore pointer to IDE_INTERFACE_DEVICE

	mov bl,[si + IDE_INTERFACE_DEVICE + 1]
	call calculateIDEDevicesDataOffset

	push ax					; save IDE_DEVICES_DATA offset

	call identifyIDEDevice

	pop si					; restore IDE_DEVICES_DATA offset

	mov ah,HIGHLIGHT_TEXT_COLOR

	add si,IDE_DEVICES_DATA_MODEL_OFFSET
	es cmp byte [si],00h
	jnz .writeStringAtSegment

	mov si,sIDEDeviceTypeNone
	jmp .writeString

.writeStringAtSegment:
	push es
	pop ds

.writeString:
	call directWrite

	call CRLF

.exit:
	pop ds
	pop si
	pop cx
	pop bx

	ret
