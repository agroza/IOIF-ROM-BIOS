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

echo Assembling ROM #0 File...
.\bin\nasm.exe -l .\output\ioifrom0.lst -f bin .\source\ioifrom0.asm -o .\output\ioifrom0.bin

echo Calculating and Updating ROM #0 Checksum...
.\bin\romcksum.exe -o .\output\ioifrom0.bin