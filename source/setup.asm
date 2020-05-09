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
; Affects:
;     FLAGS, AX, CX, DX, SI
; Preserves:
;     none
; ---------------------------------------------------------------------------
drawSetupTUI:
	mov ah,BIOS_TEXT_COLOR

.drawHorizontalFrames:
	mov al,0CDh				; horizontal frame
	mov cx,VIDEO_COLUMN_COUNT - 2

	mov dl,1				; first column

	xor dh,dh				; row
	call directWriteChar

	mov dh,3				; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 1		; row
	call directWriteChar

	mov dh,10				; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 3		; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 1		; row
	call directWriteChar

.drawVerticalFrames:
	mov al,0BAh				; vertical frame
	mov cx,1				; write one time

.drawLeftFrame:
	mov dh,VIDEO_ROW_COUNT - 2
	xor dl,dl				; column

.1:
	call directWriteChar
	dec dh
	cmp dh,1				; stop at upper frame intersection
	jae .1

.drawRightFrame:
	mov dh,VIDEO_ROW_COUNT - 2
	mov dl,VIDEO_COLUMN_COUNT - 1		; column

.2:
	call directWriteChar
	dec dh
	cmp dh,1				; stop at upper frame intersection
	jae .2

.drawAllCorners:
	mov cx,1				; write one time

	mov al,0C9h				; top left of frame
	xor dx,dx				; row,column = 0,0
	call directWriteChar

	mov al,0BBh				; top right of frame
	xor dh,dh
	mov dl,VIDEO_COLUMN_COUNT - 1		; top-right = 0,79
	call directWriteChar

	mov al,0C8h				; bottom left of frame
	mov dh,VIDEO_ROW_COUNT - 1
	xor dl,dl				; bottom-left = 24,0
	call directWriteChar

	mov al,0BCh				; bottom right of frame
	mov dh,VIDEO_ROW_COUNT - 1
	mov dl,VIDEO_COLUMN_COUNT - 1		; bottom-right = 24,79
	call directWriteChar

.drawIntermediaryLeftCorners:
	mov al,0CCh				; intermediary left of frame
	xor dl,dl				; column

	mov dh,3				; intermediary top-left
	call directWriteChar

	mov dh,10				; intermediary middle-left
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 3		; intermediary bottom-left of frame
	call directWriteChar

.drawIntermediaryRightCorners:
	mov al,0B9h				; intermediary upper-right of frame
	mov dl,VIDEO_COLUMN_COUNT - 1		; column

	mov dh,3
	call directWriteChar

	mov dh,10				; intermediary middle-right of frame
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 3		; intermediary bottom-right of frame
	call directWriteChar

.drawText:
	mov dh,1				; row
	mov dl,2				; column

	mov si,sProgram
	call directWriteAt

	mov dl,2				; column
	mov si,sCopyright
	call directWriteAt

	mov dh,4				; row
	mov dl,2				; column
	mov si,sIDEDevices
	call directWriteAt

	mov dh,4				; row
	mov dl,25				; column
	mov si,sIDEParameters
	call directWriteAt

	mov al,0C4h				; top left of frame
	mov cx,76				; write 76 times
	inc dh					; row
	mov dl,2				; column
	call directWriteChar

	inc dh					; row
	mov dl,2				; column
	mov si,sIDEDevicePM
	call directWriteAt

	inc dh					; row
	mov dl,2				; column
	mov si,sIDEDevicePS
	call directWriteAt

	inc dh					; row
	mov dl,2				; column
	mov si,sIDEDeviceSS
	call directWriteAt

	inc dh					; row
	mov dl,2				; column
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

	mov dh,SETUP_USAGE_TOP
	mov dl,SETUP_USAGE_OFFSET
	mov ah,BIOS_HIGHLIGHT_TEXT_COLOR
	mov si,sSetupUsage
	call directWriteAt

	ret

