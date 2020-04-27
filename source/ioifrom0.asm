; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS (ioifrom0.asm)                                   -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

	use16
	cpu 286

%include ".\source\include\equates.inc"

	org ROMSTART

; ROM BIOS Header
; ---------------------------------------------------------------------------
	db 55h
	db 0AAh
	db ROMBLOCKS

	jmp start

; Initialization Routine
; ---------------------------------------------------------------------------
start:
	push ax
	push bx
	push cx
	push dx
	push si
	push ds

	mov si,sProgram
	call print
	mov si,sCopyright
	call print
	mov si,sPressDELKey
	call print

	call autodetectPM
	call autodetectPS
	call autodetectSM
	call autodetectSS

	pop ds
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	retf

; Autodetection of IDE Primary Master device.
; ---------------------------------------------------------------------------
autodetectPM:
	mov si,sAutodetectIDE
	call print
	mov si,sAutodetectPM
	call print
	mov si,sAutodetectNone
	call print

	ret

; Autodetection of IDE Primary Slave device.
; ---------------------------------------------------------------------------
autodetectPS:
	mov si,sAutodetectIDE
	call print
	mov si,sAutodetectPS
	call print
	mov si,sAutodetectNone
	call print

	ret

; Autodetection of IDE Secondary Master device.
; ---------------------------------------------------------------------------
autodetectSM:
	mov si,sAutodetectIDE
	call print
	mov si,sAutodetectSM
	call print
	mov si,sAutodetectNone
	call print

	ret

; Autodetection of IDE Secondary Slave device.
; ---------------------------------------------------------------------------
autodetectSS:
	mov si,sAutodetectIDE
	call print
	mov si,sAutodetectSS
	call print
	mov si,sAutodetectNone
	call print

	ret

; Prints an ASCIIZ string to the screen via function 0Eh (teletype) on INT10.
; Input:
;   CS:SI - pointer to the string
; Output:
;   none
; ---------------------------------------------------------------------------
print:
	pushf
	push ax
	push bx
	push si
	push ds
	push cs
	pop ds
	
	cld

.nextchar:
	lodsb
	or al,al
	jz .exit
	
	mov ah,0Eh
	mov bx,0007h
	int 10h
	
	jmp .nextchar

.exit:
	pop ds
	pop si
	pop bx
	pop ax
	popf

	ret

; Delay for multiplies of approximately 15 microseconds.
; Input:
;   CX - time to delay (in 15us units)
; Output:
;   none
; ---------------------------------------------------------------------------
Wait1s:
	pusha
	push ds

	mov ax,0
	mov ds,ax

	mov cx,18
	mov bx,[46Ch]

WaitForAnotherChange:

NoChange:
	mov ax,[46Ch]
	cmp ax,bx
	je NoChange
	mov bx,ax
	loop WaitForAnotherChange

	pop ds
	popa

	ret

%include ".\source\include\messages.inc"

TIMES (ROMSIZE-($-$$)-ROMSTART) db 00h