; ---------------------------------------------------------------------------
; - CMOS Routines (cmos.asm)                                                -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

; Reads all IDE Devices Parameters from CMOS.
; Input:
;   none
; Output
;   none
; ---------------------------------------------------------------------------
readCMOSData:
	; TODO : Replace this test data with real data.

	mov word [IDE_DEVICE_CYLINDERS],820
	mov word [IDE_DEVICE_HEADS],6
	mov word [IDE_DEVICE_SECTORS],17
	mov word [IDE_DEVICE_LDZONE],820
	mov word [IDE_DEVICE_WPCOMP],65535

	ret