; Writes a line of IDE Device parameters and computes Device Size.
; Input:
;     DH - row
; Output:
;     none
; Affects:
;     FLAGS, SI, DI
; Preserves:
;     AX, BX, CX, DX
; ---------------------------------------------------------------------------
drawParameters:
	push bp
	mov bp,sp

	push ax
	push bx
	push cx
	push dx

	mov bl,[si + IDE_INTERFACE_DEVICE + 1]	; get device ID
	call calculataIDEDevicesDataOffset

	mov di,ax

	mov ah,BIOS_TEXT_COLOR

	mov al,20h				; empty space
	mov cx,IDE_DEVICE_REGION_WIDTH
	mov dl,IDE_DEVICE_REGION_TYPE_OFFSET
	call directWriteChar

	mov dl,IDE_DEVICE_REGION_TYPE_OFFSET

	cmp word [di + IDE_DEVICES_DATA_CYLINDERS_OFFSET],0
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

	mov bh,ah				; color attribute for directWriteInteger

	mov ax,[di + IDE_DEVICES_DATA_CYLINDERS_OFFSET]
	mov dl,IDE_DEVICE_REGION_CYLINDERS_OFFSET
	call directWriteInteger

	mov ax,[di + IDE_DEVICES_DATA_HEADS_OFFSET]
	mov dl,IDE_DEVICE_REGION_HEADS_OFFSET
	call directWriteInteger

	mov ax,[di + IDE_DEVICES_DATA_SECTORS_OFFSET]
	mov dl,IDE_DEVICE_REGION_SECTORS_OFFSET
	call directWriteInteger

	mov ax,[di + IDE_DEVICES_DATA_WPCOMP_OFFSET]
	mov dl,IDE_DEVICE_REGION_WPCOMP_OFFSET
	call directWriteInteger

	mov ax,[di + IDE_DEVICES_DATA_LDZONE_OFFSET]
	mov dl,IDE_DEVICE_REGION_LDZONE_OFFSET
	call directWriteInteger

	push bx					; save color attribute
	push dx					; save row,column

	mov ax,[di + IDE_DEVICES_DATA_CYLINDERS_OFFSET]
	mov bx,[di + IDE_DEVICES_DATA_HEADS_OFFSET]
	mul bx
	mov bx,[di + IDE_DEVICES_DATA_SECTORS_OFFSET]
	mul bx
	mov bx,1024				; in Mb
	div bx
	shr ax,1				; divide by 2 (assume 512 bps)

	pop dx					; restore row,column
	pop bx					; restore color attribute

	mov dl,IDE_DEVICE_REGION_SIZE_OFFSET
	call directWriteInteger

	mov dl,IDE_DEVICE_REGION_MODE_OFFSET
	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDeviceModeCHS
	call directWriteAt

	pop dx
	pop cx
	pop bx
	pop ax

	mov sp,bp
	pop bp

	ret

; Highlights the entire Parameters region during IDE Device detection.
; Input:
;     none
; Output:
;     none
; Affects:
;     FLAGS, AH, CX, DL
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
; Affects:
;     SI
; Preserves:
;     AX, BX, CX, DX
; ---------------------------------------------------------------------------
detectIDEDevicesParameters:
	; TODO : Are all these registers necessary?

	push ax
	push bx
	push cx
	push dx

	mov dh,IDE_DEVICES_REGION_PRIMARY_MASTER
	call highlightDetection

	mov si,IDE_INTERFACES_DEVICE_0	
	call identifyDevice

	call drawParameters

	mov dh,IDE_DEVICES_REGION_PRIMARY_SLAVE
	call highlightDetection

	mov si,IDE_INTERFACES_DEVICE_1
	call identifyDevice

	call drawParameters

	mov dh,IDE_DEVICES_REGION_SECONDARY_MASTER
	call highlightDetection

	mov si,IDE_INTERFACES_DEVICE_2
	call identifyDevice

	call drawParameters

	mov dh,IDE_DEVICES_REGION_SECONDARY_SLAVE
	call highlightDetection

	mov si,IDE_INTERFACES_DEVICE_3
	call identifyDevice

	call drawParameters

	pop dx
	pop cx
	pop bx
	pop ax

	ret

