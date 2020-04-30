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

	mov si,sProgram
	call directwrite
	mov si,sCopyright
	call print

	call processSetup

	call autodetectDevices

	mov si,sCRLF
	call print

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
	call print

	; TODO : Add code to process keypresses and enter the Setup Program.

	mov cx,100
	call delay1sec

	ret

; Autodetection of IDE Devices.
; ---------------------------------------------------------------------------
autodetectDevices:
	mov si,sAutodetectIDE
	call print
	mov si,sAutodetectPM
	call print

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,MASTER_DEVICE
	call autodetectDevice

	mov si,sAutodetectIDE
	call print
	mov si,sAutodetectPS
	call print

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,SLAVE_DEVICE
	call autodetectDevice

	mov si,sAutodetectIDE
	call print
	mov si,sAutodetectSM
	call print

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,MASTER_DEVICE
	call autodetectDevice

	mov si,sAutodetectIDE
	call print
	mov si,sAutodetectSS
	call print

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,SLAVE_DEVICE
	call autodetectDevice

	ret

TIMES (ROMSIZE-($-$$)-ROMSTART) DB 00h

section .bss

BUFFER				RESB 256