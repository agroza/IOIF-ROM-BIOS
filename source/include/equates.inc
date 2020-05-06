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
DOSSTART				EQU	100h
ROMSTART				EQU	0000h
ROMSIZE					EQU	2000h
ROMBLOCKS				EQU	ROMSIZE / 512

WPCOMP_VALUE				EQU	65535

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

BLINK					EQU	1 << 7

NORMAL_TEXT_COLOR			EQU	(BLACK << 4) + LIGHTGRAY
HIGHLIGHT_TEXT_COLOR			EQU	(BLACK << 4) + WHITE

BIOS_TEXT_COLOR				EQU	(BLUE << 4) + WHITE
BIOS_SELECTED_COLOR			EQU	(RED << 4) + WHITE
BIOS_SELECTED_HIGHLIGHT_COLOR		EQU	(RED << 4) + LIGHTYELLOW + BLINK
BIOS_HIGHLIGHT_TEXT_COLOR		EQU	(BLUE << 4) + LIGHTCYAN

IDE_FEATURE_ABSENT			EQU	(BLUE << 4) + LIGHTRED
IDE_FEATURE_PRESENT			EQU	(BLUE << 4) + LIGHTGREEN
IDE_FEATURE_POSSIBLE			EQU	(BLUE << 4) + LIGHTYELLOW

; Video Constants
; ---------------------------------------------------------------------------
VIDEO_RAM_SEGMENT			EQU	0B800h
VIDEO_COLUMN_COUNT			EQU	80
VIDEO_ROW_COUNT				EQU	25

; Text Offsets and Lengths in the Text-Mode User Interface
; ---------------------------------------------------------------------------
IDE_DEVICE_REGION_WIDTH			EQU	53

IDE_DEVICE_REGION_COUNT			EQU	7

IDE_DEVICE_REGION_TYPE_OFFSET		EQU	25
IDE_DEVICE_REGION_TYPE_LENGTH		EQU	6
IDE_DEVICE_REGION_CYLINDERS_OFFSET	EQU	31
IDE_DEVICE_REGION_CYLINDERS_LENGTH	EQU	7
IDE_DEVICE_REGION_HEADS_OFFSET		EQU	38
IDE_DEVICE_REGION_HEADS_LENGTH		EQU	7
IDE_DEVICE_REGION_SECTORS_OFFSET	EQU	45
IDE_DEVICE_REGION_SECTORS_LENGTH	EQU	7
IDE_DEVICE_REGION_WPCOMP_OFFSET 	EQU	52
IDE_DEVICE_REGION_WPCOMP_LENGTH		EQU	8
IDE_DEVICE_REGION_LDZONE_OFFSET		EQU	60
IDE_DEVICE_REGION_LDZONE_LENGTH		EQU	8
IDE_DEVICE_REGION_SIZE_OFFSET		EQU	68
IDE_DEVICE_REGION_SIZE_LENGTH		EQU	6
IDE_DEVICE_REGION_MODE_OFFSET		EQU	75
IDE_DEVICE_REGION_MODE_LENGTH		EQU	6

IDE_DEVICES_REGION_OFFSET		EQU	2
IDE_DEVICES_REGION_LENGTH		EQU	78

IDE_DEVICES_REGION_TOP			EQU	6

IDE_DEVICES_REGION_PRIMARY_MASTER	EQU	IDE_DEVICES_REGION_TOP
IDE_DEVICES_REGION_PRIMARY_SLAVE	EQU	IDE_DEVICES_REGION_PRIMARY_MASTER + 1
IDE_DEVICES_REGION_SECONDARY_MASTER	EQU	IDE_DEVICES_REGION_PRIMARY_SLAVE + 1
IDE_DEVICES_REGION_SECONDARY_SLAVE	EQU	IDE_DEVICES_REGION_SECONDARY_MASTER + 1

IDE_DEVICES_REGION_BOTTOM		EQU	IDE_DEVICES_REGION_SECONDARY_SLAVE

MAIN_MENU_REGION_OFFSET			EQU	2
MAIN_MENU_REGION_LENGTH			EQU	20

MAIN_MENU_REGION_TOP			EQU	11

MAIN_MENU_EDIT_PARAMETERS		EQU	MAIN_MENU_REGION_TOP
MAIN_MENU_AUTODETECT_ALL		EQU	MAIN_MENU_EDIT_PARAMETERS + 1
MAIN_MENU_DEVICE_INFORMATION		EQU	MAIN_MENU_AUTODETECT_ALL + 1
MAIN_MENU_EXIT				EQU	MAIN_MENU_DEVICE_INFORMATION + 1
MAIN_MENU_SAVE_AND_EXIT			EQU	MAIN_MENU_EXIT + 1

MAIN_MENU_REGION_BOTTOM			EQU	MAIN_MENU_SAVE_AND_EXIT

IDE_DEVICE_INFO_TOP			EQU	11

IDE_DEVICE_INFO_KEY_OFFSET		EQU	25
IDE_DEVICE_INFO_VALUE_OFFSET		EQU	35

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

; IDE Error Register Bits
ERROR_REGISTER_BBK			EQU	1 << 7	; bad block detected
ERROR_REGISTER_UNC			EQU	1 << 6	; uncorrectable data error
ERROR_REGISTER_MC			EQU	1 << 5	; media changed
ERROR_REGISTER_IDNF			EQU	1 << 4	; ID not found
ERROR_REGISTER_MCR			EQU	1 << 3	; media change request
ERROR_REGISTER_ABRT			EQU	1 << 2	; command aborted
ERROR_REGISTER_TK0NF			EQU	1 << 1	; track 0 not found
ERROR_REGISTER_AMNF			EQU	1 << 0	; address mark not found

; IDE Status Register Bits
; ---------------------------------------------------------------------------
STATUS_REGISTER_BSY			EQU	1 << 7	; busy
STATUS_REGISTER_DRDY			EQU	1 << 6	; device ready
STATUS_REGISTER_DF			EQU	1 << 5	; device fault
STATUS_REGISTER_DSC			EQU	1 << 4	; device seek complete
STATUS_REGISTER_DRQ			EQU	1 << 3	; data request ready
STATUS_REGISTER_CORR			EQU	1 << 2	; corrected data
STATUS_REGISTER_IDX			EQU	1 << 1	; index
STATUS_REGISTER_ERR			EQU	1 << 0	; error

; IDE/ATA Commands
; ---------------------------------------------------------------------------
ATA_IDENTIFY_DEVICE_COMMAND		EQU	0ECh