; Allows editing of the given IDE Device Parameter.
; Input:
;     AX - pointer to the parameter
; Output:
;     none
; Affects:
;     FLAGS
; Preserves:
;     AX, BX, CX, DX, SI
; ---------------------------------------------------------------------------
editIDEDeviceParameter:
	push bp
	mov bp,sp

	sub sp,2				; input value

	push ax					; bp - 4 = IDE Device Parameter
	push bx					; bh - parameter ID
	push cx
	push dx
	push si

	; TODO : Optimize the entire function.

	call calculataIDEDevicesDataOffset
	mov si,ax

	mov bx,[bp-6]				; stored bx
	xchg bh,bl				; move the IDE Device Parameter in bl
	xor bh,bh				; ignore high byte
	shl bx,1				; multiply by word size

	add si,bx				; relative parameter

	mov cx,1				; write one time
	inc dl					; column

	xor bl,bl				; decimal digit counter

	mov word [bp - 2],0			; start with input value 0

.editParameterLoop:
	mov ah,01h				; read the state of the keyboard buffer
	int 16h
	jz .editParameterLoop

	mov ah,00h				; read key press
	int 16h

	cmp ax,KEYBOARD_ESC
	je .exitNoSave
	cmp ax,KEYBOARD_ENTER
	je .exitSave
	cmp ax,KEYBOARD_BACKSPACE
	je .backOnePosition
	cmp al,KEYBOARD_0
	jb .editParameterLoop
	cmp al,KEYBOARD_9
	ja .editParameterLoop

	cmp bl,4
	ja .editParameterLoop
	inc bl

	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR

	cmp bl,1				; first digit?
	jne .skipClear

	; TODO : Refactor or extract this Ugly routine.

	push ax
	push cx
	push dx

	mov cx,5				; clear the visual input
	mov al,20h				; empty space
	call directWriteChar

	pop dx
	pop cx
	pop ax

.skipClear:
	call directWriteChar

	push bx
	push dx

	push ax

	mov ax,[bp - 2]
	xor bh,bh
	mov bl,10
	mul bx
	mov [bp - 2],ax

	pop ax

	xor ah,ah
	sub al,30h				; convert to decimal
	add [bp - 2],ax				; update the input value

	pop dx
	pop bx

	inc dl					; column

	jmp .editParameterLoop

.backOnePosition:
	or bl,bl
	jz .editParameterLoop
	dec bl

	dec dl					; column

	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	mov al,20h				; empty space
	call directWriteChar

	push bx
	push dx

	xor dx,dx

	mov ax,[bp - 2]
	xor bh,bh
	mov bl,10
	div bx
	mov [bp - 2],ax				; update the input value

	pop dx
	pop bx

	jmp .editParameterLoop

.exitNoSave:
	mov ax,[si]				; original value
	mov dx,[bp - 10]			; original row,column
	inc dl					; column

	; TODO : Refactor or extract this Ugly routine.

	push ax
	push cx
	push dx

	mov cx,5				; clear the visual input
	mov al,20h				; empty space
	call directWriteChar

	pop dx
	pop cx
	pop ax

	call directWriteInteger

	jmp .exit

.exitSave:
	mov ax,[bp - 2]				; input value
	mov [si],ax

	; TODO : Extract the size calculation routine.

.exit:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	mov sp,bp
	pop bp

	ret

; Allows editing of the IDE Devices Parameters.
; Input:
;     none
; Output:
;     none
; Affects:
;     FLAGS
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
	xor bh,bh				; initial row
	mov bl,IDE_DEVICES_REGION_TOP
	mov si,IDE_PARAMETERS_REGIONS

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bl				; row
	mov dl,[si]				; region offset
	call highlightRegion

