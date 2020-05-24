; ---------------------------------------------------------------------------
; - Interrupt Routines (interrupts.asm)                                     -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

; Sets the appropriate BIOS Disk Error Code and value of the Carry FLag.
; Input:
;     DL - drive
; Output:
;     AH - BIOS Disk Error Code
;     CF - clear = success
;          set = error
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
interrupt13hSetErrorAndCode:
	mov ah,BIOS_DISK_NO_ERROR_ON_LAST_OPERATION

	clc

	ret

; Hooks the original System BIOS Interrupt 13h ISR and installs the new one.
; Input:
;     none
; Output
;     none
; Affects:
;     none
; Preserves:
;     FLAGS
; ---------------------------------------------------------------------------
interrupt13hHook:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Handler.
; Input:
;     AH - interrupt service routine
;     DL - drive
; Output
;     none
; Affects:
;     BX
; Preserves:
;     FLAGS
; ---------------------------------------------------------------------------
interrupt13hHandler:
	pushf

	cmp dl,80h				; only 4 hard disk drives
	jb .otherDeviceOrNoService
	cmp dl,83h
	ja .otherDeviceOrNoService

.interrupt13hService:
	xor bh,bh				; ignore high byte
	mov bl,ah				; copy service memory address to bx
	shl bx,1				; multiply by word size

	cmp ah,15h
	ja .otherDeviceOrNoService

	cs call [bx + INT13H_SERVICE_BRANCH_TABLE]

	popf

	jmp .exit

.otherDeviceOrNoService:
	popf

	call interrupt13hNoService

.exit:
	; TODO : Replace ret with iret once the ISRs are ready to take over.

	ret
	;iret

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
interrupt13hService00h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 01h (Get Status of Last Drive Operation)
; Hardware: Floppy Disk Drive, Hard Disk Drive
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
interrupt13hService01h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 02h (Read Sectors From Drive)
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
interrupt13hService02h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 03h (Write Sectors To Drive)
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
interrupt13hService03h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 04h (Verify Sectors From Drive)
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
interrupt13hService04h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 08h (Read Drive Parameters)
; Hardware: Floppy Disk Drive, Hard Disk Drive
; Input:
;     DL - drive
; Output
;     CF - clear = success
;          set = error
;     AH - BIOS Disk Error Code
;     DH - logical last index of heads (heads - 1)
;     DL - number of hard disk drives on first interface
;     CH - logical last index of tracks / cylinders (cylinders - 1; bits 7-0 = cylinder)
;     CL - logical last index of sectors (bits 7,6 = bits 9,8 of cylinder; bits 5-0 = sector)
;     ES:DI - address of hard disk parameters table
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
interrupt13hService08h:
	pusha

	mov di,IDE_DEVICES_DATA

	es mov word cx,[di + IDE_DEVICES_DATA_CYLINDERS_OFFSET]
	es mov byte dh,[di + IDE_DEVICES_DATA_HEADS_OFFSET]
	es mov byte dl,[di + IDE_DEVICES_DATA_SECTORS_OFFSET]

	dec cx					; logical last index of tracks / cylinders (cylinders - 1)
	dec dh					; logical last index of heads (heads - 1)

	xchg ch,cl				; tracks / cylinders (cylinders - 1; bits 7-0 = cylinder)
	ror cl,2				; tracks / cylinders (bits 7,6 = bits 9,8 of cylinder)
	or cl,dl				; sectors (bits 5-0 = sector)

	call interrupt13hSetErrorAndCode

	call primaryInterfaceIDEDevicesCount

	popa

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 09h (Initialize Drive Controller)
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
interrupt13hService09h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 0Ch (Move Drive Head To Cylinder)
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
interrupt13hService0Ch:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 0Dh (Reset Disk Drives)
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
interrupt13hService0Dh:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 10h (Test Whether Drive Is Ready)
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
interrupt13hService10h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 11h (Recalibrate Drive)
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
interrupt13hService11h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 14h (Controller Diagnostics)
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
interrupt13hService14h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h Service 15h (Read Drive Type)
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
interrupt13hService15h:
	; TODO : Add code.

	ret

; I/O Interface ROM BIOS Interrupt 13h No Routine
; Hardware: Floppy Disk Drive, Hard Disk Drive
; Input:
;     DL - drive
; Output
;     none
; Affects:
;     none
; Preserves:
;     none
; ---------------------------------------------------------------------------
interrupt13hNoService:
	;int INTERRUPT_ORIGINAL_INT13H

	ret
