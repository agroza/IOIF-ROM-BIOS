; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS Equates (equates.inc)                            -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

; ROM: General Constants
; ---------------------------------------------------------------------------
DOSSTART					EQU	100h
ROMSTART					EQU	0000h
ROMSIZE						EQU	2000h
ROMBLOCKS					EQU	ROMSIZE / 512

; System: Video BIOS Constants
; ---------------------------------------------------------------------------
VIDEO_RAM_SEGMENT				EQU	0B800h
VIDEO_COLUMN_COUNT				EQU	79
VIDEO_ROW_COUNT					EQU	24

; System: Keyboard Constants
; ---------------------------------------------------------------------------
KEYBOARD_UP					EQU	4800h
KEYBOARD_DOWN					EQU	5000h
KEYBOARD_LEFT					EQU	4B00h
KEYBOARD_RIGHT					EQU	4D00h
KEYBOARD_PAGE_UP				EQU	4900h
KEYBOARD_PAGE_DOWN				EQU	5100h
KEYBOARD_ENTER					EQU	1C0Dh
KEYBOARD_ESC					EQU	011Bh
KEYBOARD_DEL					EQU	5300h
KEYBOARD_BACKSPACE				EQU	0E08h
KEYBOARD_0					EQU	'0'
KEYBOARD_9					EQU	'9'
KEYBOARD_N					EQU	'N'
KEYBOARD_Y					EQU	'Y'

; Text-Mode User Interface: Color Constants
; ---------------------------------------------------------------------------
COLOR_BLACK					EQU	00h
COLOR_BLUE					EQU	01h
COLOR_GREEN					EQU	02h
COLOR_CYAN					EQU	03h
COLOR_RED					EQU	04h
COLOR_PURPLE					EQU	05h
COLOR_YELLOW					EQU	06h
COLOR_LIGHTGRAY					EQU	07h
COLOR_GRAY					EQU	08h
COLOR_LIGHTBLUE					EQU	09h
COLOR_LIGHTGREEN				EQU	0Ah
COLOR_LIGHTCYAN					EQU	0Bh
COLOR_LIGHTRED					EQU	0Ch
COLOR_LIGHTPURPLE				EQU	0Dh
COLOR_LIGHTYELLOW				EQU	0Eh
COLOR_WHITE					EQU	0Fh

ATTRIBUTE_BLINK					EQU	1 << 7

; Text-Mode User Interface: Pre-defined Color Constants
; ---------------------------------------------------------------------------
NORMAL_TEXT_COLOR				EQU	(COLOR_BLACK << 4) + COLOR_LIGHTGRAY
HIGHLIGHT_TEXT_COLOR				EQU	(COLOR_BLACK << 4) + COLOR_WHITE

BIOS_TEXT_COLOR					EQU	(COLOR_BLUE << 4) + COLOR_WHITE
BIOS_SELECTED_COLOR				EQU	(COLOR_RED << 4) + COLOR_WHITE
BIOS_SELECTED_HIGHLIGHT_COLOR			EQU	(COLOR_RED << 4) + COLOR_LIGHTYELLOW + ATTRIBUTE_BLINK
BIOS_HIGHLIGHT_TEXT_COLOR			EQU	(COLOR_BLUE << 4) + COLOR_LIGHTCYAN

IDE_FEATURE_ABSENT				EQU	(COLOR_BLUE << 4) + COLOR_LIGHTRED
IDE_FEATURE_PRESENT				EQU	(COLOR_BLUE << 4) + COLOR_LIGHTGREEN
IDE_FEATURE_POSSIBLE				EQU	(COLOR_BLUE << 4) + COLOR_LIGHTYELLOW

; Text-Mode User Interface: Messages (Strings) Constants
; ---------------------------------------------------------------------------
MSG_IDE_DEVICE_LENGTH				EQU	20
MSG_IDE_DEVICE_TYPE_LENGTH			EQU	5

; Text-Mode User Interface: IDE Devices Regions Constants
; ---------------------------------------------------------------------------
IDE_DEVICES_REGION_OFFSET			EQU	2
IDE_DEVICES_REGION_LENGTH			EQU	78

IDE_DEVICES_REGION_TOP				EQU	6