.editParametersLoop:
	mov ah,01h				; read the state of the keyboard buffer
	int 16h
	jz .editParametersLoop

	mov ah,00h				; read key press
	int 16h

	cmp ax,KEYBOARD_ESC
	je .exit
	cmp ax,KEYBOARD_ENTER
	je .executeAction
	cmp ax,KEYBOARD_PAGE_UP
	je .executePageUp
	cmp ax,KEYBOARD_PAGE_DOWN
	je .executePageDown
	cmp ax,KEYBOARD_UP
	je .moveUp
	cmp ax,KEYBOARD_DOWN
	je .moveDown
	cmp ax,KEYBOARD_LEFT
	je .moveLeft
	cmp ax,KEYBOARD_RIGHT
	je .moveRight

	jmp .editParametersLoop

.executeAction:
	or bh,bh				; skip first region
	je .editParametersLoop
	cmp bh,IDE_DEVICE_REGION_COUNT - 1	; skip last region
	je .editParametersLoop

	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	call highlightRegion

	push bx

	sub bh,1				; skip TYPE, bh now holds editable parameter index
	sub bl,IDE_DEVICES_REGION_TOP		; infer IDE Device index from bl (row = ID)
	call editIDEDeviceParameter

	pop bx

	mov ah,BIOS_SELECTED_COLOR
	call highlightRegion

	jmp .editParametersLoop

.executePageUp:

	jmp .editParametersLoop

.executePageDown:

	jmp .editParametersLoop

.moveUp:
	cmp bl,IDE_DEVICES_REGION_TOP
	je .editParametersLoop
	dec bl

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bl				; row
	mov dl,[si]				; region offset
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	inc dh					; restore previous row
	call highlightRegion
	dec dh					; so that we can clear at exit

	jmp .editParametersLoop

.moveDown:
	cmp bl,IDE_DEVICES_REGION_BOTTOM
	je .editParametersLoop
	inc bl

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bl				; row
	mov dl,[si]				; region offset
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	dec dh					; restore previous row
	call highlightRegion
	inc dh					; so that we can clear at exit

	jmp .editParametersLoop

.moveLeft:
	or bh,bh
	je .editParametersLoop
	dec bh

	mov ah,BIOS_TEXT_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bl				; row
	mov dl,[si]				; region offset
	call highlightRegion

	sub si,2				; previous region

	mov ah,BIOS_SELECTED_COLOR
	mov cl,[si + 1]				; region length
	mov dl,[si]				; region offset
	call highlightRegion

	jmp .editParametersLoop

.moveRight:
	cmp bh,IDE_DEVICE_REGION_COUNT - 1
	je .editParametersLoop
	inc bh

	mov ah,BIOS_TEXT_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bl				; row
	mov dl,[si]				; region offset
	call highlightRegion

	add si,2				; next region

	mov ah,BIOS_SELECTED_COLOR
	mov cl,[si + 1]				; region length
	mov dl,[si]				; region offset
	call highlightRegion

	jmp .editParametersLoop

.exit:
	mov ah,BIOS_TEXT_COLOR			; destroy any possible selection
	call highlightRegion

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	ret

; Highlights a specific IDE Device Feature.
; Input:
;     AH - features byte
;     AL - feature test bit mask
;     BL - extra condition test bit mask: possible = !(ah and al) or bl
;     DH - row
;     DL - column
;     CX - feature string length
; Output:
;     none
; Affects:
;     FLAGS
; Preserves:
;     AX
; ---------------------------------------------------------------------------
highlightFeature:
	push ax

	and ah,al
	jnz .featurePresent

.featureAbsent:
	or bl,bl
	jnz .featurePossible

	mov ah,IDE_FEATURE_ABSENT

	jmp .exit

.featurePossible:
	mov ah,IDE_FEATURE_POSSIBLE

	jmp .exit

