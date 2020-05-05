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
	xor dx,dx			; first row, first column
	call moveCursor

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

	mov dl,1			; first column

	xor dh,dh			; row
	call directWriteChar

	mov dh,3			; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT-1	; row
	call directWriteChar

	mov dh,10			; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT-1	; row
	call directWriteChar

.drawVerticalFrames:
	mov al,0BAh			; vertical frame
	mov cx,1			; write one time

.drawLeftFrame:
	mov dh,VIDEO_ROW_COUNT-2
	xor dl,dl			; column

.1:
	call directWriteChar
	dec dh
	cmp dh,1			; stop at upper frame intersection
	jae .1

.drawRightFrame:
	mov dh,VIDEO_ROW_COUNT-2
	mov dl,VIDEO_COLUMN_COUNT-1	; column

.2:
	call directWriteChar
	dec dh
	cmp dh,1			; stop at upper frame intersection
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
	mov dh,1			; row
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sProgram
	call directWrite

	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sCopyright
	call directWrite

	mov dh,4			; row
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDevices
	call directWrite

	mov dh,4			; row
	mov dl,25			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEParameters
	call directWrite

	mov ah,BIOS_TEXT_COLOR
	mov al,0C4h			; top left of frame
	mov cx,76			; write 76 times
	inc dh				; row
	mov dl,2			; column
	call directWriteChar

	inc dh				; row
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDevicePM
	call directWrite

	inc dh				; row
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDevicePS
	call directWrite

	inc dh				; row
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDeviceSS
	call directWrite

	inc dh				; row
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDeviceSS
	call directWrite

	mov dh,23			; row
	mov dl,16			; column
	call moveCursor

	mov ah,BIOS_HIGHLIGHT_TEXT_COLOR
	mov si,sSetupUsage
	call directWrite

.drawMainMenu:
	mov dh,MAIN_MENU_EDIT_PARAMETERS
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sMainMenuDefineParameters
	call directWrite

	mov dh,MAIN_MENU_AUTODETECT_ALL
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sMainMenuAutodetectAll
	call directWrite

	mov dh,MAIN_MENU_EXIT
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sMainMenuExit
	call directWrite

	mov dh,MAIN_MENU_SAVE_AND_EXIT
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sMainMenuSaveAndExit
	call directWrite

	ret

; Writes a line of IDE Device parameters and computes Device Size.
; Input:
;   DH - row
; Output:
;   none
; ---------------------------------------------------------------------------
drawParameters:
	push bp
	mov bp,sp

	pushf
	push ax
	push bx
	push cx
	push dx

	mov ah,BIOS_TEXT_COLOR
	mov al,20h			; empty space
	mov cx,53			; clear entire line
	mov dl,IDE_DEVICE_TYPE_OFFSET
	call directWriteChar

	mov dl,IDE_DEVICE_TYPE_OFFSET
	call moveCursor

	mov ah,BIOS_TEXT_COLOR

	cmp word [IDE_DEVICE_CYLINDERS],0
	jnz .selectUser

.selectNone:	
	mov si,sIDEDeviceTypeNone
	jmp .writeDeviceType

.selectUser:
	mov si,sIDEDeviceTypeUser
	jmp .writeDeviceType

.selectAuto:
	mov si,sIDEDeviceTypeAuto

.writeDeviceType:
	call directWrite

	mov dl,IDE_DEVICE_CYLINDERS_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_CYLINDERS]
	call print_dec

	mov dl,IDE_DEVICE_HEADS_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_HEADS]
	call print_dec

	mov dl,IDE_DEVICE_SECTORS_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_SECTORS]
	call print_dec

	mov dl,IDE_DEVICE_WPCOMP_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_WPCOMP]
	call print_dec

	mov dl,IDE_DEVICE_LDZONE_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_LDZONE]
	call print_dec

	mov dl,IDE_DEVICE_SIZE_OFFSET
	call moveCursor

	push dx

	mov ax,[IDE_DEVICE_CYLINDERS]
	mov bx,[IDE_DEVICE_HEADS]
	mul bx
	mov bx,[IDE_DEVICE_SECTORS]
	mul bx
	mov bx,1024			; in Mb
	div bx
	shr ax,1			; divide by 2 (assume 512 bps)

	call print_dec

	pop dx

	mov dl,IDE_DEVICE_MODE_OFFSET
	call moveCursor

	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDeviceModeCHS
	call directWrite

	pop dx
	pop cx
	pop bx
	pop ax
	popf

	mov sp,bp
	pop bp

	ret

