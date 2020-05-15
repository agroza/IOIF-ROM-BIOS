; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS Data (data.inc)                                  -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

	; IDE_PARAMETERS_REGIONS is a memory array, being structured as:
	;     Offset:  0 :  1 word  - IDE Device region Type offset
	;     Offset:  2 :  1 word  - IDE Device region Type length
	;     Offset:  4 :  1 word  - IDE Device region Cylinders offset
	;     Offset:  6 :  1 word  - IDE Device region Cylinders length
	;     Offset:  8 :  1 word  - IDE Device region Heads offset
	;     Offset: 10 :  1 word  - IDE Device region Heads length
	;     Offset: 12 :  1 word  - IDE Device region Sectors offset
	;     Offset: 14 :  1 word  - IDE Device region Sectors length
	;     Offset: 16 :  1 word  - IDE Device region Write Precompensation offset
	;     Offset: 18 :  1 word  - IDE Device region Write Precompensation length
	;     Offset: 20 :  1 word  - IDE Device region Landing Zone offset
	;     Offset: 22 :  1 word  - IDE Device region Landing Zone length
	IDE_PARAMETERS_REGIONS:
		DB	IDE_DEVICE_REGION_TYPE_OFFSET - 1, IDE_DEVICE_REGION_TYPE_LENGTH
		DB	IDE_DEVICE_REGION_CYLINDERS_OFFSET - 1, IDE_DEVICE_REGION_CYLINDERS_LENGTH
		DB	IDE_DEVICE_REGION_HEADS_OFFSET - 1, IDE_DEVICE_REGION_HEADS_LENGTH
		DB	IDE_DEVICE_REGION_SECTORS_OFFSET - 1, IDE_DEVICE_REGION_SECTORS_LENGTH
		DB	IDE_DEVICE_REGION_WPCOMP_OFFSET - 1, IDE_DEVICE_REGION_WPCOMP_LENGTH
		DB	IDE_DEVICE_REGION_LDZONE_OFFSET - 1, IDE_DEVICE_REGION_LDZONE_LENGTH
		DB	IDE_DEVICE_REGION_MODE_OFFSET - 2, IDE_DEVICE_REGION_MODE_LENGTH

	; IDE_PARAMETERS_CHS is a memory array, being structured as:
	;     Offset:  0 :  1 word  - IDE CHS Addressing Cylinders Minimum Value
	;     Offset:  2 :  1 word  - IDE CHS Addressing Cylinders Maximum Value
	;     Offset:  4 :  1 word  - IDE CHS Addressing Heads Minimum Value
	;     Offset:  6 :  1 word  - IDE CHS Addressing Heads Maximum Value
	;     Offset:  8 :  1 word  - IDE CHS Addressing Sectors Minimum Value
	;     Offset: 10 :  1 word  - IDE CHS Addressing Sectors Maximum Value
	;     Offset: 12 :  1 word  - IDE CHS Addressing Write Precompensation Minimum Value
	;     Offset: 14 :  1 word  - IDE CHS Addressing Write Precompensation Maximum Value
	;     Offset: 16 :  1 word  - IDE CHS Addressing Landing Zone Minimum Value
	;     Offset: 18 :  1 word  - IDE CHS Addressing Landing Zone Maximum Value
	IDE_PARAMETERS_CHS:
		DW	IDE_PARAMETER_CHS_CYLINDERS_MIN, IDE_PARAMETER_CHS_CYLINDERS_MAX
		DW	IDE_PARAMETER_CHS_HEADS_MIN, IDE_PARAMETER_CHS_HEADS_MAX
		DW	IDE_PARAMETER_CHS_SECTORS_MIN, IDE_PARAMETER_CHS_SECTORS_MAX
		DW	IDE_PARAMETER_CHS_WPCOMP_MIN, IDE_PARAMETER_CHS_WPCOMP_MAX
		DW	IDE_PARAMETER_CHS_LDZONE_MIN, IDE_PARAMETER_CHS_LDZONE_MAX

	; IDE_INTERFACES_DEVICE_X is a memory array, being structured as:
	;     Offset:  0 :  1 word  - IDE Interface Base Address
	;     Offset:  2 :  1 word  - IDE Interface Control Address
	;     Offset:  3 :  1 byte  - IDE Interface Device Master/Slave
	;     Offset:  4 :  1 byte  - IDE Interface Device ID
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

	; IDE_DEVICES_STORED_DATA is a ROM storage matrix, each row being structured as:
	;     Offset:  0 :  1 word  - cylinders
	;     Offset:  2 :  1 word  - heads
	;     Offset:  4 :  1 word  - sectors
	;     Offset:  6 :  1 word  - write precompensation
	;     Offset:  8 :  1 word  - landing zone
	;     Offset: 10 :  1 byte  - type
	IDE_DEVICES_STORED_DATA:
		TIMES (IDE_DEVICES_STORED_DATA_SIZE * IDE_DEVICES_DATA_DEVICES_COUNT) DB 00h

section .bss

	ATA_IDENTIFY_DEVICE_DATA	RESW	256

	; IDE_DEVICES_DATA is a memory matrix, each row being structured as:
	;     Offset:  0 :  1 word  - cylinders
	;     Offset:  2 :  1 word  - heads
	;     Offset:  4 :  1 word  - sectors
	;     Offset:  6 :  1 word  - write precompensation
	;     Offset:  8 :  1 word  - landing zone
	;     Offset: 10 :  1 byte  - type
	;     Offset: 11 : 21 bytes - serial, null-terminated string
	;     Offset: 32 :  1 byte  - unused, always 0
	;     Offset: 33 :  9 bytes - revision, null-terminates string
	;     Offset: 42 :  1 byte  - unused, always 0
	;     Offset: 43 : 41 bytes - model, null-terminated string
	;     Offset: 84 :  1 byte  - unused, always 0
	;     Offset: 85 :  1 byte  - general configuration register - high
	;     Offset: 86 :  1 byte  - general coniguration register - low
	;     Offset: 87 :  1 byte  - device features register
	IDE_DEVICES_DATA		RESB	IDE_DEVICES_DATA_SIZE * IDE_DEVICES_DATA_DEVICES_COUNT
