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
;     none
; Output:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
drawSetupTUI:
	mov ah,BIOS_TEXT_COLOR

.drawHorizontalFrames:
	mov al,0CDh			; horizontal frame
	mov cx,VIDEO_COLUMN_COUNT - 2

	mov dl,1			; first column

	xor dh,dh			; row
	call directWriteChar

	mov dh,3			; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 1	; row
	call directWriteChar

	mov dh,10			; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 3	; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 1	; row
	call directWriteChar

.drawVerticalFrames:
	mov al,0BAh			; vertical frame
	mov cx,1			; write one time

.drawLeftFrame:
	mov dh,VIDEO_ROW_COUNT - 2
	xor dl,dl			; column

.1:
	call directWriteChar
	dec dh
	cmp dh,1			; stop at upper frame intersection
	jae .1

.drawRightFrame:
	mov dh,VIDEO_ROW_COUNT - 2
	mov dl,VIDEO_COLUMN_COUNT - 1	; column

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
	mov dl,VIDEO_COLUMN_COUNT - 1	; top-right = 0,79
	call directWriteChar

	mov al,0C8h			; bottom left of frame
	mov dh,VIDEO_ROW_COUNT - 1
	xor dl,dl			; bottom-left = 24,0
	call directWriteChar

	mov al,0BCh			; bottom right of frame
	mov dh,VIDEO_ROW_COUNT - 1
	mov dl,VIDEO_COLUMN_COUNT - 1	; bottom-right = 24,79
	call directWriteChar

.drawIntermediaryLeftCorners:
	mov al,0CCh			; intermediary left of frame
	xor dl,dl			; column

	mov dh,3			; intermediary top-left
	call directWriteChar

	mov dh,10			; intermediary middle-left
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 3	; intermediary bottom-left of frame
	call directWriteChar

.drawIntermediaryRightCorners:
	mov al,0B9h			; intermediary upper-right of frame
	mov dl,VIDEO_COLUMN_COUNT - 1	; column

	mov dh,3
	call directWriteChar

	mov dh,10			; intermediary middle-right of frame
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 3	; intermediary bottom-right of frame
	call directWriteChar

.drawText:
	mov dh,1			; row
	mov dl,2			; column

	mov si,sProgram
	call directWriteAt

	mov dl,2			; column
	mov si,sCopyright
	call directWriteAt

	mov dh,4			; row
	mov dl,2			; column
	mov si,sIDEDevices
	call directWriteAt

	mov dh,4			; row
	mov dl,25			; column
	mov si,sIDEParameters
	call directWriteAt

	mov al,0C4h			; top left of frame
	mov cx,76			; write 76 times
	inc dh				; row
	mov dl,2			; column
	call directWriteChar

	inc dh				; row
	mov dl,2			; column
	mov si,sIDEDevicePM
	call directWriteAt

	inc dh				; row
	mov dl,2			; column
	mov si,sIDEDevicePS
	call directWriteAt

	inc dh				; row
	mov dl,2			; column
	mov si,sIDEDeviceSS
	call directWriteAt

	inc dh				; row
	mov dl,2			; column
	mov si,sIDEDeviceSS
	call directWriteAt

.drawMainMenu:
	mov dh,MAIN_MENU_EDIT_PARAMETERS
	mov dl,MAIN_MENU_REGION_OFFSET + 1
	mov si,sMainMenuDefineParameters
	call directWriteAt

	mov dh,MAIN_MENU_AUTODETECT_ALL
	mov dl,MAIN_MENU_REGION_OFFSET + 1
	mov si,sMainMenuAutodetectAll
	call directWriteAt

	mov dh,MAIN_MENU_DEVICE_INFORMATION
	mov dl,MAIN_MENU_REGION_OFFSET + 1
	mov si,sMainMenuDeviceInformation
	call directWriteAt

	mov dh,MAIN_MENU_EXIT
	mov dl,MAIN_MENU_REGION_OFFSET + 1
	mov si,sMainMenuExit
	call directWriteAt

	mov dh,MAIN_MENU_SAVE_AND_EXIT
	mov dl,MAIN_MENU_REGION_OFFSET + 1
	mov si,sMainMenuSaveAndExit
	call directWriteAt

	mov dh,23			; row
	mov dl,16			; column
	mov ah,BIOS_HIGHLIGHT_TEXT_COLOR
	mov si,sSetupUsage
	call directWriteAt

	ret