IDE_DEVICES_REGION_PRIMARY_MASTER		EQU	IDE_DEVICES_REGION_TOP
IDE_DEVICES_REGION_PRIMARY_SLAVE		EQU	IDE_DEVICES_REGION_PRIMARY_MASTER + 1
IDE_DEVICES_REGION_SECONDARY_MASTER		EQU	IDE_DEVICES_REGION_PRIMARY_SLAVE + 1
IDE_DEVICES_REGION_SECONDARY_SLAVE		EQU	IDE_DEVICES_REGION_SECONDARY_MASTER + 1

IDE_DEVICES_REGION_BOTTOM			EQU	IDE_DEVICES_REGION_SECONDARY_SLAVE

; Text-Mode User Interface: IDE Device Region Constants
; ---------------------------------------------------------------------------
IDE_DEVICE_REGION_WIDTH				EQU	53

IDE_DEVICE_REGION_COUNT				EQU	7

IDE_DEVICE_REGION_TYPE_OFFSET			EQU	25
IDE_DEVICE_REGION_TYPE_LENGTH			EQU	6
IDE_DEVICE_REGION_CYLINDERS_OFFSET		EQU	31
IDE_DEVICE_REGION_CYLINDERS_LENGTH		EQU	7
IDE_DEVICE_REGION_HEADS_OFFSET			EQU	38
IDE_DEVICE_REGION_HEADS_LENGTH			EQU	7
IDE_DEVICE_REGION_SECTORS_OFFSET		EQU	45
IDE_DEVICE_REGION_SECTORS_LENGTH		EQU	7
IDE_DEVICE_REGION_WPCOMP_OFFSET 		EQU	52
IDE_DEVICE_REGION_WPCOMP_LENGTH			EQU	8
IDE_DEVICE_REGION_LDZONE_OFFSET			EQU	60
IDE_DEVICE_REGION_LDZONE_LENGTH			EQU	8
IDE_DEVICE_REGION_SIZE_OFFSET			EQU	68
IDE_DEVICE_REGION_SIZE_LENGTH			EQU	6
IDE_DEVICE_REGION_MODE_OFFSET			EQU	75
IDE_DEVICE_REGION_MODE_LENGTH			EQU	6

IDE_DEVICE_REGION_EDIT_DIGIT_COUNT		EQU	5

; Text-Mode User Interface: Main Menu Regions Constants
; ---------------------------------------------------------------------------
MAIN_MENU_REGION_OFFSET				EQU	2
MAIN_MENU_REGION_LENGTH				EQU	20

MAIN_MENU_REGION_TOP				EQU	11

MAIN_MENU_DEFINE_PARAMETERS			EQU	MAIN_MENU_REGION_TOP
MAIN_MENU_AUTODETECT_ALL			EQU	MAIN_MENU_DEFINE_PARAMETERS + 1
MAIN_MENU_DEVICE_INFORMATION			EQU	MAIN_MENU_AUTODETECT_ALL + 1
MAIN_MENU_EXIT					EQU	MAIN_MENU_DEVICE_INFORMATION + 1
MAIN_MENU_SAVE_AND_EXIT				EQU	MAIN_MENU_EXIT + 1

MAIN_MENU_REGION_BOTTOM				EQU	MAIN_MENU_SAVE_AND_EXIT

; Text-Mode User Interface: IDE Device Information Constants
; ---------------------------------------------------------------------------
IDE_DEVICE_INFO_TOP				EQU	11

IDE_DEVICE_INFO_KEY_OFFSET			EQU	25
IDE_DEVICE_INFO_VALUE_OFFSET			EQU	35

IDE_DEVICE_GENERAL_FIXED_OFFSET			EQU	IDE_DEVICE_INFO_VALUE_OFFSET
IDE_DEVICE_GENERAL_FIXED_LENGTH			EQU	5
IDE_DEVICE_GENERAL_REMOVABLE_OFFSET		EQU	7
IDE_DEVICE_GENERAL_REMOVABLE_LENGTH		EQU	9
IDE_DEVICE_GENERAL_NON_MAGNETIC_OFFSET		EQU	11
IDE_DEVICE_GENERAL_NON_MAGNETIC_LENGTH		EQU	12

IDE_DEVICE_FEATURE_LBA_OFFSET			EQU	IDE_DEVICE_INFO_VALUE_OFFSET
IDE_DEVICE_FEATURE_LBA_LENGTH			EQU	3
IDE_DEVICE_FEATURE_DMA_OFFSET			EQU	5
IDE_DEVICE_FEATURE_DMA_LENGTH			EQU	3
IDE_DEVICE_FEATURE_IORDY_OFFSET			EQU	5
IDE_DEVICE_FEATURE_IORDY_LENGTH			EQU	6
IDE_DEVICE_FEATURE_IORDY_DISABLE_OFFSET		EQU	7
IDE_DEVICE_FEATURE_IORDY_DISABLE_LENGTH		EQU	11

