; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS Data (data.inc)                                  -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

IDE_PARAMETERS_REGIONS		DB	IDE_DEVICE_TYPE_OFFSET - 1, IDE_DEVICE_TYPE_LENGTH
				DB	IDE_DEVICE_CYLINDERS_OFFSET - 1, IDE_DEVICE_CYLINDERS_LENGTH
				DB	IDE_DEVICE_HEADS_OFFSET - 1, IDE_DEVICE_HEADS_LENGTH
				DB	IDE_DEVICE_SECTORS_OFFSET - 1, IDE_DEVICE_SECTORS_LENGTH
				DB	IDE_DEVICE_WPCOMP_OFFSET - 1, IDE_DEVICE_WPCOMP_LENGTH
				DB	IDE_DEVICE_LDZONE_OFFSET - 1, IDE_DEVICE_LDZONE_LENGTH
				DB	IDE_DEVICE_MODE_OFFSET - 2, IDE_DEVICE_MODE_LENGTH
