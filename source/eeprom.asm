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
	; TODO : Remove Test Data when it is not needed anymore.

%ifdef USETESTDATA
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_USER
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_CYLINDERS_OFFSET],820
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_HEADS_OFFSET],6
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_SECTORS_OFFSET],17
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_LDZONE_OFFSET],820
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_WPCOMP_OFFSET],65535
%else
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

%endif
	ret

; Writes all IDE Devices parameters to EEPROM.
; Input:
;     none
; Output:
;     none
; Affects:
;     CX, SI, DI
; Preserves:
;     none
; ---------------------------------------------------------------------------
writeEEPROMData:
	; TODO : Implement EEPROM writing functionality.

%ifdef EEPROMWRITE
	mov si,IDE_DEVICES_DATA
	mov di,IDE_DEVICES_STORED_DATA
	mov cx,IDE_DEVICES_STORED_DATA_SIZE; * IDE_DEVICES_DATA_DEVICES_COUNT
	call programEEPROMCode

	; TODO : Currently the programEEPROMCode routine writes directly in memory.
	; It should write to the ROM IC instead.
%endif

	ret

; EEPROM programing (code patching) routine.
; Input:
;     CX - data size (in bytes)
;     SI - pointer to IDE_DEVICES_DATA in memory
;     DI - pointer to IDE_DEVICES_STORED_DATA in EEPROM
; Output:
;     CX - 0 = success, non-zero = fail
;     AL - 0 = assume SDP is not present, 1 = assume SDP is present
; Affects:
;     FLAGS, AH, BX, CX, DX, SI, DI
; Preserves:
;     none
; ---------------------------------------------------------------------------
programEEPROMCode:
	cli

	cld

	xor al,al				; assume SDP is not present

.writeEEPROM:
	mov byte ah,[si]
	cmp byte [di],ah
	je .nextByte

	or al,al				; retest if SDP is present
	jz .writeData

.enableSDPWrites:
	mov byte [es:1555h],0AAh		; this sequence is described
	mov byte [es:0AAAh],55h			; in the ATMEL 28C64B datasheet
	mov byte [es:1555h],0A0h		; at page 8 (REV. 0270H–12/99)

.writeData:
	mov byte [di],ah

	xor bx,bx				; wait cycle time counter (2 - 10 ms)

.writeCycleTime:
	cmp byte [di],ah
	je .nextByte
	dec bx
	jnz .writeCycleTime

	or al,al				; retest if SDP is present
	jnz .exit

	inc al					; assume SDP is present
	jmp .enableSDPWrites

.nextByte:
	inc si
	inc di

	loop .writeEEPROM

.exit:
	sti

	ret

PROGRAM_EEPROM_CODE_SIZE			EQU	($ - programEEPROMCode)