; Text-Mode User Interface: Other Text Offsets and General Constants
; ---------------------------------------------------------------------------
SETUP_USAGE_TOP					EQU	23
SETUP_USAGE_OFFSET				EQU	16

; ATA Standard: IDE Interface Registers
; ---------------------------------------------------------------------------
DATA_REGISTER					EQU	00h	; read/write
ERROR_REGISTER					EQU	01h	; read-only
WRITE_PRECOMP_REGISTER				EQU	01h	; write-only
SECTOR_COUNT_REGISTER				EQU	02h	; read/write
SECTOR_NUMBER_REGISTER				EQU	03h	; read/write
LOW_CYLINDER_REGISTER				EQU	04h	; read/write
HIGH_CYLINDER_REGISTER				EQU	05h	; read/write
SELECT_DRIVE_AND_HEAD_REGISTER			EQU	06h	; read/write
STATUS_REGISTER					EQU	07h	; read-only
COMMAND_REGISTER				EQU	07h	; write-only

ALTERNATE_STATUS_REGISTER			EQU	06h	; read-only
DEVICE_CONTROL_REGISTER				EQU	06h	; write-only
DEVICE_ADDRESS_REGISTER				EQU	07h	; not used

; ATA Standard: IDE Error Register Flags
; ---------------------------------------------------------------------------
ERROR_REGISTER_BBK				EQU	1 << 7	; bad block detected
ERROR_REGISTER_UNC				EQU	1 << 6	; uncorrectable data error
ERROR_REGISTER_MC				EQU	1 << 5	; media changed
ERROR_REGISTER_IDNF				EQU	1 << 4	; ID not found
ERROR_REGISTER_MCR				EQU	1 << 3	; media change request
ERROR_REGISTER_ABRT				EQU	1 << 2	; command aborted
ERROR_REGISTER_TK0NF				EQU	1 << 1	; track 0 not found
ERROR_REGISTER_AMNF				EQU	1 << 0	; address mark not found

; ATA Standard: IDE Status Register Flags
; ---------------------------------------------------------------------------
STATUS_REGISTER_BSY				EQU	1 << 7	; busy
STATUS_REGISTER_DRDY				EQU	1 << 6	; device ready
STATUS_REGISTER_DF				EQU	1 << 5	; device fault
STATUS_REGISTER_DSC				EQU	1 << 4	; device seek complete
STATUS_REGISTER_DRQ				EQU	1 << 3	; data request ready
STATUS_REGISTER_CORR				EQU	1 << 2	; corrected data
STATUS_REGISTER_IDX				EQU	1 << 1	; index
STATUS_REGISTER_ERR				EQU	1 << 0	; error

; ATA Standard: ATA Commands
; ---------------------------------------------------------------------------
ATA_IDENTIFY_DEVICE_COMMAND			EQU	0ECh

; ATA Standard: ATA Identify Device Command Offsets
; ---------------------------------------------------------------------------
ATA_IDENTIFY_DEVICE_GENERAL_OFFSET		EQU	0
ATA_IDENTIFY_DEVICE_CYLINDERS_OFFSET		EQU	2
ATA_IDENTIFY_DEVICE_HEADS_OFFSET		EQU	6
ATA_IDENTIFY_DEVICE_SECTORS_OFFSET		EQU	12
ATA_IDENTIFY_DEVICE_SERIAL_OFFSET		EQU	20
ATA_IDENTIFY_DEVICE_REVISION_OFFSET		EQU	46
ATA_IDENTIFY_DEVICE_MODEL_OFFSET		EQU	54
ATA_IDENTIFY_DEVICE_FEATURES_OFFSET		EQU	98

IDE_DEVICES_DATA_SERIAL_LENGTH			EQU	10	; words
IDE_DEVICES_DATA_REVISION_LENGTH		EQU	4	; words
IDE_DEVICES_DATA_MODEL_LENGTH			EQU	20	; words

; ATA Standard: ATA Identify Device Command Feature Flags
; ---------------------------------------------------------------------------
ATA_ID_DEV_GENERAL_REMOVABLE_FLAG		EQU	1 << 7
ATA_ID_DEV_GENERAL_FIXED_FLAG			EQU	1 << 6
ATA_ID_DEV_GENERAL_NON_MAGNETIC_FLAG		EQU	1 << 7

