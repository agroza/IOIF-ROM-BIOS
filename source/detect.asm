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
; Technically, the IDE interfaces could work with 8-bit machines.
; But by design, the I/O Interface is hard-wired for 16-bit ISA slots.
; Input:
;   none
; Output
;   AL - 0 = 8-bit, 1 = 16-bit
; ---------------------------------------------------------------------------
check8bitCPU:
	pushf

	xor al,al					; 8-bit CPU

	pushf
	pop bx						; flags in bx
	and bx,00FFFh				; mask off bits 12-15
	push bx						; save on stack

	popf						; restore flags
	pushf						; save flags again

	pop bx						; flags in bx
	and bx,0F000h				; mask off all bits, besides 12-15
	cmp bx,0F000h				; bits 12-15 are still set?
	je .exit

	inc al						; 16-bit CPU

.exit:
	popf

	ret

; Autodetection of an IDE device.
; Input:
;   AX - IDE Interface Base Address
;   BX - Master/Slave
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
	push si
	push di
	push ds
	push cs
	pop ds
	push es

	; TODO : Add code to autodetect IDE devices.

	mov ah,VIDEOHIGHLIGHT
	mov si,sAutodetectNone
	call directWrite

.exit:
	call CRLF

    pop es
	pop ds
	pop di
	pop si
	pop cx
	pop bx
	pop ax
	popf

	mov sp,bp
	pop bp

	ret

section .bss

BUFFER				RESB 256