; Writes a line of IDE Device parameters and computes Device Size.
; Input:
;     DH - row
; Output:
;     none
; Preserves:
;     FLAGS, AX, BX, CX, DX
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
	mov cx,IDE_DEVICE_REGION_WIDTH
	mov dl,IDE_DEVICE_REGION_TYPE_OFFSET
	call directWriteChar

	mov dl,IDE_DEVICE_REGION_TYPE_OFFSET

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
	call directWriteAt

	mov dl,IDE_DEVICE_REGION_CYLINDERS_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_CYLINDERS]
	call print_dec

	mov dl,IDE_DEVICE_REGION_HEADS_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_HEADS]
	call print_dec

	mov dl,IDE_DEVICE_REGION_SECTORS_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_SECTORS]
	call print_dec

	mov dl,IDE_DEVICE_REGION_WPCOMP_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_WPCOMP]
	call print_dec

	mov dl,IDE_DEVICE_REGION_LDZONE_OFFSET
	call moveCursor

	mov ax,[IDE_DEVICE_LDZONE]
	call print_dec

	mov dl,IDE_DEVICE_REGION_SIZE_OFFSET
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

	mov dl,IDE_DEVICE_REGION_MODE_OFFSET
	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDeviceModeCHS
	call directWriteAt

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
;     none
; Output:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
highlightDetection:
	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	xor ch,ch
	mov cl,IDE_DEVICE_REGION_WIDTH
	mov dl,IDE_DEVICE_REGION_TYPE_OFFSET
	call highlightRegion

	ret

; Detects all IDE Devices and fills their parameters.
; Input:
;     none
; Output:
;     none
; Preserves:
;     AX, BX, CX, DX
; ---------------------------------------------------------------------------
detectIDEDevicesParameters:
	push ax
	push bx
	push cx
	push dx

	mov dh,IDE_DEVICES_REGION_PRIMARY_MASTER
	call highlightDetection

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,PRIMARY_IDE_INTERFACE_CONTROL
	mov cl,IDE_MASTER_DEVICE
	call identifyDevice

	call drawParameters

	mov dh,IDE_DEVICES_REGION_PRIMARY_SLAVE
	call highlightDetection

	mov ax,PRIMARY_IDE_INTERFACE
	mov bx,PRIMARY_IDE_INTERFACE_CONTROL
	mov cl,IDE_SLAVE_DEVICE
	call identifyDevice

	call drawParameters
%ifdef comment
	mov dh,IDE_DEVICES_REGION_SECONDARY_MASTER
	call highlightDetection

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,SECONDARY_IDE_INTERFACE_CONTROL
	mov cl,IDE_MASTER_DEVICE
	call identifyDevice

	call drawParameters

	mov dh,IDE_DEVICES_REGION_SECONDARY_SLAVE
	call highlightDetection

	mov ax,SECONDARY_IDE_INTERFACE
	mov bx,SECONDARY_IDE_INTERFACE_CONTROL
	mov cl,IDE_SLAVE_DEVICE
	call identifyDevice

	call drawParameters
%endif
	pop dx
	pop cx
	pop bx
	pop ax

	ret

; Allows editing of one IDE Device Parameter.
; Input:
;     none
; Output:
;     none
; Preserves:
;     AX
; ---------------------------------------------------------------------------
editIDEDeviceParameter:
	push ax

.editParameterLoop:
	mov ah,01h			; read the state of the keyboard buffer
	int 16h
	jz .editParameterLoop

	mov ah,00h			; read key press
	int 16h

	cmp ax,KBD_ESC
	je .exit
	cmp ax,KBD_ENTER
	je .exitSave

	; TODO : Allow entering of numbers.

	jmp .editParameterLoop

.exitSave:
	; TODO : Save the value.

.exit:
	pop ax

	ret

; Allows editing of the IDE Devices Parameters.
; Input:
;     none
; Output:
;     none
; Preserves:
;     AX, BX, CX, DX, SI, DI
; ---------------------------------------------------------------------------
editIDEDevicesParameters:
	push ax
	push bx
	push cx
	push dx
	push si
	push di

