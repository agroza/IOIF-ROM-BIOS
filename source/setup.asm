; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS SETUP Program (setup.asm)                        -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

; Draws the I/OIF ROM BIOS SETUP Program text-mode interface.
; Input:
;   none
; Output:
;   none
; ---------------------------------------------------------------------------
drawSetupTUI:
	mov ah,02h					; set cursor position
	xor dx,dx					; first row, first column
	int 10h

	mov ah,06h					; scroll up window
	mov al,25					; by screen height
	mov bh,(BLUE<<4)+WHITE		; attribute to pass to function 06h
	xor cx,cx					; top-left = 0,0
	mov dh,VIDEO_ROW_COUNT-1	; last row
	mov dl,VIDEO_COLUMN_COUNT-1	; last column
	int 10h

.drawTopFrame:
	mov ah,BIOS_TEXT_COLOR

	mov al,0C9h					; top left of frame
	mov cx,1
	xor dx,dx					; top-left = 0,0
	call directWriteChar

	mov al,0CDh					; horizontal frame
	mov cx,VIDEO_COLUMN_COUNT-2
	xor dh,dh
	mov dl,1					; top-left = 0,1
	call directWriteChar

	mov al,0BBh					; top right of frame
	mov cx,1
	xor dh,dh
	mov dl,VIDEO_COLUMN_COUNT-1	; top-right = 0,79
	call directWriteChar

.drawIntermediaryFrame:
	mov al,0CCh					; intermediary left of frame
	mov cx,1
	mov dh,3
	xor dl,dl					; top-left = 3,0
	call directWriteChar

	mov al,0CDh					; horizontal frame
	mov cx,VIDEO_COLUMN_COUNT-2
	mov dh,3
	mov dl,1					; top-left = 3,1
	call directWriteChar

	mov al,0B9h					; intermediary right of frame
	mov cx,1
	mov dh,3
	mov dl,VIDEO_COLUMN_COUNT-1	; top-right = 3,79
	call directWriteChar

.drawBottomFrame:
	mov al,0C8h					; bottom left of frame
	mov cx,1
	mov dh,VIDEO_ROW_COUNT-1
	xor dl,dl					; bottom-left = 24,0
	call directWriteChar

	mov al,0CDh					; horizontal frame
	mov cx,VIDEO_COLUMN_COUNT-2
	mov dh,VIDEO_ROW_COUNT-1
	mov dl,1					; bottom-left = 24,1
	call directWriteChar

	mov al,0BCh					; bottom right of frame
	mov cx,1
	mov dh,VIDEO_ROW_COUNT-1
	mov dl,VIDEO_COLUMN_COUNT-1	; bottom-right = 24,79
	call directWriteChar

.drawLeftFrame:
	; TODO : Implement writing of vertical left frame.

.drawRightFrame:
	; TODO : Implement writing of vertical left frame.

.drawText:
	mov ah,02h					; set cursor position
	xor bh,bh
	mov dh,1					; row
	mov dl,2					; column
	int 10h

	mov ah,BIOS_TEXT_COLOR
	mov si,sProgram
	call directWrite

	mov ah,02h					; set cursor position
	mov dl,2					; column
	int 10h

	mov ah,BIOS_TEXT_COLOR
	mov si,sCopyright
	call directWrite

	ret

restoreViewMode:
	mov ah,02h					; set cursor position
	xor dx,dx					; first row, first column
	int 10h

	mov ah,06h					; scroll up window
	mov al,25					; by screen height
	mov bh,VIDEONORMAL			; attribute to pass to function 06h
	xor cx,cx					; top-left = 0,0
	mov dh,24					; last row
	mov dl,79					; last column
	int 10h

	ret

; Enter the I/OIF ROM BIOS SETUP Program.
; Input:
;   none
; Output:
;   none
; ---------------------------------------------------------------------------
enterSetup:
	mov ah,01h					; set text-mode cursor shape
	mov cx,2607h				; hide cursor
	int 10h

	call drawSetupTUI

menuLoop:
	mov ah,01h					; read the state of the keyboard buffer
	int 16h
	jz menuLoop

	mov ah,00h					; read key press
	int 16h
	cmp al,KBD_ESC
	jne menuLoop

.quit:
	; TODO : Add code to confirm that you really want to exit.

.exit:
	call restoreViewMode

	mov ah,01h					; set text-mode cursor shape
	mov cx,0607h				; enable cursor
	int 10h

	ret