; Highlights the entire Parameters region during IDE Device detection.
; Input:
;   none
; Output:
;   none
; ---------------------------------------------------------------------------
highlightDetection:
	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	xor ch,ch
	mov cl,53
	mov dl,IDE_DEVICE_TYPE_OFFSET
	call highlightRegion

	ret

; Detects all IDE Devices and fills their parameters.
; Input:
;   none
; Output:
;   none
; ---------------------------------------------------------------------------
detectIDEDevicesParameters:
	push ax
	push bx
	push cx
	push dx
	push ds

	; TODO : decide where to put this line

	mov ax,cs
	mov ds,ax			; DS:SI = CS:IDE_DEVICE_DATA

	mov dh,IDE_DEVICE_PRIMARY_MASTER
	call highlightDetection

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,PRIMARY_IDE_INTERFACE_CONTROL
	mov cl,IDE_MASTER_DEVICE
	call identifyDevice

	call drawParameters

	mov dh,IDE_DEVICE_PRIMARY_SLAVE
	call highlightDetection

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,PRIMARY_IDE_INTERFACE_CONTROL
	mov cl,IDE_SLAVE_DEVICE
	call identifyDevice

	call drawParameters

	mov dh,IDE_DEVICE_SECONDARY_MASTER
	call highlightDetection

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,SECONDARY_IDE_INTERFACE_CONTROL
	mov cl,IDE_MASTER_DEVICE
	call identifyDevice

	call drawParameters

	mov dh,IDE_DEVICE_SECONDARY_SLAVE
	call highlightDetection

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,SECONDARY_IDE_INTERFACE_CONTROL
	mov cl,IDE_SLAVE_DEVICE
	call identifyDevice

	call drawParameters

	pop ds
	pop dx
	pop cx
	pop bx
	pop ax

	ret

; Allows editing of the IDE Devices Parameters.
; Input:
;   none
; Output:
;   none
; ---------------------------------------------------------------------------
editIDEDevicesParameters:
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push ds

	mov ax,cs
	mov ds,ax

	xor bh,bh			; initial row
	mov bl,IDE_DEVICES_REGIONS_TOP
	mov si,IDE_PARAMETERS_REGIONS

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,[si+1]			; region length
	mov dh,bl			; row
	mov dl,[si]			; region offset
	call highlightRegion

.editParametersLoop:
	mov ah,01h			; read the state of the keyboard buffer
	int 16h
	jz .editParametersLoop

	mov ah,00h			; read key press
	int 16h

	cmp ax,KBD_ESC
	je .exit
	cmp ax,KBD_ENTER
	je .executeAction
	cmp ax,KBD_UP
	je .moveUp
	cmp ax,KBD_DOWN
	je .moveDown
	cmp ax,KBD_LEFT
	je .moveLeft
	cmp ax,KBD_RIGHT
	je .moveRight

	jmp .editParametersLoop

.executeAction:

	jmp .editParametersLoop

.moveUp:
	cmp bl,IDE_DEVICES_REGIONS_TOP
	je .editParametersLoop
	dec bl

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,[si+1]			; region length
	mov dh,bl			; row
	mov dl,[si]			; region offset
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	inc dh				; restore previous row
	call highlightRegion
	dec dh				; so that we can clear at exit

	jmp .editParametersLoop

.moveDown:
	cmp bl,IDE_DEVICES_REGIONS_BOTTOM
	je .editParametersLoop
	inc bl

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,[si+1]			; region length
	mov dh,bl			; row
	mov dl,[si]			; region offset
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	dec dh				; restore previous row
	call highlightRegion
	inc dh				; so that we can clear at exit

	jmp .editParametersLoop

.moveLeft:
	or bh,bh
	je .editParametersLoop
	dec bh

	mov ah,BIOS_TEXT_COLOR
	xor ch,ch
	mov cl,[si+1]			; region length
	mov dh,bl			; row
	mov dl,[si]			; region offset
	call highlightRegion

	sub si,2			; previous region

	mov ah,BIOS_SELECTED_COLOR
	mov cl,[si+1]			; region length
	mov dl,[si]			; region offset
	call highlightRegion

	jmp .editParametersLoop

.moveRight:
	cmp bh,IDE_DEVICES_REGIONS_COUNT-1
	je .editParametersLoop
	inc bh

	mov ah,BIOS_TEXT_COLOR
	xor ch,ch
	mov cl,[si+1]			; region length
	mov dh,bl			; row
	mov dl,[si]			; region offset
	call highlightRegion

	add si,2			; next region

	mov ah,BIOS_SELECTED_COLOR
	mov cl,[si+1]			; region length
	mov dl,[si]			; region offset
	call highlightRegion

	jmp .editParametersLoop