.selectFirstItem:
	xor bh,bh			; initial row
	mov bl,IDE_DEVICES_REGION_TOP
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
	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	call highlightRegion

	call editIDEDeviceParameter

	mov ah,BIOS_SELECTED_COLOR
	call highlightRegion

	jmp .editParametersLoop

.moveUp:
	cmp bl,IDE_DEVICES_REGION_TOP
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
	cmp bl,IDE_DEVICES_REGION_BOTTOM
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
	cmp bh,IDE_DEVICE_REGION_COUNT - 1
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

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	ret

; Displays information about the selected IDE Device.
; Input:
;     BL - device ID
; Output:
;     none
; Preserves:
;     BX, CX, DX
; ---------------------------------------------------------------------------
deviceInformation:
	push bx
	push cx
	push dx

	; TODO : put bx to use

	mov ah,BIOS_TEXT_COLOR

	mov dh,IDE_DEVICE_INFO_TOP
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov si,IDE_DEVICE_MODEL
	call directWriteAt

	inc dh				; row
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov si,IDE_DEVICE_SERIAL
	call directWriteAt

	inc dh				; row
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov si,IDE_DEVICE_REVISION
	call directWriteAt

	inc dh				; row
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov si,sIDEDeviceFeaturesList
	call directWriteAt

	; TODO : Extract constants separately.

.highlightFeatures:
	mov ah,IDE_FEATURE_PRESENT
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov cx,3 ; lba
	call highlightRegion

	mov ah,IDE_FEATURE_ABSENT
	add dl,5
	mov cx,3 ; dma
	call highlightRegion

	mov ah,IDE_FEATURE_PRESENT
	add dl,5
	mov cx,6 ; iordy
	call highlightRegion

	mov ah,IDE_FEATURE_POSSIBLE
	add dl,7
	mov cx,11 ; disableable
	call highlightRegion

	pop dx
	pop cx
	pop bx

	ret

; Allows viewing of extended IDE Devices Information.
; Input:
;     none
; Output:
;     none
; Preserves:
;     DX
; ---------------------------------------------------------------------------
viewIDEDevicesInformation:
	push bx
	push cx
	push dx

	mov ah,BIOS_TEXT_COLOR

.drawVerticalFrames:
	mov al,0B0h			; vertical frame
	mov cx,1			; write one time

.drawLeftFrame:
	mov dh,21
	mov dl,23			; column

.1:
	call directWriteChar
	dec dh
	cmp dh,IDE_DEVICE_INFO_TOP
	jae .1

.drawText:
	mov dh,IDE_DEVICE_INFO_TOP
	mov dl,IDE_DEVICE_INFO_KEY_OFFSET
	mov si,sIDEDeviceModel
	call directWriteAt

	inc dh				; row
	mov dl,IDE_DEVICE_INFO_KEY_OFFSET
	mov si,sIDEDeviceSerial
	call directWriteAt

	inc dh				; row
	mov dl,IDE_DEVICE_INFO_KEY_OFFSET
	mov si,sIDEDeviceRevision
	call directWriteAt

	inc dh				; row
	mov dl,IDE_DEVICE_INFO_KEY_OFFSET
	mov si,sIDEDeviceFeatures
	call directWriteAt

.selectFirstItem:
	xor bh,bh			; initial row
	mov bl,IDE_DEVICES_REGION_TOP

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,IDE_DEVICES_REGION_LENGTH
	mov dh,bl			; row
	mov dl,IDE_DEVICES_REGION_OFFSET - 1
	call highlightRegion

.ideDevicesMenuLoop:
	mov ah,01h			; read the state of the keyboard buffer
	int 16h
	jz .ideDevicesMenuLoop

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

	jmp .ideDevicesMenuLoop

.executeAction:
	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	call highlightRegion

	push cx
	mov cx,1
	call delay
	pop cx

	mov ah,BIOS_SELECTED_COLOR
	call highlightRegion

	call deviceInformation

	jmp .ideDevicesMenuLoop

.moveUp:
	cmp bl,IDE_DEVICES_REGION_TOP
	je .ideDevicesMenuLoop
	dec bl

	mov ah,BIOS_SELECTED_COLOR
	mov dh,bl			; row
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	inc dh				; restore previous row
	call highlightRegion
	dec dh				; so that we can clear at exit

	jmp .ideDevicesMenuLoop

