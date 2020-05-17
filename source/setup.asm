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
	mov cx,VIDEO_COLUMN_COUNT - 1

	mov dl,1				; first column

	xor dh,dh				; row
	call directWriteChar

	mov dh,3				; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT			; row
	call directWriteChar

	mov dh,10				; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 2		; row
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT			; row
	call directWriteChar

.drawVerticalFrames:
	mov al,0BAh				; vertical frame
	mov cx,1				; write one time

.drawLeftFrame:
	mov dh,VIDEO_ROW_COUNT - 1
	xor dl,dl				; column

.1:
	call directWriteChar
	dec dh
	cmp dh,1				; stop at upper frame intersection
	jae .1

.drawRightFrame:
	mov dh,VIDEO_ROW_COUNT - 1
	mov dl,VIDEO_COLUMN_COUNT		; column

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
	mov dl,VIDEO_COLUMN_COUNT		; top-right = 0,79
	call directWriteChar

	mov al,0C8h				; bottom left of frame
	mov dh,VIDEO_ROW_COUNT
	xor dl,dl				; bottom-left = 24,0
	call directWriteChar

	mov al,0BCh				; bottom right of frame
	mov dh,VIDEO_ROW_COUNT
	mov dl,VIDEO_COLUMN_COUNT		; bottom-right = 24,79
	call directWriteChar

.drawIntermediaryLeftCorners:
	mov al,0CCh				; intermediary left of frame
	xor dl,dl				; column

	mov dh,3				; intermediary top-left
	call directWriteChar

	mov dh,10				; intermediary middle-left
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 2		; intermediary bottom-left of frame
	call directWriteChar

.drawIntermediaryRightCorners:
	mov al,0B9h				; intermediary upper-right of frame
	mov dl,VIDEO_COLUMN_COUNT		; column

	mov dh,3
	call directWriteChar

	mov dh,10				; intermediary middle-right of frame
	call directWriteChar

	mov dh,VIDEO_ROW_COUNT - 2		; intermediary bottom-right of frame
	call directWriteChar

.drawText:
	mov dh,1				; row
	mov dl,2				; column

	mov si,sProgram
	call directWriteAt

	inc dh
	mov si,sCopyright
	call directWriteAt

	mov dh,4				; row
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
	mov si,sIDEDevicePM
	call directWriteAt

	inc dh					; row
	mov si,sIDEDevicePS
	call directWriteAt

	inc dh					; row
	mov si,sIDEDeviceSS
	call directWriteAt

	inc dh					; row
	mov si,sIDEDeviceSS
	call directWriteAt

	mov dh,MAIN_MENU_DEFINE_PARAMETERS
	mov dl,MAIN_MENU_REGION_OFFSET + 1
	mov si,sMainMenuDefineParameters
	call directWriteAt

	mov dh,MAIN_MENU_AUTODETECT_ALL
	mov si,sMainMenuAutodetectAll
	call directWriteAt

	mov dh,MAIN_MENU_DEVICE_INFORMATION
	mov si,sMainMenuDeviceInformation
	call directWriteAt

	mov dh,MAIN_MENU_EXIT
	mov si,sMainMenuExit
	call directWriteAt

	mov dh,MAIN_MENU_SAVE_AND_EXIT
	mov si,sMainMenuSaveAndExit
	call directWriteAt

	mov dh,SETUP_USAGE_TOP
	mov dl,SETUP_USAGE_OFFSET
	mov ah,BIOS_HIGHLIGHT_TEXT_COLOR
	mov si,sSetupUsage
	call directWriteAt

	ret

