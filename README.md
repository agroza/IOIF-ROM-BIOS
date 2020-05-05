# IOIF-ROM-BIOS
I/O Interface ROM BIOS

## Notes:
* At the moment this is a work in progress so the compiled ROM mirocode is pretty much useless.
* In order to compile the ROM binary file, you need ```nasm.exe``` and ```romcksum.exe``` to be present in the .\bin subdirectory.
* Optionally you also need ```sclc.exe``` in the .\bin subdirectory.
* Build the project by launching ```_build.bat```.
* The compiled ROM file will be generated in the .\output subdirectory.

### Coding Conventions:
* Technically, the I/O Interface ISA card could work with 8-bit machines. But by design, the IDE interfaces are hard-wired for 16-bit ISA slots. That is why I use an 8-bit CPU detection mechanism to enable or disable the ROM BIOS.
* Given the consideration above, I tend to use the 80286 instruction set rather than 8086 one.

### Toolchain:
1. Source Code Lines Counter (totally optional but helps me get an idea of how much I've worked on this project)
2. Netwide Assembler (I am using NASM version 2.14.02)
3. ROM Checksum Calculator

Besides NASM, I have uploaded the other executable files in the .\bin subdirectory.
Needless to say that all of these programs require Windows to run.

### Testing Environment:
* I am performing most of the superficial tests using QEMU. But I am having real difficulties identifying hard disks in the emulator.
* The real tests are performed on real hardware. The machine is equipped with an 80386DX processor running at 33MHz. Also it has a LAN card, and dual Compact Flash cards in master/slave configuration on the Primary IDE controller.
* Testing is basically done in no time since I have written a batch script that assembles the ROM in such way that it can be executed directly from MS-DOS. This script also copies the compiled ROM file to a network share drive which is targeted by the 80386 machine. Thus I can go from compilation to real testing in less than 5 seconds.
