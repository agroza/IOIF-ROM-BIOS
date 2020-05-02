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
KBD_ENTER				EQU	13
KBD_ESC					EQU	27
KBD_DEL					EQU	5300h

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
BIOS_HIGHLIGHT_TEXT_COLOR		EQU	(BLUE << 4) + LIGHTCYAN
BIOS_QUESTION_TEXT_COLOR		EQU	(RED << 4) + WHITE