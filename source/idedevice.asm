; ---------------------------------------------------------------------------
; - IDE Device Routines (idedevice.asm)                                     -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

; Sends the specified ATA command to the given drive.
; Input:
;     AH - ATA command
;     DL - drive
;     SI - pointer to IDE_INTERFACE_DEVICE array
; Output:
;     CF - clear = success
;          set = error
; Affects:
;     FLAGS, AX, BX, DX
; Preserves:
;     CX, DS
; ---------------------------------------------------------------------------
sendATACommand:
	push cx
	push ds

	xor ax,ax
	mov ds,ax				; DS:SI = 0000h:SI

	clc					; assume no error

.wait400ns:
	cs mov dx,[si + IDE_INTERFACE_CONTROL_ADDRESS]
	add dx,ALTERNATE_STATUS_REGISTER

	mov cl,3

.nextRead:
	in al,dx				; takes 100ns
	dec cl
	jnz .nextRead

.checkBSY:
	cs mov dx,[si + IDE_INTERFACE_BASE_ADDRESS]
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

	stc					; time-out, assume error

	jmp .exit

.checkDRDY:
	cs mov dx,[si + IDE_INTERFACE_BASE_ADDRESS]
	add dx,STATUS_REGISTER

	mov ax,18				; 18 Hz
	shl ax,1				; multiply by 2 seconds
	xchg ax,cx				; result in cx
	mov bx,[46Ch]				; BIOS timer count is updated at 18.2 Hz

.waitDRDY:
	in al,dx				; read
	and al,STATUS_REGISTER_DRDY
	jnz .sendCommand

	mov ax,[46Ch]				; BIOS timer count is updated at 18.2 Hz
	cmp ax,bx				; same timer count?
	je .waitDRDY
	mov bx,ax				; store the new compare value

	loop .waitDRDY				; continue until time-out

	stc					; time-out, assume error

	jmp .exit

.sendCommand:
	cli

	cs mov dx,[si + IDE_INTERFACE_BASE_ADDRESS]
	add dx,SELECT_DRIVE_AND_HEAD_REGISTER
	cs mov al,[si + IDE_INTERFACE_DEVICE]
	out dx,al

	cs mov dx,[si + IDE_INTERFACE_BASE_ADDRESS]
	add dx,COMMAND_REGISTER
	mov al,ATA_COMMAND_IDENTIFY_DEVICE
	out dx,al

.waitDRQ:
	cs mov dx,[si + IDE_INTERFACE_BASE_ADDRESS]
	add dx,STATUS_REGISTER

.checkDRQ:
	in al,dx
	and al,STATUS_REGISTER_DRQ
	jz .checkDRQ

	cs mov dx,[si + IDE_INTERFACE_BASE_ADDRESS]
	add dx,DATA_REGISTER

	sti

.exit:
	pop ds
	pop cx

	ret

; Accesses an IDE Device for reading, writing, or verifying of sectors.
; Input:
;     DL - drive
; Output:
;     none
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
accessIDEDevice:

	ret