.featurePresent:
	mov ah,IDE_FEATURE_PRESENT

.exit:
	call highlightRegion	

	pop ax

	ret

; Clears the IDE Device Information region, starting at the given column.
; Input:
;     CL - starting column
; Output:
;     none
; Affects:
;     AX, BH
; Preserves:
;     DX
; ---------------------------------------------------------------------------
clearDeviceInformation:
	push dx

	mov ah,06h				; scroll up window
	mov al,VIDEO_ROW_COUNT			; by screen height
	mov bh,BIOS_TEXT_COLOR			; attribute to pass to function 06h
	mov ch,11				; row
	mov dh,VIDEO_ROW_COUNT - 4		; last row - 1
	mov dl,VIDEO_COLUMN_COUNT - 2		; last column - 1
	int 10h

	pop dx

	ret

; Displays information about the selected IDE Device.
; Input:
;     BL - device ID
; Output:
;     none
; Affects:
;     SI
; Preserves:
;     BX, CX, DX
; ---------------------------------------------------------------------------
deviceInformation:
	push bx
	push cx
	push dx

	mov cl,IDE_DEVICE_INFO_VALUE_OFFSET	; starting column
	call clearDeviceInformation

	sub bl,IDE_DEVICES_REGION_TOP		; infer IDE Device index from bl (row = ID)
	call calculataIDEDevicesDataOffset

	mov bx,ax
	
	mov ah,BIOS_TEXT_COLOR

	mov dh,IDE_DEVICE_INFO_TOP
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov si,bx
	add si,IDE_DEVICES_DATA_MODEL_OFFSET
	call directWriteAt

	inc dh					; row
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov si,bx
	add si,IDE_DEVICES_DATA_SERIAL_OFFSET
	call directWriteAt

	inc dh					; row
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET	
	mov si,bx
	add si,IDE_DEVICES_DATA_REVISION_OFFSET
	call directWriteAt

	inc dh					; row
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov si,sIDEDeviceGeneralList
	call directWriteAt

	inc dh					; row
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov si,sIDEDeviceFeaturesList
	call directWriteAt

	; TODO : Testing for cylinders <> 0. It is ugly and needs refactor.

	cmp word [bx],0				; no cylinders?
	je .exit

.highlight:
	xor bx,bx				; extra condition is false

	dec dh					; row

	; TODO : Static IDE_DEVICES_DATA addressing is wrong. They should rely on BX. Or better an indexable register.

.highlightType:
	mov ah,[IDE_DEVICES_DATA + IDE_DEVICES_DATA_GENERAL_HIGH_OFFSET]
	mov al,ATA_ID_DEV_GENERAL_FIXED_FLAG
	mov dl,IDE_DEVICE_GENERAL_FIXED_OFFSET
	mov cx,IDE_DEVICE_GENERAL_FIXED_LENGTH
	call highlightFeature

	mov al,ATA_ID_DEV_GENERAL_REMOVABLE_FLAG
	add dl,IDE_DEVICE_GENERAL_REMOVABLE_OFFSET
	mov cx,IDE_DEVICE_GENERAL_REMOVABLE_LENGTH
	call highlightFeature

	mov ah,[IDE_DEVICES_DATA + IDE_DEVICES_DATA_GENERAL_LOW_OFFSET]

	mov al,ATA_ID_DEV_GENERAL_NON_MAGNETIC_FLAG
	add dl,IDE_DEVICE_GENERAL_NON_MAGNETIC_OFFSET
	mov cx,IDE_DEVICE_GENERAL_NON_MAGNETIC_LENGTH
	call highlightFeature

