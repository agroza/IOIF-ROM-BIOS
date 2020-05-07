; ---------------------------------------------------------------------------
; - General Purpose Routines (routines.asm)                                 -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

; Moves the cursor to the specified row and column.
; Input:
;     DH - row
;     DL - column
; Output:
;     none
; Affects:
;     FLAGS
; Preserves:
;     BX
; ---------------------------------------------------------------------------
moveCursor:
	push bx

	mov ah,02h			; set cursor position
	xor bh,bh			; video page 0
	int 10h

	pop bx

	ret

; Advances the cursor to the next line, column 0.
; Input:
;     none
; Output:
;     none
; Affects:
;     FLAGS, AX, BX, DX
; Preserves:
;     none
; ---------------------------------------------------------------------------
CRLF:
	mov ah,03h			; get cursor position
	xor bh,bh			; video page 0
	int 10h

	xor dl,dl			; first column

	cmp dh,VIDEO_ROW_COUNT-1	; last row?
	jz .scrollUp
	inc dh				; next row
	call moveCursor

	jmp .exit

.scrollUp:
	call moveCursor

	mov ah,08h			; read character and attribute at cursor position
	int 10h
	mov bh,ah			; attribute to pass to function 06h

	mov ah,06h			; scroll up window
	mov al,1			; by one line
	xor cx,cx			; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT-1	; last row
	mov dl,VIDEO_COLUMN_COUNT-1	; last column
	int 10h

.exit:
	ret

; Calculates the new position in VGA RAM.
; Input:
;     DH - row
;     DL - column
; Output:
;     AX - result
; Affects:
;     FLAGS, BX
; Preserves:
;     CX, DX
; ---------------------------------------------------------------------------
calculatePosition:
	push cx
	push dx

	mov cx,dx

	xor ah,ah
	mov al,ch			; row
	xor bh,bh
	mov bl,VIDEO_COLUMN_COUNT
	mul bx
	shl ax,1			; multiply by 2
	xor dh,dh
	mov dl,cl			; column
	shl dx,1			; multiply by 2
	add ax,dx

	pop dx
	pop cx

	ret

; Highlight a linear region directly in the VGA RAM.
; Input:
;     AH - color attribute
;     DH - row
;     DL - column
;     CX - number of characters
; Output:
;     none
; Affects:
;     none
; Preserves:
;     AX, BX, CX, SI, DI, DS, ES
; ---------------------------------------------------------------------------
highlightRegion:
	push bp
	mov bp,sp

	push ax
	push bx
	push cx
	push si
	push di
	push ds
	push es

	mov ax,VIDEO_RAM_SEGMENT
	mov ds,ax			; DS:SI = 0B800h:SI
	mov es,ax			; ES:DI = 0B800h:DI

	call calculatePosition

	mov si,ax
	mov di,ax			; ES:DI = (dh * 80 + dl) * 2

	cld

.doHighlight:
	lodsw
	mov ah,[bp-1]			; attribute from stack (original ax)
	stosw

	loop .doHighlight

	pop es
	pop ds
	pop di
	pop si
	pop cx
	pop bx
	pop ax

	mov sp,bp
	pop bp

	ret

; Writes a character directly to the VGA RAM.
; Input:
;     AH - color attribute
;     AL - character
;     DH - row
;     DL - column
;     CX - number of characters
; Output:
;     none
; Affects:
;     none
; Preserves:
;     AX, BX, CX, DI, ES
; ---------------------------------------------------------------------------
directWriteChar:
	push bp
	mov bp,sp

	push ax
	push bx
	push cx
	push di
	push es

	mov ax,VIDEO_RAM_SEGMENT
	mov es,ax			; ES:DI = 0B800h:DI

	call calculatePosition

	mov di,ax			; ES:DI = (dh * 80 + dl) * 2
	mov ax,[bp-2]			; (attribute|character) from stack (original ax)

	cld

	rep stosw

	pop es
	pop di
	pop cx
	pop bx
	pop ax

	mov sp,bp
	pop bp

	ret

