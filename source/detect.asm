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

; Autodetection of an IDE device.
; Input:
;   AX - IDE Interface Base Address
;   BX - IDE Interface Controll Address
;   CX - Master/Slave
; Output
;   none
; ---------------------------------------------------------------------------
autodetectDevice:
	push bp
	mov bp,sp

	pushf
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push ds
	push cs
	pop ds
	push es

; TODO CEVA E AICI

	xor ax,ax
	mov ds,ax

.wait400ns:
	mov dx,[bp-6]			; IDE Interface Control Address
	add dx,ALTERNATE_STATUS_REGISTER

	mov cl,3
.nextRead:
	in al,dx			; takes 100ns
	dec cl
	jnz .nextRead

.checkBSY:
	mov dx,[bp-4]			; IDE Interface Base Address
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
	cmp ax,bx			; same time counter?
	je .waitBSY
	mov bx,ax			; store the new compare value
	loop .waitBSY			; continue for 2 seconds

	; TODO : This code is faulty.

	jmp .detectNone

.checkDRDY:
	mov dx,[bp-4]			; IDE Interface Base Address
	add dx,STATUS_REGISTER

	mov ax,18			; 18 Hz
	shl ax,1			; multiply by 2 seconds
	xchg ax,cx			; result in cx
	mov bx,[46Ch]			; BIOS timer count is updated at 18.2 Hz

.waitDRDY:
	in al,dx			; read
	and al,STATUS_REGISTER_DRDY
	jne .tempContinue

	mov ax,[46Ch]			; BIOS timer count is updated at 18.2 Hz
	cmp ax,bx			; same time counter?
	je .waitDRDY
	mov bx,ax			; store the new compare value
	loop .waitDRDY			; continue for 2 seconds

	jmp .detectNone			; time-out

.tempContinue:


.detectNone:
	mov ah,VIDEOHIGHLIGHT
	mov si,sAutodetectNone
	call directWrite

.exit:
	call CRLF

	sti

	pop es
	pop ds
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	popf

	mov sp,bp
	pop bp

	ret

section .bss
	BUFFER		RESB	256
