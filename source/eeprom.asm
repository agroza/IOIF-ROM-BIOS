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

; Writes all IDE Devices parameters to EEPROM. Not available in MS-DOS version.
; Input:
;     none
; Output:
;     AL - ROM checksum (or last byte written)
; Affects:
;     FLAGS, BL, CX, SI, DI
; Preserves:
;     DS, ES
; ---------------------------------------------------------------------------
writeEEPROMData:
%ifdef ROM
	push ds
	push es

.copyProgramEEPROMCode:
	push PROGRAM_EEPROM_CODE_SEGMENT
	pop es

	mov si,programEEPROMCode
	xor di,di
	mov cx,PROGRAM_EEPROM_CODE_SIZE

	cld

	rep movsb

.writeIDEDevicesParameters:
	push IDE_DEVICES_DATA_SEGMENT
	pop ds
	push cs
	pop es

	mov si,IDE_DEVICES_DATA
	mov di,IDE_DEVICES_STORED_DATA

	mov bl,IDE_DEVICES_DATA_DEVICES_COUNT

.writeData:
	mov cx,IDE_DEVICES_STORED_DATA_SIZE
	call PROGRAM_EEPROM_CODE_SEGMENT:PROGRAM_EEPROM_CODE_OFFSET

	add si,IDE_DEVICES_DATA_SIZE - IDE_DEVICES_STORED_DATA_SIZE

	dec bl

	jnz .writeData

.calculateChecksum:
	xor di,di
	xor al,al

	mov cx,ROMSIZE - 1			; skip existing checksum byte

.nextROMByte:
	es add byte al,[di]			; add each ROM byte to an 8-bit sum

	inc di

	loop .nextROMByte

	neg al					; multiply sum by -1 (in other words: al = 256 - al)

	mov si,OPTION_ROM_CHECKSUM
	ds mov byte [si],al			; calculated 8-bit Option ROM checksum

	xor cx,cx
	inc cx					; last ROM byte is the recalculated checksum
	call PROGRAM_EEPROM_CODE_SEGMENT:PROGRAM_EEPROM_CODE_OFFSET

	pop es
	pop ds
%endif
	ret

; EEPROM programing (code patching) routine.
; Input:
;     CX - data size (in bytes)
;     DS:SI - pointer to any location within RAM
;     ES:DI - pointer to any location within EEPROM
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

	xor ah,ah				; assume SDP is not present

.writeEEPROM:
	ds mov byte al,[si]
	es cmp byte [di],al
	je .nextDataByte

	or ah,ah				; retest if SDP is present
	jz .writeData

.enableSDPWrites:
	es mov byte [1555h],0AAh		; this sequence is described
	es mov byte [0AAAh],55h			; in the ATMEL 28C64B datasheet
	es mov byte [1555h],0A0h		; at page 8 (REV. 0270H–12/99)

.writeData:
	es mov byte [di],al

	xor bx,bx				; wait cycle time counter (2 - 10 ms)

.writeCycleTime:
	es cmp byte al,[di]
	je .nextDataByte

	dec bx

	jnz .writeCycleTime

	or ah,ah				; retest if SDP is present
	jnz .exit				; UV-erasable EPROM might be present

	inc ah					; assume SDP is present

	jmp .enableSDPWrites

.nextDataByte:
	inc si
	inc di

	loop .writeEEPROM

.exit:
	sti

	pop bx

	retf

PROGRAM_EEPROM_CODE_SIZE			EQU	($ - programEEPROMCode)
