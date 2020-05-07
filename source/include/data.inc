; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS Data (data.inc)                                  -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

	IDE_PARAMETERS_REGIONS:
		DB	IDE_DEVICE_REGION_TYPE_OFFSET - 1, IDE_DEVICE_REGION_TYPE_LENGTH
		DB	IDE_DEVICE_REGION_CYLINDERS_OFFSET - 1, IDE_DEVICE_REGION_CYLINDERS_LENGTH
		DB	IDE_DEVICE_REGION_HEADS_OFFSET - 1, IDE_DEVICE_REGION_HEADS_LENGTH
		DB	IDE_DEVICE_REGION_SECTORS_OFFSET - 1, IDE_DEVICE_REGION_SECTORS_LENGTH
		DB	IDE_DEVICE_REGION_WPCOMP_OFFSET - 1, IDE_DEVICE_REGION_WPCOMP_LENGTH
		DB	IDE_DEVICE_REGION_LDZONE_OFFSET - 1, IDE_DEVICE_REGION_LDZONE_LENGTH
		DB	IDE_DEVICE_REGION_MODE_OFFSET - 2, IDE_DEVICE_REGION_MODE_LENGTH

section .bss

	IDE_DEVICE_DATA			RESW	256

	IDE_DEVICE_CYLINDERS		RESW	1
	IDE_DEVICE_HEADS		RESW	1
	IDE_DEVICE_SECTORS		RESW	1
	IDE_DEVICE_WPCOMP		RESW	1
	IDE_DEVICE_LDZONE		RESW	1

	IDE_DEVICE_MODEL		RESB	41
	IDE_DEVICE_SERIAL		RESB	21
	IDE_DEVICE_REVISION		RESB	9

	IDE_DEVICE_GENERAL_HIGH		RESB	1
	IDE_DEVICE_GENERAL_LOW		RESB	1
	IDE_DEVICE_FEATURES		RESB	1
