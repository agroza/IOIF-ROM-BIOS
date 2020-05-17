; ---------------------------------------------------------------------------
; - EEPROM Routines (eeprom.asm)                                            -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

; Reads all IDE Devices parameters from EEPROM.
; Input:
;     none
; Output:
;     none
; Affects:
;     BL, CX, SI, DI
; Preserves:
;     none
; ---------------------------------------------------------------------------
readEEPROMData:
	cld

	mov si,IDE_DEVICES_STORED_DATA
	mov di,IDE_DEVICES_DATA

	mov bl,IDE_DEVICES_DATA_DEVICES_COUNT

.readData:
	mov cx,IDE_DEVICES_STORED_DATA_SIZE

	rep movsb

	add di,IDE_DEVICES_DATA_SIZE - IDE_DEVICES_STORED_DATA_SIZE

	dec bl
	jnz .readData

	ret

; Writes all IDE Devices parameters to EEPROM.
; Input:
;     none
; Output:
;     AL - ROM checksum
; Affects:
;     FLAGS, BL, CX, SI, DI
; Preserves:
;     none
; ---------------------------------------------------------------------------
writeEEPROMData:
%ifdef EEPROMWRITE
	cld

	mov si,IDE_DEVICES_DATA
	mov di,IDE_DEVICES_STORED_DATA

	mov bl,IDE_DEVICES_DATA_DEVICES_COUNT

.writeData:
	; TODO : Currently the programEEPROMCode routine writes directly in memory.
	; It should write to the ROM IC instead.

	mov cx,IDE_DEVICES_STORED_DATA_SIZE
	call programEEPROMCode

	add si,IDE_DEVICES_DATA_SIZE - IDE_DEVICES_STORED_DATA_SIZE

	dec bl
	jnz .writeData

.calculateChecksum:
	xor si,si
	xor al,al

	mov cx,ROMSIZE - 1			; skip existing checksum byte

.nextByte:
	add byte al,[si]
	inc si

	loop .nextByte

	neg al

	inc si
	mov byte [si],al			; last ROM byte is the recalculated checksum
%endif

	ret

; EEPROM programing (code patching) routine.
; Input:
;     CX - data size (in bytes)
;     SI - pointer to IDE_DEVICES_DATA in memory
;     DI - pointer to IDE_DEVICES_STORED_DATA in EEPROM
; Output:
;     CX - 0 = success, non-zero = fail
;     AH - 0 = assume SDP is not present, 1 = assume SDP is present
; Affects:
;     FLAGS, AL, CX, DX, SI, DI
; Preserves:
;     BX
; ---------------------------------------------------------------------------
programEEPROMCode:
	push bx

	cli

	cld

	xor ah,ah				; assume SDP is not present

.writeEEPROM:
	mov byte al,[si]
	cmp byte al,[di]
	je .nextByte

	or ah,ah				; retest if SDP is present
	jz .writeData

.enableSDPWrites:
	mov byte [es:1555h],0AAh		; this sequence is described
	mov byte [es:0AAAh],55h			; in the ATMEL 28C64B datasheet
	mov byte [es:1555h],0A0h		; at page 8 (REV. 0270H–12/99)

.writeData:
	mov byte [di],al

	xor bx,bx				; wait cycle time counter (2 - 10 ms)

.writeCycleTime:
	cmp byte al,[di]
	je .nextByte
	dec bx
	jnz .writeCycleTime

	or ah,ah				; retest if SDP is present
	jnz .exit

	inc ah					; assume SDP is present
	jmp .enableSDPWrites

.nextByte:
	inc si
	inc di

	loop .writeEEPROM

.exit:
	sti

	pop bx

	ret

PROGRAM_EEPROM_CODE_SIZE			EQU	($ - programEEPROMCode)
