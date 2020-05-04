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
	mov ah,02h			; set cursor position
	xor bh,bh			; video page 0
	xor dx,dx			; first row, first column
	int 10h

	mov ah,06h			; scroll up window
	mov al,VIDEO_ROW_COUNT		; by screen height
	mov bh,BIOS_TEXT_COLOR		; attribute to pass to function 06h
	xor cx,cx			; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT-1	; last row
	mov dl,VIDEO_COLUMN_COUNT-1	; last column
	int 10h

.drawMainFrame:
	mov ah,BIOS_TEXT_COLOR

.drawHorizontalFrames:
	mov al,0CDh			; horizontal frame
	mov cx,VIDEO_COLUMN_COUNT-2

	xor dh,dh
	mov dl,1			; row,column = 0,1
	call directWriteChar

	mov dh,3
	mov dl,1			; row,column = 3,1
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT-1
	mov dl,1			; bottom-left = 24,1
	call directWriteChar

	mov dh,10
	mov dl,1			; row,column = 10,1
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT-1
	mov dl,1			; bottom-left = 24,1
	call directWriteChar

.drawVerticalFrames:
	mov al,0BAh			; vertical frame
	mov cx,1			; write one time
	xor dl,dl			; column

.drawLeftFrame:
	mov bl,VIDEO_ROW_COUNT-2
.1:
	mov dh,bl			; row
	call directWriteChar

	dec bl
	cmp bl,1			; stop at intermediate frame intersection
	jae .1

.drawRightFrame:
	mov dl,VIDEO_COLUMN_COUNT-1	; column

	mov bl,VIDEO_ROW_COUNT-2
.2:
	mov dh,bl			; row
	call directWriteChar

	dec bl
	cmp bl,1			; stop at intermediate frame intersection
	jae .2

.drawAllCorners:
	mov cx,1			; write one time

	mov al,0C9h			; top left of frame
	xor dx,dx			; row,column = 0,0
	call directWriteChar

	mov al,0BBh			; top right of frame
	xor dh,dh
	mov dl,VIDEO_COLUMN_COUNT-1	; top-right = 0,79
	call directWriteChar

	mov al,0CCh			; intermediary upper-left of frame
	mov dh,3
	xor dl,dl			; row,column = 3,0
	call directWriteChar

	mov al,0B9h			; intermediary upper-right of frame
	mov dh,3
	mov dl,VIDEO_COLUMN_COUNT-1	; top-right = 3,79
	call directWriteChar

	mov al,0CCh			; intermediary middle-left of frame
	mov dh,10
	xor dl,dl			; row,column = 10,0
	call directWriteChar

	mov al,0B9h			; intermediary middle-right of frame
	mov dh,10
	mov dl,VIDEO_COLUMN_COUNT-1	; top-right = 10,79
	call directWriteChar

	mov al,0C8h			; bottom left of frame
	mov dh,VIDEO_ROW_COUNT-1
	xor dl,dl			; bottom-left = 24,0
	call directWriteChar

	mov al,0BCh			; bottom right of frame
	mov dh,VIDEO_ROW_COUNT-1
	mov dl,VIDEO_COLUMN_COUNT-1	; bottom-right = 24,79
	call directWriteChar

.drawText:
	mov ah,02h			; set cursor position
	xor bh,bh			; video page 0
	mov dh,1			; row
	mov dl,2			; column
	int 10h

	mov ah,BIOS_TEXT_COLOR
	mov si,sProgram
	call directWrite

	mov ah,02h			; set cursor position
	mov dl,2			; column
	int 10h

	mov ah,BIOS_TEXT_COLOR
	mov si,sCopyright
	call directWrite

	mov ah,02h			; set cursor position
	mov dh,4			; row
	mov dl,2			; column
	int 10h

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDevices
	call directWrite

	mov ah,BIOS_TEXT_COLOR
	mov al,0C4h			; top left of frame
	mov cx,76			; write 76 times
	inc dh				; row
	mov dl,2			; column
	call directWriteChar

	mov ah,02h			; set cursor position
	inc dh				; row
	mov dl,2			; column
	int 10h

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDevicePM
	call directWrite

	mov ah,02h			; set cursor position
	inc dh				; row
	mov dl,2			; column
	int 10h

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDevicePS
	call directWrite

	mov ah,02h			; set cursor position
	inc dh				; row
	mov dl,2			; column
	int 10h

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDeviceSS
	call directWrite

	mov ah,02h			; set cursor position
	inc dh				; row
	mov dl,2			; column
	int 10h

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDeviceSS
	call directWrite

	ret

; Clears the screen and sets text color and attribute to default.
; Input:
;   none
; Output:
;   none
; ---------------------------------------------------------------------------
restoreViewMode:
	mov ah,02h			; set cursor position
	xor bh,bh			; video page 0
	xor dx,dx			; row,column = 0,0
	int 10h

	mov ah,06h			; scroll up window
	mov al,VIDEO_ROW_COUNT		; by screen height
	mov bh,VIDEONORMAL		; attribute to pass to function 06h
	xor cx,cx			; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT-1	; last row
	mov dl,VIDEO_COLUMN_COUNT-1	; last column
	int 10h

	ret

; Enter the I/OIF ROM BIOS SETUP Program.
; Input:
;   none
; Output:
;   none
; ---------------------------------------------------------------------------
enterSetup:
	mov ah,01h			; set text-mode cursor shape
	mov cx,2607h			; hide cursor
	int 10h

	call drawSetupTUI

.partialRedraw:
	mov ah,02h			; set cursor position
	xor bh,bh			; video page 0
	mov dh,VIDEO_ROW_COUNT-2	; row
	mov dl,2			; column
	int 10h

	mov ah,BIOS_HIGHLIGHT_TEXT_COLOR
	mov si,sSetupESCExit
	call directWrite

.mainMenuLoop:
	mov ah,01h			; read the state of the keyboard buffer
	int 16h
	jz .mainMenuLoop

	mov ah,00h			; read key press
	int 16h

	cmp al,KBD_ESC
	jne .mainMenuLoop

.exitSetup:
	mov ah,02h			; set cursor position
	mov dh,VIDEO_ROW_COUNT-2	; row
	mov dl,2			; column
	int 10h

	mov ah,BIOS_QUESTION_TEXT_COLOR
	mov si,sSetupExit
	call directWrite

.exitMenuLoop:
	mov ah,01h			; read the state of the keyboard buffer
	int 16h
	jz .exitMenuLoop

	mov ah,00h			; read key press
	int 16h

	cmp al,KBD_ENTER
	jz .exit
	cmp al,KBD_ESC
	jz .partialRedraw
	sub al,20h			; coonvert to uppercase
	cmp al,KBD_Y
	jz .exit
	cmp al,KBD_N
	jz .partialRedraw
	jmp .exitMenuLoop

.exit:
	call restoreViewMode

	mov ah,01h			; set text-mode cursor shape
	mov cx,0607h			; enable cursor
	int 10h

	ret
