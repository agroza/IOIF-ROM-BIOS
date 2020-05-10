; ---------------------------------------------------------------------------
; - I/O Interface ROM BIOS Messages (messages.inc)                          -
; - Integrant part of I/O Interface ROM BIOS                                -
; - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
; - All rights reserved.                                                    -
; ---------------------------------------------------------------------------
; - License: GNU General Public License v3.0                                -
; ---------------------------------------------------------------------------

section .text

sProgram			DB 'I/O Interface ROM BIOS  VER 0.1 REV. C',13,10,0
sCopyright			DB 'Copyright (C) 2020 Microprogramming TECHNIQUES',13,10,10,0
sBIOSDisabled			DB '16-bit CPU required. ROM BIOS disabled.',13,10,0
sPressDELKey			DB 'Press DEL to enter I/OIF SETUP...',13,10,10,0

sSetupESCExit			DB '[ESC] - Exit',0
sSetupUsage			DB '[ENTER] - Select  ',24,25,27,26,' - Move  PU/PD - Modify',0
sSetupExit			DB 'Exit?  (Y/n)',0

sDetectingIDE			DB 'Detecting IDE ',0
sIDEDevicePM			DB 'Primary Master   : ',0
sIDEDevicePS			DB 'Primary Slave    : ',0
sIDEDeviceSM			DB 'Secondary Master : ',0
sIDEDeviceSS			DB 'Secondary Slave  : ',0

sIDEDevices			DB 'IDE DEVICES',0
sIDEParameters			DB 'TYPE  CYLNS  HEADS  SECTS  WPCOMP  LDZONE  SIZE  MODE',0

sIDEDeviceTypeNone		DB 'NONE',0
sIDEDeviceTypeUser		DB 'USER',0
sIDEDeviceTypeAuto		DB 'AUTO',0

sIDEDeviceModeCHS		DB 'CHS',0

sIDEDeviceNA			DB 'N/A',0
sIDEDeviceModel			DB 'Model',0
sIDEDeviceSerial		DB 'Serial',0
sIDEDeviceRevision		DB 'Revision',0
sIDEDeviceGeneral		DB 'General',0
sIDEDeviceGeneralList		DB 'Fixed  Removable  Non-Magnetic',0
sIDEDeviceFeatures		DB 'Features',0
sIDEDeviceFeaturesList		DB 'LBA  DMA  I/ORDY Disableable',0

sMainMenuDefineParameters	DB 'DEFINE PARAMETERS',0
sMainMenuAutodetectAll		DB 'AUTODETECT ALL',0
sMainMenuDeviceInformation	DB 'DEVICE INFORMATION',0
sMainMenuExit			DB 'EXIT',0
sMainMenuSaveAndExit		DB 'SAVE & EXIT',0
