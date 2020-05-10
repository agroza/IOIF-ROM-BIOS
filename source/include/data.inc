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

	IDE_INTERFACES_DEVICE_0:
		DW	PRIMARY_IDE_INTERFACE, PRIMARY_IDE_INTERFACE_CONTROL
		DB	IDE_MASTER_DEVICE, IDE_DEVICES_PRIMARY_MASTER_ID

	IDE_INTERFACES_DEVICE_1:
		DW	PRIMARY_IDE_INTERFACE, PRIMARY_IDE_INTERFACE_CONTROL
		DB	IDE_SLAVE_DEVICE, IDE_DEVICES_PRIMARY_SLAVE_ID

	IDE_INTERFACES_DEVICE_2:
		DW	SECONDARY_IDE_INTERFACE, SECONDARY_IDE_INTERFACE_CONTROL
		DB	IDE_MASTER_DEVICE, IDE_DEVICES_SECONDARY_MASTER_ID

	IDE_INTERFACES_DEVICE_3:
		DW	SECONDARY_IDE_INTERFACE, SECONDARY_IDE_INTERFACE_CONTROL
		DB	IDE_SLAVE_DEVICE, IDE_DEVICES_SECONDARY_SLAVE_ID

	; IDE_INTERFACES_DEVICE_X is a memory array, being structured as:
	;     Offset:  0 :  1 word  - IDE Interface Base Address
	;     Offset:  2 :  1 word  - IDE Interface Control Address
	;     Offset:  3 :  1 byte  - IDE Interface Device Master/Slave
	;     Offset:  4 :  1 byte  - IDE Interface Device ID

section .bss

	ATA_IDENTIFY_DEVICE_DATA	RESW	256

	IDE_DEVICES_DATA		RESB	IDE_DEVICES_DATA_SIZE * IDE_DEVICES_DATA_DEVICES_COUNT

	; IDE_DEVICES_DATA is a memory matrix, each row being structured as:
	;     Offset:  0 :  1 word  - cylinders
	;     Offset:  2 :  1 word  - heads
	;     Offset:  4 :  1 word  - sectors
	;     Offset:  6 :  1 word  - write precompensation
	;     Offset:  8 :  1 word  - landing zone
	;     Offset: 10 : 21 bytes - serial, null-terminated string
	;     Offset: 31 :  1 byte  - unused, always 0
	;     Offset: 32 :  9 bytes - revision, null-terminates string
	;     Offset: 41 :  1 byte  - unused, always 0
	;     Offset: 42 : 41 bytes - model, null-terminated string
	;     Offset: 83 :  1 byte  - unused, always 0
	;     Offset: 84 :  1 byte  - general configuration register - high
	;     Offset: 85 :  1 byte  - general coniguration register - low
	;     Offset: 86 :  1 byte  - device features register
