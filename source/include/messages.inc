; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS (MESSAGES.INC)                                   -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

sProgram           db 'I/O Interface ROM BIOS  VER 0.1 REV. A',13,10,0
sCopyright         db 'Copyright (C) 2020 Microprogramming TECHNIQUES',13,10,10,0
sPressDELKey       db 'Press DEL to enter I/OIF SETUP...',13,10,10,0

sAutodetectIDE     db 'Autodetecting IDE ',0
sAutodetectPM      db 'Primary Master   : ',0
sAutodetectPS      db 'Primary Slave    : ',0
sAutodetectSM      db 'Secondary Master : ',0
sAutodetectSS      db 'Secondary Slave  : ',0
sAutodetectNone    db 'NONE',13,10,0