; Writes a null-terminated string directly to the VGA RAM.
; Input:
;     AH    - color attribute
;     DS:SI - pointer to string
; Output:
;     none
; Affects:
;     FLAGS
; Preserves:
;     AX, BX, CX, SI, DI, ES
; ---------------------------------------------------------------------------
directWrite:
	push bp
	mov bp,sp

	push ax
	push bx
	push cx
	push si
	push di
	push es

	mov ax,VIDEO_RAM_SEGMENT
	mov es,ax			; ES:DI = 0B800h:SI

	mov ah,03h			; get cursor position
	xor bh,bh			; video page 0
	int 10h

	cld

.computePosition:
	call calculatePosition

	mov di,ax			; ES:DI = (ch * 80 + cl) * 2
	mov ah,[bp-1]			; attribute from stack (original ah)

.nextByte:
	lodsb				; load byte from DS:SI

	or al,al			; end of string?
	jz .exit
	cmp al,13			; carriage return?
	jz .CR
	cmp al,10			; line feed?
	jz .LF

	stosw				; store word (attribute|character) in ES:DI

	inc dl				; next column

	jmp .nextByte

.CR:
	mov dl,0			; first column
	call moveCursor

	jmp .computePosition

.LF:
	cmp dh,VIDEO_ROW_COUNT-1	; last row?
	jz .scrollUp
	inc dh				; next row
	call moveCursor

	jmp .computePosition

.scrollUp:
	call moveCursor

	push dx				; save row,column

	mov ah,08h			; read character and attribute at cursor position
	int 10h
	mov bh,ah			; attribute to pass to function 06h

	mov ah,06h			; scroll up window
	mov al,1			; by one line
	xor cx,cx			; row,column = 0,0
	mov dh,VIDEO_ROW_COUNT-1	; last row
	mov dl,VIDEO_COLUMN_COUNT-1	; last column
	int 10h

	pop dx				; restore row,column

	; TODO : Should it be .computePosition ?

	jmp .nextByte

.exit:
	call moveCursor

	pop es
	pop di
	pop si
	pop cx
	pop bx
	pop ax

	mov sp,bp
	pop bp

	ret

; Writes a null-terminated string directly to the VGA RAM at position: DH,DL.
; Input:
;     AH    - color attribute
;     DH    - row
;     DL    - column
;     DS:SI - pointer to string
; Output:
;     none
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
directWriteAt:
	; TODO : It would be a good ideea to store DX. Might reduce code size.

	push ax
	call moveCursor
	pop ax
	call directWrite

	ret

; Writes an integer number directly to the VGA RAM at position: DH,DL.
; Input:
;     AX - number
;     BH - color attribute
;     DH - row
;     DL - column
; Output:
;     none
; Affected:
;     FLAGS
; Preserves:
;     BX, CX, DX
; ---------------------------------------------------------------------------
directWriteInteger:
	push bp
	mov bp,sp

	push bx
	push cx
	push dx

	mov bx,10			; base-10

	xor cx,cx			; number of digits

.nextDigit:
	xor dx,dx
	div bx				; dx = dx:ax % bx
	add dx,30h			; convert to character

	push dx				; save digit (dl)

	inc cx				; next digit

	or ax,ax
	jnz .nextDigit

.printDigit:
	pop dx				; load digit (dl)

	mov ah,[bp-1]			; stored bh = color attribute
	mov al,dl
	mov dx,[bp-6]			; stored dx = row,column
	call directWriteChar

	inc byte [bp-6]			; next column
	call moveCursor

	loop .printDigit

	pop dx
	pop cx
	pop bx

	mov sp,bp
	pop bp

	ret

; Delay for a number of seconds using the System Timer.
; Input:
;     CX - number of seconds
; Output:
;     none
; Affects:
;      FLAGS, AX, CX
; Preserves:
;     BX, DX, DS
; ---------------------------------------------------------------------------
delay:
	push bx
	push dx
	push ds

	xor ax,ax
	mov ds,ax			; DS:SI = 0000h:SI

	mov ax,18			; 18 Hz
	mul cx				; how many seconds
	xchg ax,cx			; result in cx
	mov bx,[46Ch]			; BIOS timer count is updated at 18.2 Hz

.nextUpdate:
	mov ax,[46Ch]			; BIOS timer count is updated at 18.2 Hz
	cmp ax,bx			; same timer count?
	je .nextUpdate
	mov bx,ax			; store the new compare value
	loop .nextUpdate

	pop ds
	pop dx
	pop bx

	ret
