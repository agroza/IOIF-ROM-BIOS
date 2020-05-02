; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS (messages.inc)                                   -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

sProgram					DB 'I/O Interface ROM BIOS  VER 0.1 REV. A',13,10,0
sCopyright					DB 'Copyright (C) 2020 Microprogramming TECHNIQUES',13,10,10,0
sBIOSDisabled				DB '16-bit CPU required. ROM BIOS disabled.',13,10,0
sPressDELKey				DB 'Press DEL to enter I/OIF SETUP...',13,10,10,0

sAutodetectIDE				DB 'Detecting IDE ',0
sAutodetectPM				DB 'Primary Master   : ',0
sAutodetectPS				DB 'Primary Slave    : ',0
sAutodetectSM				DB 'Secondary Master : ',0
sAutodetectSS				DB 'Secondary Slave  : ',0
sAutodetectNone				DB 'NONE',0
sAutodetectError			DB 'ERROR',0
sAutodetectFault			DB 'DEVICE FAULT',0