# IOIF-ROM-BIOS
I/O Interface ROM BIOS

Notes:
* In order to compile the ROM binary file, you need NASM.EXE to be present in the .\bin subdirectory.
* At the moment this is a work in progress so the compiled ROM mirocode is pretty much useless.
* Technically, the I/O Interface ISA card could work with 8-bit machines. But by design, the IDE interfaces are hard-wired for 16-bit ISA slots. That is why I use an 8-bit CPU detection mechanism to enable or disable the ROM BIOS.
