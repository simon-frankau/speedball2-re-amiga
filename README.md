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

The first-level loader doesn't seem that opinionated about memory. As
long as it can grab 100kB of memory it'll load the second
stage. Moreover, it uses the Amiga's boot ROM code to load the second
stage. Things start to change at this point.

The loader basically ignores whatever memory allocations the OS told
us about. In short, it skips 22 512 byte sectors (i.e. goes to track
2, side 1), and reads in 600 sectors (300kB) to addresses
0x32000-0x7D000 (i.e. starting 200kB into RAM). It then writes
0x21570d25 to address 0x44 (some magic?) and jumps to 0x32000.

It does this without OS help by directly accessing the disk
hardware. I had no idea that the Amiga did explicit MFM
encoding/decoding in software, and could use the blitter to accelerate
this process. http://lclevy.free.fr/adflib/adf_info.html was very
useful for details of MFM decoding.

Interestingly, the code is quite general, including modes to not just
read data, but write it out, and the writing mode can either overwrite
sectors selectively (by reading existing sectors and merging the data)
or creating fresh tracks. Writes are always whole-track writes.
