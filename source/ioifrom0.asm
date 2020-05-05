; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS (ioifrom0.asm)                                   -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

%define ROM
;%define DOS

	use16
	cpu 286

%include ".\source\include\equates.inc"

%ifdef ROM
	org ROMSTART
%else
	org 100h
%endif

section .text

; ROM BIOS Header
; ---------------------------------------------------------------------------
%ifdef ROM
	DB 55h
	DB 0AAh
	DB ROMBLOCKS
%endif
	jmp start

	DB 0,'I/O-IF ROM #0',0

%include ".\source\debug.asm"
%include ".\source\routines.asm"
%include ".\source\setup.asm"
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

%ifdef ROM
	retf
%else
	xor al,al
	mov ah,4Ch
	int 21h
%endif

; I/OIF ROM BIOS SETUP Program trigger.
; ---------------------------------------------------------------------------
processSetup:
	mov si,sPressDELKey
	call directWrite

	mov cx,1
	call delay

	mov ah,01h			; read the state of the keyboard buffer
	int 16h
	jz .exit

	mov ah,00h			; read key press
	int 16h

	cmp ax,KBD_DEL
	jne .exit

	call enterSetup

.exit:
	ret

; Autodetection of IDE Devices.
; ---------------------------------------------------------------------------
autodetectDevices:
	mov ah,VIDEONORMAL
	mov si,sAutodetectIDE
	call directWrite
	mov si,sIDEDevicePM
	call directWrite

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,PRIMARY_IDE_INTERFACE_CONTROL
	mov cx,IDE_MASTER_DEVICE
	call autodetectDevice

	mov ah,VIDEONORMAL
	mov si,sAutodetectIDE
	call directWrite
	mov si,sIDEDevicePS
	call directWrite

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,PRIMARY_IDE_INTERFACE_CONTROL
	mov cx,IDE_SLAVE_DEVICE
	call autodetectDevice

	mov ah,VIDEONORMAL
	mov si,sAutodetectIDE
	call directWrite
	mov si,sIDEDeviceSM
	call directWrite

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,SECONDARY_IDE_INTERFACE_CONTROL
	mov cx,IDE_MASTER_DEVICE
	call autodetectDevice

	mov ah,VIDEONORMAL
	mov si,sAutodetectIDE
	call directWrite
	mov si,sIDEDeviceSS
	call directWrite

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,SECONDARY_IDE_INTERFACE_CONTROL
	mov cx,IDE_SLAVE_DEVICE
	call autodetectDevice

	ret

%ifdef ROM
	TIMES (ROMSIZE-($-$$)-ROMSTART) DB 00h
%endif
