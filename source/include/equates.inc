; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS Equates (equates.inc)                            -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

; General Constants
; ---------------------------------------------------------------------------
ROMSTART				EQU	0000h
ROMSIZE					EQU	2000h
ROMBLOCKS				EQU	ROMSIZE / 512

; Keyboard Constants
; ---------------------------------------------------------------------------
KBD_UP					EQU	4800h
KBD_DOWN				EQU	5000h
KBD_LEFT				EQU	4B00h
KBD_RIGHT				EQU	4D00h
KBD_ENTER				EQU	1C0Dh
KBD_ESC					EQU	011Bh
KBD_DEL					EQU	5300h
KBD_N					EQU	'N'
KBD_Y					EQU	'Y'

; Color Constants
; ---------------------------------------------------------------------------
BLACK					EQU	00h
BLUE					EQU	01h
GREEN					EQU	02h
CYAN					EQU	03h
RED					EQU	04h
PURPLE					EQU	05h
YELLOW					EQU	06h
LIGHTGRAY				EQU	07h
GRAY					EQU	08h
LIGHTBLUE				EQU	09h
LIGHTGREEN				EQU	0Ah
LIGHTCYAN				EQU	0Bh
LIGHTRED				EQU	0Ch
LIGHTPURPLE				EQU	0Dh
LIGHTYELLOW				EQU	0Eh
WHITE					EQU	0Fh

; Video Constants
; ---------------------------------------------------------------------------
VIDEO_RAM_SEGMENT			EQU	0B800h
VIDEO_COLUMN_COUNT			EQU	80
VIDEO_ROW_COUNT				EQU	25

VIDEONORMAL				EQU	(BLACK << 4) + LIGHTGRAY
VIDEOHIGHLIGHT				EQU	(BLACK << 4) + WHITE
VIDEOERROR				EQU	(BLACK << 4) + RED

BIOS_TEXT_COLOR				EQU	(BLUE << 4) + WHITE
BIOS_SELECTED_COLOR			EQU	(RED << 4) + WHITE
BIOS_SELECTED_HIGHLIGHT_COLOR		EQU	(RED << 4) + YELLOW
BIOS_HIGHLIGHT_TEXT_COLOR		EQU	(BLUE << 4) + LIGHTCYAN
BIOS_QUESTION_TEXT_COLOR		EQU	(RED << 4) + WHITE

; IDE Device Parameters Text Offsets and Lengths
; ---------------------------------------------------------------------------
IDE_DEVICES_REGIONS_COUNT		EQU	8

IDE_DEVICE_TYPE_OFFSET			EQU	25
IDE_DEVICE_TYPE_LENGTH			EQU	6
IDE_DEVICE_CYLINDERS_OFFSET		EQU	32
IDE_DEVICE_CYLINDERS_LENGTH		EQU	7
IDE_DEVICE_HEADS_OFFSET			EQU	38
IDE_DEVICE_HEADS_LENGTH			EQU	7
IDE_DEVICE_SECTORS_OFFSET		EQU	45
IDE_DEVICE_SECTORS_LENGTH		EQU	7
IDE_DEVICE_WPCOMP_OFFSET 		EQU	53
IDE_DEVICE_WPCOMP_LENGTH		EQU	8
IDE_DEVICE_LDZONE_OFFSET		EQU	61
IDE_DEVICE_LDZONE_LENGTH		EQU	8
IDE_DEVICE_SIZE_OFFSET			EQU	68
IDE_DEVICE_SIZE_LENGTH			EQU	6
IDE_DEVICE_MODE_OFFSET			EQU	74
IDE_DEVICE_MODE_LENGTH			EQU	6

; IDE Master/Slave Identifiers
; ---------------------------------------------------------------------------
IDE_MASTER_DEVICE			EQU	00h
IDE_SLAVE_DEVICE			EQU	10h

; IDE Interface Base Addresses
; ---------------------------------------------------------------------------
PRIMARY_IDE_INTERFACE			EQU	01F0h	; 0x1F0h - 0x1F7h
PRIMARY_IDE_INTERFACE_CONTROL		EQU	03F0h	; 0x3F6h - 0x3F7h
SECONDARY_IDE_INTERFACE			EQU	0170h	; 0x170h - 0x177h
SECONDARY_IDE_INTERFACE_CONTROL		EQU	0370h	; 0x376h - 0x377h

; IDE Interface Registers
; ---------------------------------------------------------------------------
DATA_REGISTER				EQU	00h	; read/write
ERROR_REGISTER				EQU	01h	; read-only
WRITE_PRECOMP_REGISTER			EQU	01h	; write-only
SECTOR_COUNT_REGISTER			EQU	02h	; read/write
SECTOR_NUMBER_REGISTER			EQU	03h	; read/write
LOW_CYLINDER_REGISTER			EQU	04h	; read/write
HIGH_CYLINDER_REGISTER			EQU	05h	; read/write
SELECT_DRIVE_AND_HEAD_REGISTER		EQU	06h	; read/write
STATUS_REGISTER				EQU	07h	; read-only
COMMAND_REGISTER			EQU	07h	; write-only

ALTERNATE_STATUS_REGISTER		EQU	06h	; read-only
DEVICE_CONTROL_REGISTER			EQU	06h	; write-only
DEVICE_ADDRESS_REGISTER			EQU	07h	; not used

; IDE Status Register Bits
; ---------------------------------------------------------------------------
STATUS_REGISTER_BSY			EQU	1 << 7	; Busy
STATUS_REGISTER_DRDY			EQU	1 << 6	; Device Ready
STATUS_REGISTER_DF			EQU	1 << 5	; Device Fault
STATUS_REGISTER_DSC			EQU	1 << 4	; Device Seek Complete
STATUS_REGISTER_DRQ			EQU	1 << 3	; Data Request Ready
STATUS_REGISTER_CORR			EQU	1 << 2	; Corrected Data
STATUS_REGISTER_IDX			EQU	1 << 1	; Index
STATUS_REGISTER_ERR			EQU	1 << 0	; Error

; IDE/ATA Commands
; ---------------------------------------------------------------------------
ATA_IDENTIFY_DEVICE_COMMAND		EQU	0ECh
