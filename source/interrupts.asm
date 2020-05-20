; ---------------------------------------------------------------------------
; - Interrupt Routines (interrupts.asm)                                     -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

; Hooks the original System BIOS Interrupt 13h ISR and installs the new one.
; Input:
;     DL - drive
; Output
;     none
; Affects:
;     none
; Preserves:
;     FLAGS
; ---------------------------------------------------------------------------
hookINT13h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Handler and Service Routines.
; Input:
;     DL - drive
; Output
;     none
; Affects:
;     none
; Preserves:
;     FLAGS
; ---------------------------------------------------------------------------
isrINT13h:
	pushf

	cmp dl,80h
	je .selectINT13Service

	popf

	int INTERRUPT_ORIGINAL_INT13h

	iret

.selectINT13Service:
	cmp ah,00h
	je .serviceINT13h00h
	cmp ah,01h
	je .serviceINT13h01h
	cmp ah,02h
	je .serviceINT13h02h
	cmp ah,03h
	je .serviceINT13h03h
	cmp ah,04h
	je .serviceINT13h04h
	cmp ah,08h
	je .serviceINT13h08h
	cmp ah,09h
	je .serviceINT13h09h
	cmp ah,0Ch
	je .serviceINT13h0Ch
	cmp ah,0Dh
	je .serviceINT13h0Dh
	cmp ah,10h
	je .serviceINT13h10h
	cmp ah,11h
	je .serviceINT13h11h
	cmp ah,14h
	je .serviceINT13h14h
	cmp ah,15h
	je .serviceINT13h15h

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 00h (Reset Disk System)
; Hardware: Floppy Disk Drive, Hard Disk Drive
; Input:
;     DL - drive
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h00h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 01h (Get Status of Last Drive Operation)
; Hardware: Floppy Disk Drive, Hard Disk Drive
; Input:
;     DL - drive
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h01h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 02h (Read Sectors From Drive)
; Hardware: Floppy Disk Drive, Hard Disk Drive
; Input:
;     AL - sectors to read count
;     CH - cylinder (bits 7-0 = cylinder)
;     CL - sector (bits 7,6 = bits 9,8 of cylinder; bits 5-0 = sector)
;     DH - head
;     DL - drive
;     ES:BX - buffer address pointer
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
;     AL - actual sectors read count
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h02h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 03h (Write Sectors To Drive)
; Hardware: Floppy Disk Drive, Hard Disk Drive
; Input:
;     AL - sectors to write count
;     CH - track / cylinder (bits 7-0 = cylinder)
;     CL - sector (bits 7,6 = bits 9,8 of cylinder; bits 5-0 = sector)
;     DH - head
;     DL - drive
;     ES:BX - buffer address pointer
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
;     AL - actual sectors written count
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h03h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 04h (Verify Sectors From Drive)
; Hardware: Floppy Disk Drive, Hard Disk Drive
; Input:
;     AL - sectors to verify count
;     CH - track / cylinder (bits 7-0 = cylinder)
;     CL - sector (bits 7,6 = bits 9,8 of cylinder; bits 5-0 = sector)
;     DH - head
;     DL - drive
;     ES:BX - buffer address pointer
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
;     AL - actual sectors verified count
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h04h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 08h (Read Drive Parameters)
; Hardware: Floppy Disk Drive, Hard Disk Drive
; Input:
;     DL - drive (bit 7 set = reset FD and HD)
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
;     DH - logical last index of heads (heads - 1)
;     DL - number of hard disk drives
;     CH - logical last index of track cylinders (cylinders - 1; bits 7-0 = cylinder)
;     CL - logical last index of sectors (bits 7,6 = bits 9,8 of cylinder; bits 5-0 = sector)
;     ES:DI - address of hard disk parameters table
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h08h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 09h (Initialize Drive Controller)
; Hardware: Hard Disk Drive
; Input:
;     DL - drive (bit 7 set = reset FD and HD)
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h09h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 0Ch (Move Drive Head To Cylinder)
; Hardware: Hard Disk Drive
; Input:
;     CH - track / cylinder (bits 7-0 = cylinder)
;     CL - sector (bits 7,6 = bits 9,8 of cylinder; bits 5-0 = sector)
;     DH - head
;     DL - drive
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h0Ch:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 0Dh (Reset Disk Drives)
; Hardware: Hard Disk Drive
; Input:
;     DL - drive
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h0Dh:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 10h (Test Whether Drive Is Ready)
; Hardware: Hard Disk Drive
; Input:
;     DL - drive
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h10h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 11h (Recalibrate Drive)
; Hardware: Hard Disk Drive
; Input:
;     DL - drive
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h11h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 14h (Controller Diagnostics)
; Hardware: Hard Disk Drive
; Input:
;     none
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h14h:
	; TODO : Add code.

	jmp .exit

; I/O Interface ROM BIOS Interrupt 13h Service Routine 15h (Read Drive Type)
; Hardware: Floppy Disk Drive, Hard Disk Drive
; Input:
;     DL - drive
; Output
;     CF - clear = success
;          set = error
;     AH - 00h = not installed
;          01h = floppy disk drive: can not detect disk change
;          02h = floppy disk drive: can detect disk change
;          03h = hard disk drive
;          otherwise, BIOS Disk Error Code
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
.serviceINT13h15h:
	; TODO : Add code.

	jmp .exit

.exit:
	popf

	iret
