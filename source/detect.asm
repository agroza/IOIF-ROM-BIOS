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

	;mov ah,VIDEOHIGHLIGHT
	;mov si,sAutodetectNone
	;call directWrite

	;jmp .exit;.printbuffer

	mov dx,[bp-4]
	add dx,STATUS_REGISTER
.1:
	in al,dx
	and al,STATUS_REGISTER_BSY
	jne .1

	cli

	mov dx,[bp-4]
	add dx,STATUS_REGISTER
.2:
	in al,dx
	mov bl,al
	and bl,STATUS_REGISTER_ERR
	je .detectError
	mov bl,al
	and bl,STATUS_REGISTER_DF
	je .detectFault
	mov bl,al
	and bl,STATUS_REGISTER_DRDY
	je .2

.detectError:
	mov ah,VIDEOERROR
	mov si,sAutodetectError
	call directWrite
	;jmp .exit

.detectFault:
    mov ah,VIDEOERROR
	mov si,sAutodetectFault
	call directWrite
	;jmp .exit

.detectNone:
	mov ah,VIDEOHIGHLIGHT
	mov si,sAutodetectNone
	call directWrite
	jmp .exit

	mov dx,[bp-4]
	add dx,SELECT_DRIVE_AND_HEAD_REGISTER
	mov al,[bp-6]
	out dx,al

	mov dx,[bp-4]
	add dx,COMMAND_REGISTER
	mov al,ATA_IDENTIFY_DEVICE_COMMAND
	out dx,al

	mov dx,[bp-4]
	add dx,STATUS_REGISTER
.3:
	in al,dx
	and al,STATUS_REGISTER_DRQ
	je .3

	mov dx,[bp-4]
	add dx,DATA_REGISTER
	mov di,BUFFER ;points DI to the buffer we're using
	mov cx,256

	cld ; INSW increments DI

	rep insw

	sti

;	mov ax,0
;	mov es,ax
;	mov bx,BUFFER
;	mov cx,256
;.4:
;	mov al,'P'
;	mov [bx],al
;	inc bx
;
;	loopnz .4

.printbuffer:
	;mov ax,cs
	;mov es,ax

	;lea di,BUFFER
	;mov cx,255
	;xor ah,ah
	;mov al,'A'
	;rep stosb
	;mov al,0
	;stosb

	mov byte [BUFFER],'P'
	mov byte [BUFFER+1],'s'

	;mov si,pula
	;call print

	mov si,BUFFER
	call print

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