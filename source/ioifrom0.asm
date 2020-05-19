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

;%define USETESTDATA
%define EEPROMWRITE

	use16
	cpu 286

%include ".\source\include\equates.inc"

%ifdef ROM
	org ROMSTART
%else
	org DOSSTART
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

;%include ".\source\debug\debug.asm"
%include ".\source\routines.asm"
;%include ".\source\cmos.asm"
%include ".\source\eeprom.asm"
%include ".\source\detect.asm"
%include ".\source\setup.asm"
;%include ".\source\interrupts.asm"

%include ".\source\include\data.inc"
%include ".\source\include\messages.inc"

; Initialization Routine
; Input:
;     none
; Output:
;     none
; Affects:
;     DI
; Preserves:
;     FLAGS, AX, BX, CX, DX, SI, DS, ES
; ---------------------------------------------------------------------------
start:
	pushf
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push ds
	push es
	push bp
	push sp

	xor ax,ax
	mov ss,ax
	mov ax,cs
	mov ds,ax				; DS:SI = CS:SI for entire program
	mov ax,IDE_DEVICES_DATA_SEGMENT
	mov es,ax				; ES:DI = IDE_DEVICES_DATA_SEGMENT:DI for entire program

	call clearIDEDevicesData

	call CRLF

	mov ah,HIGHLIGHT_TEXT_COLOR
	mov si,sProgram
	call directWrite
	mov ah,NORMAL_TEXT_COLOR
	mov si,sCopyright
	call directWrite

	call check8bitCPU
	or al,al
	jnz .continue

	mov si,sBIOSDisabled
	call directWrite

	jmp .exit

.continue:
	call readEEPROMData

	mov si,sPressDELKey
	call directWrite

	mov cx,1
	call delay

	mov ah,01h				; read the state of the keyboard buffer
	int 16h
	jz .autodetectIDEDevices

	mov ah,00h				; read key press
	int 16h

	cmp ax,KEYBOARD_DEL
	jne .autodetectIDEDevices

	call enterSetup

.autodetectIDEDevices:
	mov bx,sIDEDevicePM			; first IDE Device string: Primary Master string
	mov si,IDE_INTERFACES_DEVICE		; first IDE Interface: Primary Master (Device 0)

	mov cx,IDE_DEVICES_DATA_DEVICES_COUNT
.nextIDEDevice:
	call autodetectIDEDevice

	add bx,MSG_IDE_DEVICE_LENGTH		; next IDE Device string
	add si,IDE_INTERFACES_DEVICE_SIZE	; next IDE Interface

	loop .nextIDEDevice

.exit:
	call CRLF

	pop sp
	pop bp
	pop es
	pop ds
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	popf

%ifdef ROM
	retf
%else
	xor al,al
	mov ah,4Ch
	int 21h
%endif

%ifdef ROM
	TIMES (ROMSIZE - ($ - $$) - ROMSTART) DB 00h
%endif