; Calculates and displays IDE Device Size.
; Input:
;     BH - color attribute
;     DH - row
;     DI - pointer to IDE_DEVICES_DATA
; Output:
;     AX - IDE Device size in Mb
; Affects:
;     FLAGS, DL
; Preserves:
;     BX, DX
; ---------------------------------------------------------------------------
calculateDisplayIDEDeviceSize:
	mov dl,IDE_DEVICE_REGION_SIZE_OFFSET

	mov ah,bh
	call clearIDEDeviceParameterRegion

	push bx					; store color attribute
	push dx					; store row,column

	mov ax,[di + IDE_DEVICES_DATA_HEADS_OFFSET]
	mov bx,[di + IDE_DEVICES_DATA_SECTORS_OFFSET]
	mul bx
	shr ax,1				; divide (H * S ) by 2 (assume 512 bps)
	mov bx,[di + IDE_DEVICES_DATA_CYLINDERS_OFFSET]
	mul bx
	mov bx,1024				; in Mb
	div bx

	pop dx					; restore row,column
	pop bx					; restore color attribute

	call directWriteInteger

	ret

; Loads SI with the indexed IDE Device Type string located by the given IDE Device Type.
; Input:
;     AL - IDE Device Type
; Output:
;     SI - pointer to indexed IDE Device Type string
; Affects:
;     FLAGS
; Preserves:
;     AX, BX, DX
; ---------------------------------------------------------------------------
loadIDEDeviceTypeOffset:
	push ax
	push bx
	push dx

	xor ah,ah
	xor bh,bh
	mov bl,MSG_IDE_DEVICE_TYPE_LENGTH
	mul bl

	pop dx

	mov si,sIDEDeviceTypeAuto		; first IDE Device Type string
	add si,ax				; indexed IDE Device Type string

	pop bx
	pop ax

	ret

; Draws a zero or a value based on IDE Device Type.
; Input:
;     AX - number
;     BH - color attribute
;     DH - row
;     DL - column
;     DI - IDE_DEVICES_DATA offset
; Output:
;     none
; Affects:
;     FLAGS, AX
; Preserves:
;     none
; ---------------------------------------------------------------------------
drawZeroOrValue:
	cmp byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_USER
	je .drawValue

	xor ax,ax

.drawValue:
	call directWriteInteger

	ret

; Writes a line of IDE Device parameters.
; Input:
;     DH - row
;     SI - pointer to IDE_INTERFACE_DEVICE array
; Output:
;     none
; Affects:
;     FLAGS, AX, DI
; Preserves:
;     BX, CX, DX, SI
; ---------------------------------------------------------------------------
drawIDEDeviceParameters:
	push bx
	push cx
	push dx
	push si

	call calculateIDEDevicesDataOffset

	mov di,ax				; IDE_DEVICES_DATA offset

	mov ah,BIOS_TEXT_COLOR

	mov al,20h				; empty space
	mov cx,IDE_DEVICE_REGION_WIDTH
	mov dl,IDE_DEVICE_REGION_TYPE_OFFSET
	call directWriteChar

	mov byte al,[di + IDE_DEVICES_DATA_TYPE_OFFSET]
	call loadIDEDeviceTypeOffset
	call directWriteAt

	mov bh,ah				; color attribute for directWriteInteger

	mov ax,[di + IDE_DEVICES_DATA_CYLINDERS_OFFSET]
	mov dl,IDE_DEVICE_REGION_CYLINDERS_OFFSET
	call drawZeroOrValue

	mov ax,[di + IDE_DEVICES_DATA_HEADS_OFFSET]
	mov dl,IDE_DEVICE_REGION_HEADS_OFFSET
	call drawZeroOrValue

	mov ax,[di + IDE_DEVICES_DATA_SECTORS_OFFSET]
	mov dl,IDE_DEVICE_REGION_SECTORS_OFFSET
	call drawZeroOrValue

	mov ax,[di + IDE_DEVICES_DATA_WPCOMP_OFFSET]
	mov dl,IDE_DEVICE_REGION_WPCOMP_OFFSET
	call drawZeroOrValue

	mov ax,[di + IDE_DEVICES_DATA_LDZONE_OFFSET]
	mov dl,IDE_DEVICE_REGION_LDZONE_OFFSET
	call drawZeroOrValue

	call calculateDisplayIDEDeviceSize

	mov dl,IDE_DEVICE_REGION_MODE_OFFSET
	mov ah,BIOS_TEXT_COLOR
	mov si,sIDEDeviceModeCHS
	call directWriteAt

	pop si
	pop dx
	pop cx
	pop bx

	ret