ATA_ID_DEV_FEATURE_IORDY_FLAG			EQU	1 << 3
ATA_ID_DEV_FEATURE_IORDY_DISABLE_FLAG		EQU	1 << 2
ATA_ID_DEV_FEATURE_LBA_FLAG			EQU	1 << 1
ATA_ID_DEV_FEATURE_DMA_FLAG			EQU	1 << 0

; I/OIF ROM BIOS: IDE Interface Base Addresses
; ---------------------------------------------------------------------------
PRIMARY_IDE_INTERFACE				EQU	01F0h	; 0x1F0h - 0x1F7h
PRIMARY_IDE_INTERFACE_CONTROL			EQU	03F0h	; 0x3F6h - 0x3F7h
SECONDARY_IDE_INTERFACE				EQU	0170h	; 0x170h - 0x177h
SECONDARY_IDE_INTERFACE_CONTROL			EQU	0370h	; 0x376h - 0x377h

IDE_INTERFACES_SIZE				EQU	6	; bytes

IDE_INTERFACE_BASE_ADDRESS			EQU	0	; word
IDE_INTERFACE_CONTROL_ADDRESS			EQU	2	; word
IDE_INTERFACE_DEVICE				EQU	4	; word (Master/Slave|ID)

; I/OIF ROM BIOS: IDE Master/Slave Identifiers
; ---------------------------------------------------------------------------
IDE_MASTER_DEVICE				EQU	00h
IDE_SLAVE_DEVICE				EQU	10h

; I/OIF ROM BIOS: IDE Devices Data Matrix Equates and Offsets
; ---------------------------------------------------------------------------
IDE_DEVICES_PRIMARY_MASTER_ID			EQU	0
IDE_DEVICES_PRIMARY_SLAVE_ID			EQU	1
IDE_DEVICES_SECONDARY_MASTER_ID			EQU	2
IDE_DEVICES_SECONDARY_SLAVE_ID			EQU	3

IDE_DEVICES_TYPE_NONE				EQU	0
IDE_DEVICES_TYPE_USER				EQU	1
IDE_DEVICES_TYPE_AUTO				EQU	2

IDE_DEVICES_DATA_SIZE				EQU	88	; bytes
IDE_DEVICES_DATA_DEVICES_COUNT			EQU	4

IDE_DEVICES_DATA_CYLINDERS_OFFSET		EQU	0
IDE_DEVICES_DATA_HEADS_OFFSET			EQU	2
IDE_DEVICES_DATA_SECTORS_OFFSET			EQU	4
IDE_DEVICES_DATA_WPCOMP_OFFSET			EQU	6
IDE_DEVICES_DATA_LDZONE_OFFSET			EQU	8
IDE_DEVICES_DATA_TYPE_OFFSET			EQU	10
IDE_DEVICES_DATA_SERIAL_OFFSET			EQU	11
IDE_DEVICES_DATA_REVISION_OFFSET		EQU	33
IDE_DEVICES_DATA_MODEL_OFFSET			EQU	43
IDE_DEVICES_DATA_GENERAL_HIGH_OFFSET		EQU	85
IDE_DEVICES_DATA_GENERAL_LOW_OFFSET		EQU	86
IDE_DEVICES_DATA_FEATURES_OFFSET		EQU	87

; I/OIF ROM BIOS: IDE Devices Parameters Restrictions
; ---------------------------------------------------------------------------
IDE_PARAMETER_RESTRICTION_MIN_OFFSET		EQU	0
IDE_PARAMETER_RESTRICTION_MAX_OFFSET		EQU	2

IDE_PARAMETER_CHS_CYLINDERS_MIN			EQU	0
IDE_PARAMETER_CHS_CYLINDERS_MAX			EQU	1023
IDE_PARAMETER_CHS_HEADS_MIN			EQU	0
IDE_PARAMETER_CHS_HEADS_MAX			EQU	255
IDE_PARAMETER_CHS_SECTORS_MIN			EQU	1
IDE_PARAMETER_CHS_SECTORS_MAX			EQU	63
IDE_PARAMETER_CHS_WPCOMP_MIN			EQU	1
IDE_PARAMETER_CHS_WPCOMP_MAX			EQU	65535
IDE_PARAMETER_CHS_LDZONE_MIN			EQU	1
IDE_PARAMETER_CHS_LDZONE_MAX			EQU	1023