.exit:
	mov ah,BIOS_TEXT_COLOR		; destroy any possible selection
	call highlightRegion

	pop ds
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	ret

; Clears the screen and sets text color and attribute to default.
; Input:
;   none
; Output:
;   none
; ---------------------------------------------------------------------------
restoreViewMode:
	xor dx,dx			; row,column = 0,0
	call moveCursor

	mov ah,06h			; scroll up window
	mov al,VIDEO_ROW_COUNT		; by screen height
	mov bh,NORMAL_TEXT_COLOR		; attribute to pass to function 06h
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
	push ds

	mov ax,cs
	mov ds,ax			; DS:SI = CS:IDE_DEVICE_DATA

	mov ah,01h			; set text-mode cursor shape
	mov cx,2607h			; hide cursor
	int 10h

	call drawSetupTUI

	; TODO : Reconsider how to write the params.

	call readCMOSData

	mov dh,IDE_DEVICE_PRIMARY_MASTER
	call drawParameters

	mov dh,IDE_DEVICE_PRIMARY_SLAVE
	call drawParameters

	mov dh,IDE_DEVICE_SECONDARY_MASTER
	call drawParameters

	mov dh,IDE_DEVICE_SECONDARY_SLAVE
	call drawParameters

.partialRedraw:
	xor bh,bh			; initial row
	mov bl,MAIN_MENU_REGIONS_TOP

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,MAIN_MENU_REGION_LENGTH
	mov dh,bl			; row
	mov dl,MAIN_MENU_REGION_OFFSET
	call highlightRegion

	mov dh,VIDEO_ROW_COUNT-2	; row
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_HIGHLIGHT_TEXT_COLOR
	mov si,sSetupESCExit
	call directWrite

.mainMenuLoop:
	mov ah,01h			; read the state of the keyboard buffer
	int 16h
	jz .mainMenuLoop

	mov ah,00h			; read key press
	int 16h

	cmp ax,KBD_ESC
	je .exitSetup
	cmp ax,KBD_ENTER
	je .executeAction
	cmp ax,KBD_UP
	je .moveUp
	cmp ax,KBD_DOWN
	je .moveDown

	jmp .mainMenuLoop

.executeAction:
	cmp bl,MAIN_MENU_EDIT_PARAMETERS
	je .mainMenuEditParameters
	cmp bl,MAIN_MENU_AUTODETECT_ALL
	je .mainMenuAutodetectAll
	cmp bl,MAIN_MENU_EXIT
	je .exitSetup

	jmp .mainMenuLoop

.moveUp:
	cmp bl,MAIN_MENU_REGIONS_TOP
	je .mainMenuLoop
	dec bl

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,MAIN_MENU_REGION_LENGTH
	mov dh,bl			; row
	mov dl,MAIN_MENU_REGION_OFFSET
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	inc dh				; restore previous row
	call highlightRegion
	dec dh				; so that we can clear at exit

	jmp .mainMenuLoop

.moveDown:
	cmp bl,MAIN_MENU_REGIONS_BOTTOM
	je .mainMenuLoop
	inc bl

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,MAIN_MENU_REGION_LENGTH
	mov dh,bl			; row
	mov dl,MAIN_MENU_REGION_OFFSET
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	dec dh				; restore previous row
	call highlightRegion
	inc dh				; so that we can clear at exit

	jmp .mainMenuLoop

.mainMenuEditParameters:
	call editIDEDevicesParameters

	jmp .mainMenuLoop

.mainMenuAutodetectAll:
	call detectIDEDevicesParameters

	jmp .mainMenuLoop

.exitSetup:
	mov ah,BIOS_TEXT_COLOR		; destroy any possible selection
	mov dh,bl			; row
	mov dl,MAIN_MENU_REGION_OFFSET
	call highlightRegion

	mov dh,VIDEO_ROW_COUNT-2	; row
	mov dl,2			; column
	call moveCursor

	mov ah,BIOS_QUESTION_TEXT_COLOR
	mov si,sSetupExit
	call directWrite

.exitMenuLoop:
	mov ah,01h			; read the state of the keyboard buffer
	int 16h
	jz .exitMenuLoop

	mov ah,00h			; read key press
	int 16h

	cmp ax,KBD_ESC
	je .partialRedraw
	cmp ax,KBD_ENTER
	je .exit
	or ah,ah			; switch to characters
	sub al,20h			; convert to uppercase
	cmp al,KBD_Y
	je .exit
	cmp al,KBD_N
	je .partialRedraw

	jmp .exitMenuLoop

.exit:
	call restoreViewMode

	mov ah,01h			; set text-mode cursor shape
	mov cx,0607h			; enable cursor
	int 10h

	pop ds

	ret
