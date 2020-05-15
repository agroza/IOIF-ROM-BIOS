# IOIF-ROM-BIOS

## Synopsis
This repository contains the I/O Interface ROM BIOS source code for the software that will run on my DIY [ISA I/O Interface](http://www.alexandrugroza.ro/microelectronics/isa-io-interface/index.html) card that you cand find on the [Microelectronics](http://www.alexandrugroza.ro/microelectronics/index.html) page on my site.

![I/O Interface ROM BIOS](https://github.com/agroza/IOIF-ROM-BIOS/blob/master/images/rom-bios-01d.jpg?raw=true)

When finished, this computer program will perform the following tasks:
* Autodetection of up to four IDE devices that might be connected to the two IDE interfaces on the card.
* Provide a text-mode user interface for the ROM BIOS. This allows for manually configuration of up to four IDE devices.
* Display IDE devices information, on demand. Think device model, serial number, and firmware revision. In addition it will detect the IDE devices type (fixed/removable, magnetic/non-magnetic) and whether they support DMA, LBA, and I/ORDY modes. 
* INT 13h device control and possibly INT 13h BIOS extensions.
* Other things that I haven't yet thought about.

My goals would be to keep the compiled code fit within a 28C64 (64 Kbit / 8 KB) EEPROM integrated circuit. Should it extend over 8192 bytes, there is a second ROM socket on the printed circuit board assembly (PCBA). If I exceed 16 KB then I have also forseen this. By design, the I/O Interface accepts 28C256 EEPROMs as well. As simple as flipping of one or two jumpers.

PS: I was once skilled in assembly language and I used TASM and TLINK on a daily basis. But I haven't touched assembly since at least 2005. That makes it about 15 years. So I expect this project will evolve slowly as I remember all the tricks I once knew.

### Notes
* At the moment this is a work in progress so the compiled ROM mirocode is ~~pretty much useless~~ barely usable.
* In order to compile the ROM binary file, you need ```nasm.exe``` and ```romcksum.exe``` to be present in the .\bin subdirectory.
* Optionally you also need ```sclc.exe``` in the .\bin subdirectory.
* Build the project by launching ```_build.bat```.
* The compiled ROM file will be generated in the .\output subdirectory.

### Coding Conventions:
* Technically, the I/O Interface ISA card could work with 8-bit machines. But by design, the IDE interfaces are hard-wired for 16-bit ISA slots. That is why I use an 8-bit CPU detection mechanism to enable or disable the ROM BIOS.
* Given the consideration above, I tend to use the 80286 instruction set rather than 8086 one.
* Since I am aiming for minimal ROM usage, my coding style for this project could easily prove unreadable in several routines. Also it could be partially not understandable. Even I have difficulties reading it after a couple of days since writing it. For the same reason, I am stripping down any unnecessary instructions from the routines that I write. I am trying to document things as much as I can.
* I am aiming to use only registers for passing parameters. However I am also using stack frames where appropriately. But I use them in a non conventional way: I am accessing locally pushed registers for reading purposes. I mean, are there conventions in assembly language? Sure do: the ones the programmer writes.
* I try to avoid programming best practices such as writing defensive code. While I always embrace this pattern, my storage constraints forbid me to employ it on this project. I agree that it helps troubleshooting bugs and improves source code readability, for sure. But it all adds up, quickly eating those precious ROM bytes.
* This codebase only works as a whole. It might need heavy refactoring and re-thinking if you want to isolate portions of it to use in other projects.

### Toolchain
1. Source Code Lines Counter (totally optional but helps me get an idea of how much I've worked on this project)
2. Netwide Assembler (I am using NASM version 2.14.02)
3. ROM Checksum Calculator

Besides NASM, I have uploaded the other executable files in the .\bin subdirectory.
Needless to say that all of these programs require Windows to run.

### Testing Environment
* I am performing most of the superficial tests using QEMU. But I am having real difficulties identifying hard disks in the emulator.
* The real tests are performed on real hardware. The machine is equipped with an 80386DX processor running at 33 MHz. Also it has a LAN card, and dual Compact Flash cards in master/slave configuration on the Primary IDE controller.
* Testing is basically done in no time since I have written a batch script that assembles the ROM in such way that it can be executed directly from MS-DOS. This script also copies the compiled ROM file to a network share drive which is targeted by the 80386 machine. Thus I can go from compilation to real testing in less than 5 seconds.
