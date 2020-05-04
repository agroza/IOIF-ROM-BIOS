@echo off

echo.
echo ---------------------------------------------------------------------------
echo - I/O Interface ROM BIOS Build Batch Script (_build.bat)                  -
echo - Integrant part of I/O Interface ROM BIOS                                -
echo - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
echo - All rights reserved.                                                    -
echo ---------------------------------------------------------------------------
echo - License: GNU General Public License v3.0                                -
echo ---------------------------------------------------------------------------
echo.

echo Counting Source Code Lines...
.\bin\sclc.exe .\source *.asm;*.inc

echo.
echo Assembling ROM #0 Binary File...
.\bin\nasm.exe -f bin .\source\ioifrom0.asm -o .\output\ioifrom0.bin

echo.
echo Calculating and Updating ROM #0 Checksum...
.\bin\romcksum.exe -o .\output\ioifrom0.bin
