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

	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_CYLINDERS_OFFSET],820
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_HEADS_OFFSET],6
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_SECTORS_OFFSET],17
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_LDZONE_OFFSET],820
	mov word [IDE_DEVICES_DATA + IDE_DEVICES_DATA_WPCOMP_OFFSET],65535

	mov dh,IDE_DEVICES_REGION_PRIMARY_MASTER
	mov si,IDE_INTERFACES_DEVICE_0
	call drawParameters

	mov dh,IDE_DEVICES_REGION_PRIMARY_SLAVE
	mov si,IDE_INTERFACES_DEVICE_1
	call drawParameters

	mov dh,IDE_DEVICES_REGION_SECONDARY_MASTER
	mov si,IDE_INTERFACES_DEVICE_2
	call drawParameters

	mov dh,IDE_DEVICES_REGION_SECONDARY_SLAVE
	mov si,IDE_INTERFACES_DEVICE_3
	call drawParameters

	ret
