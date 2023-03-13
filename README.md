# Reverse engineering of Speedball 2 for Commodore Amiga

Following up on my reverse engineering of the [Megadrive
version](https://github.com/simon-frankau/speedball2-re.git), I
thought I'd have a go at the Amiga version, in order to understand the
differences and similarities between these 68K ports. That's this
project.

## Getting started

I started on the Megadrive version because I believed (correctly, as
it turned out!) that it would be easier to get going with, asa ROM
image. Getting from a disk image to a memory image was a fun little
learning curve.

I started with "Speedball 2 - Brutal Deluxe (1990)(ImageWorks)[cr
CLS - RZR]"
([here](https://www.planetemu.net/rom/commodore-amiga-games-adf/speedball-2-brutal-deluxe-1990-imageworks-cr-cls-rzr-3). The
disk image was just the right size for 80 cylinders, 2 heads, 11
sectors/track and 512 bytes/sector, so it looked like the ADF format
would be very tractable.

### Boot block

[first-level.asm](boot/first-level.asm)

My starting point was the boot block, as described at
http://lclevy.free.fr/adflib/adf_info.html#p41 . The first thing the
boot block does is run the intro. Data reading is accomplished using
the [`TrackDisk`](https://wiki.amigaos.net/wiki/Trackdisk_Device)
device. The relevant constants and structs to decipher the assembly
can be found in the Amiga developer CD [include
files](http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0094.html#line19).

It then sets up a trap and triggers the Reset PC interrupt vector,
presumably to ensure it's in a nice, reset state and in supervisor
mode, and attempts to allocate memory.

The status of these allocation attempts are stored in locations 0x1c,
0x28 and 0x84. Since these locations overlap with (executed) code, it
looks a bit messy if I make them variables.

If we can allocate at least 100kB of chip memory, we load 5 sectors,
starting at sector 3 (via `DoIO`), into the start of the alloction and
jump to it.

### Second-level loader

[second-level.asm](boot/second-level.asm)

The first-level loader relies on the OS quite heavily, using it for
e.g. memory allocation. As long as it can allocate 100kB, it'll load
the second level into that. It uses the ROM for disk access. Around
here, things start to change, as the loader just uses memory and
hardware directly.

The loader basically ignores whatever memory allocations the OS told
us about. In short, it skips 22 512 byte sectors (i.e. goes to track
2, side 1), and reads in 600 sectors (300kB) to addresses
0x32000-0x7D000 (i.e. starting 200kB into RAM). It then writes
0x21570d25 to address 0x2c (copy-protection magic?) and jumps to
0x32000.

It does this without OS help by directly accessing the disk
hardware. I had no idea that the Amiga did explicit MFM
encoding/decoding in software, and could use the blitter to accelerate
this process. http://lclevy.free.fr/adflib/adf_info.html was very
useful for details of MFM decoding.

Interestingly, the code is quite general, including modes to not just
read data, but write it out, and the writing mode can either overwrite
sectors selectively (by reading existing sectors and merging the data)
or creating fresh tracks. Writes are always whole-track writes.

### Unpacking the main binary

The binary at 0x32000 does a `move #0x2700, SR` and jumps over the
compressed data to the start of the decompression routine at
0x7c92a. This disables interrupts and DMA, has a bunch of NOPs
(presumably disabled copy protection), sets up the stack at 0x7f000,
and copies 0x03200a-0x07a81e down to 0x000084-0x48898, before
unpacking it, expanding it from 296980 bytes to 379292
bytes.

Everything is then checksummed by a routine that places the result in
D6. This routine adds 0xdeaa4347(l) to address 0x00002c, and writes
0x3460(w) to 0x000000.

Finally, it jumps to the code entry point at 0x000084.

This leaves 0x07cab8-0x07d00 and 0x07a81e-0x07c900 as unused, but
aparently not uninitialised...

### Main binary environment

As well as decompressing the binary into 0x000084-0x05ca20, the
bootstrap system has left various odds-and-ends over the place:

 * First-level loader, 1c, 28, 84 (address where compressed image was initially loaded).
 * Second-level loader writes 0x21570d25 to address 0x00002c.
 * Decompressor adds 0xdeaa4347 to address 0x00002c.
 * Decompressor writes 0x3460(w) to 0x000000.
 * Decompressor checksums 150,000 bytes into D6, getting value 0xfbef. (*)
 * D6 gets saved to address 0x000080 by the start of the SB2 binary.

(*) According to my reversing, rather than actually observed...

By the time we're done:

 * 0x00 contains 0x3460.
 * 0x1c
 * 0x28 - pointer to scratch space?
 * 0x2c contains 0x01506c.
 * 0x80 contains 0xfbef (?)
 * 0x84 is the entry point.
 
 TODO: Work out how this all fits together...

### Copy protection measures

The VERTB interrupt handler has self-modifying code to XOR-decode a
bunch of memory. This XOR-decoding eventually self-modifies the
self-modifying code, causing it to deactivate.

We can statically undo it by XORing 0x38b767ac into 0x015070-0x159c0:

```
memory = currentProgram.getMemory()
for addr in range(0x15070, 0x159c4, 4):
    memory.setInt(toAddr(addr), 0x38b767ac ^ memory.getInt(toAddr(addr)))
```

## Memory structure

Lots to TODO here...

 * Lots of data up to 0x7f94
 * Code through 0x16994
 * Monitor images 0x173CA-0x1beca
 * IFF picture 0x49e5e-0x52d0e - title screen with "Speedball II"
 * IFF picture 0x52d0e-0x5ae00 - archway
 * Font 0x5ae00-0x5c840
 * Ends 0x5ca20

 * Stack, then buffers down from 0x080000, 

NB: The Disk image has forms from 68e00 onwards

Audio code starts at 0x000138b6

Screen size 0x224a = 209 lines of (320 + 16) pixels.

Looks like disk code from 15ee4 to 16862? 2.3kB of code?

0x15fe4-0x16862 are disk routines, identical to those in the
second-level loader.