.highlightFeatures:
	inc dh					; row

	mov ah,[IDE_DEVICES_DATA + IDE_DEVICES_DATA_FEATURES_OFFSET]

	mov al,ATA_ID_DEV_FEATURE_LBA_FLAG
	mov dl,IDE_DEVICE_FEATURE_LBA_OFFSET
	mov cx,IDE_DEVICE_FEATURE_LBA_LENGTH
	call highlightFeature

	mov al,ATA_ID_DEV_FEATURE_DMA_FLAG
	add dl,IDE_DEVICE_FEATURE_DMA_OFFSET
	mov cx,IDE_DEVICE_FEATURE_DMA_LENGTH
	call highlightFeature

	push bx

	; TODO : IORDY availability could be better signalled.
	; IORDY could be available if drive exists. So bl is number of cylinders.

	mov al,ATA_ID_DEV_FEATURE_IORDY_FLAG
	mov bl,[IDE_DEVICES_DATA + IDE_DEVICES_DATA_CYLINDERS_OFFSET + 1]
	add dl,IDE_DEVICE_FEATURE_IORDY_OFFSET
	mov cx,IDE_DEVICE_FEATURE_IORDY_LENGTH
	call highlightFeature

	pop bx

	mov al,ATA_ID_DEV_FEATURE_IORDY_DISABLE_FLAG
	add dl,IDE_DEVICE_FEATURE_IORDY_DISABLE_OFFSET
	mov cx,IDE_DEVICE_FEATURE_IORDY_DISABLE_LENGTH
	call highlightFeature

.exit:
	pop dx
	pop cx
	pop bx

	ret

; Allows viewing of extended IDE Devices Information.
; Input:
;     none
; Output:
;     none
; Affects:
;     FLAGS, AX, SI 
; Preserves:
;     BX, CX, DX
; ---------------------------------------------------------------------------
viewIDEDevicesInformation:
	push bx
	push cx
	push dx

	mov ah,BIOS_TEXT_COLOR

.drawVerticalFrames:
	mov al,0B0h				; vertical frame
	mov cx,1				; write one time

.drawLeftFrame:
	mov dh,21
	mov dl,23				; column

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

	inc dh					; row
	mov dl,IDE_DEVICE_INFO_KEY_OFFSET
	mov si,sIDEDeviceSerial
	call directWriteAt

	inc dh					; row
	mov dl,IDE_DEVICE_INFO_KEY_OFFSET
	mov si,sIDEDeviceRevision
	call directWriteAt

	inc dh					; row
	mov dl,IDE_DEVICE_INFO_KEY_OFFSET
	mov si,sIDEDeviceGeneral
	call directWriteAt

	inc dh					; row
	mov dl,IDE_DEVICE_INFO_KEY_OFFSET
	mov si,sIDEDeviceFeatures
	call directWriteAt

.selectFirstItem:
	xor bh,bh				; ignore row
	mov bl,IDE_DEVICES_REGION_TOP

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,IDE_DEVICES_REGION_LENGTH
	mov dh,bl				; row
	mov dl,IDE_DEVICES_REGION_OFFSET - 1
	call highlightRegion

.ideDevicesMenuLoop:
	mov ah,01h				; read the state of the keyboard buffer
	int 16h
	jz .ideDevicesMenuLoop

	mov ah,00h				; read key press
	int 16h

	cmp ax,KEYBOARD_ESC
	je .exit
	cmp ax,KEYBOARD_ENTER
	je .executeAction
	cmp ax,KEYBOARD_UP
	je .moveUp
	cmp ax,KEYBOARD_DOWN
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
	mov dh,bl				; row
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	inc dh					; restore previous row
	call highlightRegion
	dec dh					; so that we can clear at exit

	jmp .ideDevicesMenuLoop

.moveDown:
	cmp bl,IDE_DEVICES_REGION_BOTTOM
	je .ideDevicesMenuLoop
	inc bl

	mov ah,BIOS_SELECTED_COLOR
	mov dh,bl				; row
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	dec dh					; restore previous row
	call highlightRegion
	inc dh					; so that we can clear at exit

	jmp .ideDevicesMenuLoop

