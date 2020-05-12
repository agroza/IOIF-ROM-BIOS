; ---------------------------------------------------------------------------
; - EEPROM Routines (eeprom.asm)                                            -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

; Reads all IDE Devices Parameters from EEPROM.
; Input:
;     none
; Output
;     none
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
readEEPROMData:
	; TODO : This is test data for Device 0 (Primary Master).

	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_TYPE_OFFSET],IDE_DEVICES_TYPE_USER
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_CYLINDERS_OFFSET],820
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_HEADS_OFFSET],6
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_SECTORS_OFFSET],17
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_LDZONE_OFFSET],820
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_WPCOMP_OFFSET],65535

	ret

; Writes all IDE Devices Parameters to EEPROM.
; Input:
;     none
; Output
;     none
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
writeEEPROMData:
	; TODO : Add code.

	ret