; Writes all parameters of all IDE Devices.
; Input:
;     none
; Output:
;     none
; Affects:
;     CX, DH, SI
; Preserves:
;     none
; ---------------------------------------------------------------------------
drawIDEDevicesParameters:
	mov dh,IDE_DEVICES_REGION_PRIMARY_MASTER
	mov si,IDE_INTERFACES_DEVICE		; first IDE Interface: Primary Master (Device 0)

	mov cx,IDE_DEVICES_DATA_DEVICES_COUNT
.drawParameters:
	mov bl,[si + IDE_INTERFACE_DEVICE + 1]	; get device ID
	call drawIDEDeviceParameters

	inc dh					; next row
	add si,IDE_INTERFACES_SIZE		; next IDE Interface

	loop .drawParameters

	ret

; Highlights the entire parameters region during IDE Device detection.
; Input:
;     none
; Output:
;     none
; Affects:
;     FLAGS, AH, DL
; Preserves:
;     CX
; ---------------------------------------------------------------------------
highlightDetection:
	push cx

	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	xor ch,ch
	mov cl,IDE_DEVICE_REGION_WIDTH
	mov dl,IDE_DEVICE_REGION_TYPE_OFFSET
	call highlightRegion

	pop cx

	ret

; Detects all IDE Devices and fills their parameters.
; Input:
;     none
; Output:
;     none
; Affects:
;     SI
; Preserves:
;     BX, CX, DX
; ---------------------------------------------------------------------------
detectIDEDevicesParameters:
	push bx
	push cx
	push dx

	mov dh,IDE_DEVICES_REGION_PRIMARY_MASTER
	mov si,IDE_INTERFACES_DEVICE		; first IDE Interface: Primary Master (Device 0)

	mov cx,IDE_DEVICES_DATA_DEVICES_COUNT
.drawParameters:
	call highlightDetection

	call identifyIDEDevice

	mov bl,[si + IDE_INTERFACE_DEVICE + 1]	; get device ID
	call drawIDEDeviceParameters

	inc dh					; next row
	add si,IDE_INTERFACES_SIZE		; next IDE Interface

	loop .drawParameters

	pop dx
	pop cx
	pop bx

	ret

; Clears the selected Parameter video region.
; Input:
;     AH - color attribute
;     DH - row
;     DL - column
; Output:
;     none
; Affects:
;     none
; Preserves:
;     AX, CX
; ---------------------------------------------------------------------------
clearIDEDeviceParameterRegion:
	push ax
	push cx

	mov cx,IDE_DEVICE_REGION_EDIT_DIGIT_COUNT
	mov al,20h				; empty space
	call directWriteChar

	pop cx
	pop ax

	ret

; Returns the IDE_DEVICES_DATA offset calculated based on the given IDE Device index.
; Input:
;     BH - Y position within IDE_DEVICES_REGION array (TOP, TOP + 1, TOP + 2, TOP + 3)
; Output:
;     AX - IDE_DEVICES_DATA offset
; Affects:
;     FLAGS, BX
; Preserves:
;     none
; ---------------------------------------------------------------------------
loadIDEDeviceDataOffset:
	sub bh,IDE_DEVICES_REGION_TOP		; infer IDE Device index from bh (row = ID)
	xchg bh,bl				; switch IDE Device index to bl
	call calculateIDEDevicesDataOffset

	ret