.exit:
	mov ah,BIOS_TEXT_COLOR			; destroy any possible selection
	call highlightRegion

	mov cl,23				; starting column
	call clearDeviceInformation

	pop dx
	pop cx
	pop bx

	ret

; Enter the I/OIF ROM BIOS SETUP Program.
; Input:
;     none
; Output:
;     none
; Affects:
;     FLAGS, AX, BX, CX, DX, SI
; Preserves:
;     none
; ---------------------------------------------------------------------------
enterSetup:
	mov ah,00h				; set video mode
	mov al,03h				; 80 x 25, 16 colors
	int 10h

	mov ah,01h				; set text-mode cursor shape
	mov cx,2607h				; hide cursor
	int 10h

	mov ah,06h				; scroll up window
	mov al,VIDEO_ROW_COUNT			; by screen height
	mov bh,BIOS_TEXT_COLOR			; attribute to pass to function 06h
	xor cx,cx				; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT - 1		; last row
	mov dl,VIDEO_COLUMN_COUNT - 1		; last column
	int 10h

	call drawSetupTUI

	; This will most probably be replaced with a call to read the EEPROM stored parameters.

	call readCMOSData

.partialRedraw:
	mov dh,SETUP_USAGE_TOP
	mov dl,2				; column
	mov ah,BIOS_HIGHLIGHT_TEXT_COLOR
	mov si,sSetupESCExit
	call directWriteAt

.selectFirstItem:
	xor bh,bh				; initial row
	mov bl,MAIN_MENU_REGION_TOP

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,MAIN_MENU_REGION_LENGTH
	mov dh,bl				; row
	mov dl,MAIN_MENU_REGION_OFFSET
	call highlightRegion

.mainMenuLoop:
	mov ah,01h				; read the state of the keyboard buffer
	int 16h
	jz .mainMenuLoop

	mov ah,00h				; read key press
	int 16h

	cmp ax,KEYBOARD_ESC
	je .exitSetup
	cmp ax,KEYBOARD_ENTER
	je .executeAction
	cmp ax,KEYBOARD_UP
	je .moveUp
	cmp ax,KEYBOARD_DOWN
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
	mov dh,bl				; row
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	inc dh					; restore previous row
	call highlightRegion
	dec dh					; so that we can clear at exit

	jmp .mainMenuLoop

.moveDown:
	cmp bl,MAIN_MENU_REGION_BOTTOM
	je .mainMenuLoop
	inc bl

	mov ah,BIOS_SELECTED_COLOR
	mov dh,bl				; row
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	dec dh					; restore previous row
	call highlightRegion
	inc dh					; so that we can clear at exit

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
	mov ah,BIOS_TEXT_COLOR			; destroy any possible selection
	call highlightRegion

	mov dh,SETUP_USAGE_TOP
	mov dl,2				; column
	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	mov si,sSetupExit
	call directWriteAt

.exitMenuLoop:
	mov ah,01h				; read the state of the keyboard buffer
	int 16h
	jz .exitMenuLoop

	mov ah,00h				; read key press
	int 16h

	cmp ax,KEYBOARD_ESC
	je .partialRedraw
	cmp ax,KEYBOARD_ENTER
	je .exit
	or ah,ah				; switch to characters
	sub al,20h				; convert to uppercase
	cmp al,KEYBOARD_Y
	je .exit
	cmp al,KEYBOARD_N
	je .partialRedraw

	jmp .exitMenuLoop

.exit:
	xor dx,dx				; row,column = 0,0
	call moveCursor

	mov ah,06h				; scroll up window
	mov al,VIDEO_ROW_COUNT			; by screen height
	mov bh,NORMAL_TEXT_COLOR		; attribute to pass to function 06h
	xor cx,cx				; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT - 1		; last row
	mov dl,VIDEO_COLUMN_COUNT - 1		; last column
	int 10h

	mov ah,01h				; set text-mode cursor shape
	mov cx,0607h				; enable cursor
	int 10h

	ret