.moveDown:
	cmp bl,IDE_DEVICES_REGION_BOTTOM
	je .ideDevicesMenuLoop
	inc bl

	mov ah,BIOS_SELECTED_COLOR
	mov dh,bl			; row
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	dec dh				; restore previous row
	call highlightRegion
	inc dh				; so that we can clear at exit

	jmp .ideDevicesMenuLoop

.exit:
	mov ah,BIOS_TEXT_COLOR		; destroy any possible selection
	call highlightRegion

	mov ah,06h			; scroll up window
	mov al,VIDEO_ROW_COUNT		; by screen height
	mov bh,BIOS_TEXT_COLOR		; attribute to pass to function 06h
	mov ch,11			; row
	mov cl,23			; column
	mov dh,VIDEO_ROW_COUNT - 4	; last row - 1
	mov dl,VIDEO_COLUMN_COUNT - 2	; last column - 1
	int 10h

	pop dx
	pop cx
	pop bx

	ret

; Enter the I/OIF ROM BIOS SETUP Program.
; Input:
;     none
; Output:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
enterSetup:
	mov ah,01h			; set text-mode cursor shape
	mov cx,2607h			; hide cursor
	int 10h

	mov ah,06h			; scroll up window
	mov al,VIDEO_ROW_COUNT		; by screen height
	mov bh,BIOS_TEXT_COLOR		; attribute to pass to function 06h
	xor cx,cx			; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT - 1	; last row
	mov dl,VIDEO_COLUMN_COUNT - 1	; last column
	int 10h

	call drawSetupTUI

	; TODO : Reconsider how to write the params.

	call readCMOSData

	mov dh,IDE_DEVICES_REGION_PRIMARY_MASTER
	call drawParameters

	mov dh,IDE_DEVICES_REGION_PRIMARY_SLAVE
	call drawParameters

	mov dh,IDE_DEVICES_REGION_SECONDARY_MASTER
	call drawParameters

	mov dh,IDE_DEVICES_REGION_SECONDARY_SLAVE
	call drawParameters

.partialRedraw:
	mov dh,VIDEO_ROW_COUNT - 2	; row
	mov dl,2			; column
	mov ah,BIOS_HIGHLIGHT_TEXT_COLOR
	mov si,sSetupESCExit
	call directWriteAt

.selectFirstItem:
	xor bh,bh			; initial row
	mov bl,MAIN_MENU_REGION_TOP

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,MAIN_MENU_REGION_LENGTH
	mov dh,bl			; row
	mov dl,MAIN_MENU_REGION_OFFSET
	call highlightRegion

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
	cmp bl,MAIN_MENU_DEVICE_INFORMATION
	je .mainMenuDeviceInformation
	cmp bl,MAIN_MENU_EXIT
	je .exitSetup

	jmp .mainMenuLoop

.moveUp:
	cmp bl,MAIN_MENU_REGION_TOP
	je .mainMenuLoop
	dec bl

	mov ah,BIOS_SELECTED_COLOR
	mov dh,bl			; row
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	inc dh				; restore previous row
	call highlightRegion
	dec dh				; so that we can clear at exit

	jmp .mainMenuLoop

.moveDown:
	cmp bl,MAIN_MENU_REGION_BOTTOM
	je .mainMenuLoop
	inc bl

	mov ah,BIOS_SELECTED_COLOR
	mov dh,bl			; row
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

.mainMenuDeviceInformation:
	call viewIDEDevicesInformation

	jmp .mainMenuLoop

.exitSetup:
	mov ah,BIOS_TEXT_COLOR		; destroy any possible selection
	call highlightRegion

	mov dh,VIDEO_ROW_COUNT - 2	; row
	mov dl,2			; column
	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	mov si,sSetupExit
	call directWriteAt

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
	xor dx,dx			; row,column = 0,0
	call moveCursor

	mov ah,06h			; scroll up window
	mov al,VIDEO_ROW_COUNT		; by screen height
	mov bh,NORMAL_TEXT_COLOR	; attribute to pass to function 06h
	xor cx,cx			; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT - 1	; last row
	mov dl,VIDEO_COLUMN_COUNT - 1	; last column
	int 10h

	mov ah,01h			; set text-mode cursor shape
	mov cx,0607h			; enable cursor
	int 10h

	ret