; Allows editing of the given IDE Device Parameter.
; Input:
;     BH - Y position within IDE_DEVICES_REGION array (TOP, TOP + 1, TOP + 2, TOP + 3)
;     BL - region parameter ID
;     DH - row
;     DL - column
; Output:
;     none
; Affects:
;     FLAGS, AX, DI
; Preserves:
;     BX, CX, DX, SI
; ---------------------------------------------------------------------------
editIDEDeviceNumericParameter:
	push bp
	mov bp,sp

	sub sp,2				; word [bp - 2]: input value

	push bx
	push cx
	push dx
	push si

	call loadIDEDeviceDataOffset		; input: bh; output: ax

	mov si,ax				; IDE_DEVICES_DATA offset

	cmp byte [si + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_USER
	jne .abort

	push si					; later on will be popped as di

	mov bx,[bp - 4]				; stored bx
	xor bh,bh				; ignore high byte
	sub bl,1				; skip TYPE, bl now holds editable parameter index
	shl bx,1				; multiply by word size

	add si,bx				; offset of parameter in the IDE_DEVICES_DATA memory storage matrix

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

.readDigit:
	cmp bl,IDE_DEVICE_REGION_EDIT_DIGIT_COUNT - 1
	ja .editParameterLoop
	inc bl					; next digit

	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR

	cmp bl,1				; first digit?
	jne .skipClear

	call clearIDEDeviceParameterRegion

.skipClear:
	call directWriteChar

	push bx
	push dx

	push ax

	mov ax,[bp - 2]				; ax = input value
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
	dec bl					; previous digit

	dec dl					; column

	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	mov al,20h				; empty space
	call directWriteChar

	push bx
	push dx

	mov ax,[bp - 2]				; ax = input value
	xor bh,bh
	mov bl,10
	xor dx,dx
	div bx
	mov [bp - 2],ax				; update the input value

	pop dx
	pop bx

	jmp .editParameterLoop

.exitSave:
	or bl,bl				; no digit entered?
	jz .exitNoSave

	mov di,IDE_PARAMETERS_CHS

	xor ah,ah
	mov al,[bp - 4]				; region parameter ID from stored bl
	sub al,1				; skip TYPE, bl now holds editable parameter index
	shl al,2				; multiply by 4 (word size * restrictions_count)

	add di,ax				; di now points to the correct restriction position

	mov ax,[bp - 2]				; input value
	cmp ax,[di + IDE_PARAMETER_RESTRICTION_MIN_OFFSET]
	jb .setMinimumRestriction
	cmp ax,[di + IDE_PARAMETER_RESTRICTION_MAX_OFFSET]
	ja .setMaximumRestriction

	jmp .updateValue

.setMinimumRestriction:
	mov ax,[di + IDE_PARAMETER_RESTRICTION_MIN_OFFSET]

	jmp .updateValue

.setMaximumRestriction:
	mov ax,[di + IDE_PARAMETER_RESTRICTION_MAX_OFFSET]

.updateValue:
	mov [si],ax

	sub dl,bl				; set to input start column

	jmp .exit

.exitNoSave:
	mov ax,[si]				; original IDE Device Parameter value
	mov dx,[bp - 8]				; original row,column

	inc dl					; set to input start column

.exit:
	call clearIDEDeviceParameterRegion

	call directWriteInteger

	pop di					; di points to original si

	mov bh,BIOS_TEXT_COLOR			; color attribute
	call calculateDisplayIDEDeviceSize

.abort:
	pop si
	pop dx
	pop cx
	pop bx

	mov sp,bp
	pop bp

	ret

; Draws all IDE Device parameters. In addition, highlights the Type parameter.
; Input:
;     SI - IDE Device Type string
; Output:
;     none
; Affects:
;     AX
; Preserves:
;     BX, CX
; ---------------------------------------------------------------------------
drawIDEDeviceParametersHighlightType:
	push cx

	call drawIDEDeviceParameters

	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	mov dl,IDE_DEVICE_REGION_TYPE_OFFSET - 1

	mov al,20h				; empty space
	mov cx,IDE_DEVICE_REGION_TYPE_LENGTH
	call directWriteChar

	inc dl					; column
	call directWriteAt			; IDE Device Type string

	pop cx

	ret

; Allows editing of IDE Devices text parameters.
; Input:
;     BH - Y position within IDE_DEVICES_REGION array (TOP, TOP + 1, TOP + 2, TOP + 3)
;     BL - region parameter ID
;     DH - row
;     DL - column
; Output:
;     none
; Affects:
;     FLAGS, AX, DI
; Preserves:
;     BX, DX, SI
; ---------------------------------------------------------------------------
editIDEDeviceTextParameter:
	push bp
	mov bp,sp

	sub sp,4				; byte [bp - 2]: initial IDE Device Type
						; word [bp - 4]: initial IDE Device Type string index
	push bx
	push dx
	push si

	or bl,bl				; is the TYPE parameter focused?
	jnz .exit

	call loadIDEDeviceDataOffset		; input: bh; output: ax

	mov di,ax				; IDE_DEVICES_DATA offset

	mov byte al,[di + IDE_DEVICES_DATA_TYPE_OFFSET]
	mov byte [bp - 2],al			; store current IDE Device Type

	call loadIDEDeviceTypeOffset		; input: al; output: si

	mov word [bp - 4],si			; store current IDE Device Type string offset

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
	cmp ax,KEYBOARD_PAGE_UP
	je .modifyPageUp
	cmp ax,KEYBOARD_PAGE_DOWN
	je .modifyPageDown

	jmp .editParameterLoop

.modifyPageUp:
	cmp byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_AUTO
	je .editParameterLoop
	dec byte [di + IDE_DEVICES_DATA_TYPE_OFFSET]

	sub si,MSG_IDE_DEVICE_TYPE_LENGTH	; previous IDE Device Type string

	jmp .writeParameter

.modifyPageDown:
	cmp byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_NONE
	je .editParameterLoop
	inc byte [di + IDE_DEVICES_DATA_TYPE_OFFSET]

	add si,MSG_IDE_DEVICE_TYPE_LENGTH	; next IDE Device Type string

.writeParameter:
	call drawIDEDeviceParametersHighlightType

	jmp .editParameterLoop

.exitNoSave:
	mov al,[bp - 2]				; restore initial IDE Device Type
	mov byte [di + IDE_DEVICES_DATA_TYPE_OFFSET],al
	mov si,[bp - 4]				; restore initial IDE Device Type string offset

.exitSave:
	call drawIDEDeviceParametersHighlightType

.exit:
	pop si
	pop dx
	pop bx

	mov sp,bp
	pop bp

	ret

; Allows editing of the IDE Devices parameters.
; Input:
;     none
; Output:
;     none
; Affects:
;     FLAGS, DI
; Preserves:
;     AX, BX, CX, DX, SI
; ---------------------------------------------------------------------------
defineIDEDevicesParameters:
	push bx
	push cx
	push dx
	push si

.selectFirstItem:
	xor bl,bl				; region parameter ID
	mov bh,IDE_DEVICES_REGION_TOP		; region row
	mov si,IDE_PARAMETERS_REGIONS

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bh				; row
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
	mov ah,BIOS_SELECTED_HIGHLIGHT_COLOR
	call highlightRegion

	or bl,bl
	je .enterEditModeText
	cmp bl,IDE_DEVICE_REGION_COUNT - 1	; skip last region
	je .exitEditMode

.enterEditModeNumber:
	call editIDEDeviceNumericParameter

	jmp .exitEditMode

.enterEditModeText:
	call editIDEDeviceTextParameter

.exitEditMode:
	mov ah,BIOS_SELECTED_COLOR
	call highlightRegion

	jmp .editParametersLoop

.moveUp:
	cmp bh,IDE_DEVICES_REGION_TOP
	je .editParametersLoop
	dec bh					; region row

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bh				; row
	mov dl,[si]				; region offset
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	inc dh					; restore previous row
	call highlightRegion
	dec dh					; so that we can clear at exit

	jmp .editParametersLoop

.moveDown:
	cmp bh,IDE_DEVICES_REGION_BOTTOM
	je .editParametersLoop
	inc bh					; region row

	mov ah,BIOS_SELECTED_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bh				; row
	mov dl,[si]				; region offset
	call highlightRegion

	mov ah,BIOS_TEXT_COLOR
	dec dh					; restore previous row
	call highlightRegion
	inc dh					; so that we can clear at exit

	jmp .editParametersLoop

.moveLeft:
	or bl,bl
	je .editParametersLoop
	dec bl					; region parameter ID

	mov ah,BIOS_TEXT_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bh				; row
	mov dl,[si]				; region offset
	call highlightRegion

	sub si,2				; previous region

	mov ah,BIOS_SELECTED_COLOR
	mov cl,[si + 1]				; region length
	mov dl,[si]				; region offset
	call highlightRegion

	jmp .editParametersLoop

.moveRight:
	cmp bl,IDE_DEVICE_REGION_COUNT - 1
	je .editParametersLoop
	inc bl					; region parameter ID

	mov ah,BIOS_TEXT_COLOR
	xor ch,ch
	mov cl,[si + 1]				; region length
	mov dh,bh				; row
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

	pop si
	pop dx
	pop cx
	pop bx

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
	mov al,VIDEO_ROW_COUNT + 1		; by screen height
	mov bh,BIOS_TEXT_COLOR			; attribute to pass to function 06h
	mov ch,11				; row
	mov dh,VIDEO_ROW_COUNT - 3		; last row - 1
	mov dl,VIDEO_COLUMN_COUNT - 1		; last column - 1
	int 10h

	pop dx

	ret

; Writes the string at SI, if it is not null. Otherwise writes N/A.
; Input:
;     AH - color attribute
;     DH - row
;     DL - column
;     SI - pointer to string
; Output:
;     none
; Affects:
;     FLAGS, SI 
; Preserves:
;     none
; ---------------------------------------------------------------------------
writeStringOrNA:
	cmp byte [si],0
	jne .writeString

.writeNA:
	mov si,sIDEDeviceNA

.writeString:
	call directWriteAt

	ret

; Displays information about the selected IDE Device.
; Input:
;     BL - Y position within IDE_DEVICES_REGION array (TOP, TOP + 1, TOP + 2, TOP + 3)
; Output:
;     none
; Affects:
;     AX, SI
; Preserves:
;     BX, CX, DX
; ---------------------------------------------------------------------------
deviceInformation:
	push bx
	push cx
	push dx

	; TODO : Identify device if not yet done.

	mov cl,IDE_DEVICE_INFO_VALUE_OFFSET	; starting column
	call clearDeviceInformation

	sub bl,IDE_DEVICES_REGION_TOP		; infer IDE Device index from bl (row = ID)
	call calculateIDEDevicesDataOffset

	mov bx,ax				; IDE_DEVICES_DATA offset
	
	mov ah,BIOS_TEXT_COLOR

	mov dh,IDE_DEVICE_INFO_TOP
	mov dl,IDE_DEVICE_INFO_VALUE_OFFSET
	mov si,bx
	add si,IDE_DEVICES_DATA_MODEL_OFFSET
	call writeStringOrNA

	inc dh					; row
	mov si,bx
	add si,IDE_DEVICES_DATA_SERIAL_OFFSET
	call writeStringOrNA

	inc dh					; row
	mov si,bx
	add si,IDE_DEVICES_DATA_REVISION_OFFSET
	call writeStringOrNA

	inc dh					; row
	mov si,sIDEDeviceGeneralList
	call directWriteAt

	inc dh					; row
	mov si,sIDEDeviceFeaturesList
	call directWriteAt

.highlight:
	mov si,bx				; IDE_DEVICES_DATA offset

	cmp byte [si + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_NONE
	je .exit

	xor bx,bx				; extra condition is false

	dec dh					; move to General row

.highlightType:
	mov ah,[si + IDE_DEVICES_DATA_GENERAL_HIGH_OFFSET]
	mov al,ATA_ID_DEV_GENERAL_FIXED_FLAG
	mov dl,IDE_DEVICE_GENERAL_FIXED_OFFSET
	mov cx,IDE_DEVICE_GENERAL_FIXED_LENGTH
	call highlightFeature

	mov al,ATA_ID_DEV_GENERAL_REMOVABLE_FLAG
	add dl,IDE_DEVICE_GENERAL_REMOVABLE_OFFSET
	mov cx,IDE_DEVICE_GENERAL_REMOVABLE_LENGTH
	call highlightFeature

	mov ah,[si + IDE_DEVICES_DATA_GENERAL_LOW_OFFSET]

	mov al,ATA_ID_DEV_GENERAL_NON_MAGNETIC_FLAG
	add dl,IDE_DEVICE_GENERAL_NON_MAGNETIC_OFFSET
	mov cx,IDE_DEVICE_GENERAL_NON_MAGNETIC_LENGTH
	call highlightFeature

.highlightFeatures:
	inc dh					; move to Features row

	mov ah,[si + IDE_DEVICES_DATA_FEATURES_OFFSET]

	mov al,ATA_ID_DEV_FEATURE_LBA_FLAG
	mov dl,IDE_DEVICE_FEATURE_LBA_OFFSET
	mov cx,IDE_DEVICE_FEATURE_LBA_LENGTH
	call highlightFeature

	mov al,ATA_ID_DEV_FEATURE_DMA_FLAG
	add dl,IDE_DEVICE_FEATURE_DMA_OFFSET
	mov cx,IDE_DEVICE_FEATURE_DMA_LENGTH
	call highlightFeature

	; TODO : Improve this section.
	; IORDY could be available if the drive exists. So bl holds IDE Device Type.

	push bx

	mov al,ATA_ID_DEV_FEATURE_IORDY_FLAG
	mov bl,[si + IDE_DEVICES_DATA_TYPE_OFFSET]
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
	mov si,sIDEDeviceSerial
	call directWriteAt

	inc dh					; row
	mov si,sIDEDeviceRevision
	call directWriteAt

	inc dh					; row
	mov si,sIDEDeviceGeneral
	call directWriteAt

	inc dh					; row
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

	mov cl,IDE_DEVICE_INFO_KEY_OFFSET - 2	; starting column
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
	mov al,VIDEO_ROW_COUNT + 1		; by screen height
	mov bh,BIOS_TEXT_COLOR			; attribute to pass to function 06h
	xor cx,cx				; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT			; last row
	mov dl,VIDEO_COLUMN_COUNT		; last column
	int 10h

	call drawSetupTUI

	call drawIDEDevicesParameters

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
	cmp ax,KEYBOARD_F10
	je .saveAndExitSetup

	jmp .mainMenuLoop

.executeAction:
	cmp bl,MAIN_MENU_DEFINE_PARAMETERS
	je .mainMenuDefineParameters
	cmp bl,MAIN_MENU_AUTODETECT_ALL
	je .mainMenuAutodetectAll
	cmp bl,MAIN_MENU_DEVICE_INFORMATION
	je .mainMenuDeviceInformation
	cmp bl,MAIN_MENU_EXIT
	je .exitSetup
	cmp bl,MAIN_MENU_SAVE_AND_EXIT
	je .saveAndExitSetup

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

.mainMenuDefineParameters:
	call defineIDEDevicesParameters

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

.saveAndExitSetup:
	call writeEEPROMData

.exit:
	xor dx,dx				; row,column = 0,0
	call moveCursor

	mov ah,06h				; scroll up window
	mov al,VIDEO_ROW_COUNT + 1		; by screen height
	mov bh,NORMAL_TEXT_COLOR		; attribute to pass to function 06h
	xor cx,cx				; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT			; last row
	mov dl,VIDEO_COLUMN_COUNT		; last column
	int 10h

	mov ah,01h				; set text-mode cursor shape
	mov cx,0607h				; enable cursor
	int 10h

	ret
