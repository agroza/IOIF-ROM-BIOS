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

section .text

; ROM BIOS Header
; ---------------------------------------------------------------------------
	DB 55h
	DB 0AAh
	DB ROMBLOCKS

	jmp start

	DB 0,'I/O-IF ROM #0',0

%include ".\source\debug.asm"
%include ".\source\routines.asm"
%include ".\source\detect.asm"
%include ".\source\include\messages.inc"

; Initialization Routine
; ---------------------------------------------------------------------------
start:
	push ax
	push bx
	push cx
	push dx
	push si
	push ds

	xor ax,ax
	mov ds,ax
	mov ss,ax
	mov es,ax

	mov ah,VIDEOHIGHLIGHT
	mov si,sProgram
	call directWrite
	mov ah,VIDEONORMAL
	mov si,sCopyright
	call directWrite

	call check8bitCPU
	or al,al
	jnz .continue

	mov si,sBIOSDisabled
	call directWrite

	jmp .exit

.continue:
	call processSetup

	call autodetectDevices

.exit:
	call CRLF

	pop ds
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	retf

; I/OIF ROM BIOS Setup Program trigger.
; ---------------------------------------------------------------------------
processSetup:
	mov si,sPressDELKey
	call directWrite

	; TODO : Add code to process keypresses and enter the Setup Program.

	mov cx,100
	call delay1sec

	ret

; Autodetection of IDE Devices.
; ---------------------------------------------------------------------------
autodetectDevices:
	mov ah,VIDEONORMAL
	mov si,sAutodetectIDE
	call directWrite
	mov si,sAutodetectPM
	call directWrite

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,MASTER_DEVICE
	call autodetectDevice

	mov ah,VIDEONORMAL
	mov si,sAutodetectIDE
	call directWrite
	mov si,sAutodetectPS
	call directWrite

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,SLAVE_DEVICE
	call autodetectDevice

	mov ah,VIDEONORMAL
	mov si,sAutodetectIDE
	call directWrite
	mov si,sAutodetectSM
	call directWrite

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,MASTER_DEVICE
	call autodetectDevice

	mov ah,VIDEONORMAL
	mov si,sAutodetectIDE
	call directWrite
	mov si,sAutodetectSS
	call directWrite

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,SLAVE_DEVICE
	call autodetectDevice

	ret

TIMES (ROMSIZE-($-$$)-ROMSTART) DB 00h