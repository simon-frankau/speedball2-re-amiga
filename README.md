# Reverse engineering of Speedball 2 for Commodore Amiga

Following up on my reverse engineering of the [Megadrive
version](https://github.com/simon-frankau/speedball2-re.git), I
thought I'd have a go at the Amiga version, in order to understand the
differences and similarities between these 68K ports. That's this
project.

## Getting started

I started on the Megadrive version because I believed (correctly, as
it turned out!) that it would be easier to get going with, as a ROM
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

### A second opinion: The DC crack

Since this is a cracked image, it's not necessarily clear what's part
of the original image, and what's been cracked. I reverse engineered
the "Speedball 2 - Brutal Deluxe (1990)(ImageWorks)[cr DC].adf" image,
too, which has a different (much simpler!) compression algorithm, but
produces a very similar RAM image. The memory image diff are (apart
from an extra 0xffff at the end, that makes no difference):

```
< 0001549c  75 20 e7 0d 9c 38 95 0d  b8 04 13 09 1a c0 73 09  19 20 fb
> 0001549c  1d fb a0 29 69 fb 46 b9  8b 69 a1 29 9f 69 87 28  e1 6a fb
```

This change is inside the XOR-protected region, whose purpose I
currently don't understand so I don't know what the significance of
this diff is yet. Probably copy protection.

```
< 0003f09a  3f ff
> 0003f016  f8 f1
```

This is literally one sample different in an audio sample. I have no
idea why it's changed!

The interesting thing about this is, though, that it appears the
different cracks leave the loaded memory image pretty much the
same. It looks like not much copy protection is patched over, for
example.

## Program start-up

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

`init_periodic` zeros all interrupt vectors except the line A (0x28)
and line F (0x2c) vectors, and the hardware interrupts we care about.

The VERTB interrupt handler has self-modifying code to XOR-decode a
bunch of memory. This area (0x1506c-0x159c0) contains the copy protection routines described below.  (TODO: Line A vector, etc.). This XOR-decoding
eventually self-modifies the self-modifying code, causing it to
deactivate.

We can statically undo it by XORing 0x38b767ac into 0x015070-0x159c0:

```
memory = currentProgram.getMemory()
for addr in range(0x15070, 0x159c4, 4):
    memory.setInt(toAddr(addr), 0x38b767ac ^ memory.getInt(toAddr(addr)))
```

init_tables does weird stuff. Including:

`init_tables` does `bset.b D1,(LAB_0000836a).l`, modifying an
instruction in `todo_game_disk_thing` from `addi.l
#-0x2fbffdc0,(DAT_00072e57).l` to an F-line function that'll trigger a
trap.

When we reach `todo_game_disk_thing`, it switches SP to `sound_base`
(don't worry, stack writes are predecrements!), and triggers a trap to
`trap_f_1` via the vector at 0x00002c. This sets up an illegal
instruction trap, and traps to `trap_illegal_1` via that vector at
0x000010.

`trap_illegal_1` installs `trap_illegal_2` as the illegal instruction
trap, and tries a 68010+ instruction to disable caching (presumably as
we're about to do some hardcore self-modifying code). Either way, we
get through to `trap_illegal_2`.

`trap_illegal_2` is proper obfuscation:

 * A `movem` loads the registers up with values extracted from the
   following functions. Modification of these instruction will corrupt
   the register initialisation for the obfuscated routines.
 * The next set of instructions construct a function on the stack.
 * This is then set to be the trace interrupt handler.
 * We then enable tracing!

This trace routine is really neat. It temporarily decrypts the next
instruction, based on condition codes, D1 and D2, and dumps state
into D0 for the traced routine to inspect.

It also tweaks the illegal instruction trap vector, so when we
eventually hit an illegal instruction it'll be pointing somewhere
else!

It's so neat I'm going to paste it here:

```
trap_trace:
; Re-encrypt old instruction.
    eor.l      D6,(A6)
    eor.l      D6,(0x4,A6)
; Next instruction pointer.
    movea.l    (saved_pc,SP),A6
    move.w     (SP)=>saved_sr,D6w
; Construct decryptor value:
    andi.w     #0xA71F,D6w      ; Mask out bits undefined on 68000.
    add.w      D6w,D0w          ; AAdd to D0 - doesn't feed into the key.
                                ; Probably checked by traced code.
    add.w      D6w,D1w          ; Mix through D1 with an add...
    eor.l      D1,D6            ; and XOR.
    eor.l      D2,D6            ; Take further entropy from D2.
; Decrypt next 4 bytes.
    eor.l      D6,(A6)
    eor.l      D6,(0x4,A6)
; You little beauty! The trap vector gets modified
; every time,  too.
; I'm not entirely sure how they make this work.
; Presumably it takes a long time to get to an illegal
; instruction, and the stars just line up.
    add.l      D6,(trap_illegal_vector).l
    rte
```

TODO: All speculative etc. below here.

Try to trace it:

Encrypted mess runs from 0x1506c to 0x159c0. This range appears to be
probed by todo_something_predraw, presumably to prevent static
decryption.

At 10509e:

4c fa
7f ff 00 02 4c fa 7f ff 00 02 2f 3c 00 00 00 10
2f 3c 00 04 dd b9 2f 3c bd 96 bd ae 2f 3c b3 86
b5 86 2f 3c d0 46 d2 46 2f 3c 02 46 a7 1f 2f 3c
00 02 3c 17 2f 3c 00 04 2c 6f 2f 3c bd 96 bd ae
23 cf 00 00 00 24 00 7c a7 1f 5c b9 00 00 00 24
13 ca 71 2c 4e 57 6d 85 33 0d 4e 7b e5 eb d1 16
2f 2c 65 f8

Overwrites 1507c...

	Should start 72 85.

Tracing:
        000150f0 72 85           moveq      #-0x7b,D1
        000150f2 71 2c 2f 18     mvs.b:     (0x2f18,A4),D0


start moves d6 to 0x80
A5 loaded into 0x173b6 in init_periodic.
0x173b4 cleared in init_copper.

TODO: init_tables does a weird `addi.l #-0x54a910ec,D6`. Why?

LAB_00011006 looks like it should be modified into an `rts`.

0xd59c8551
0xD0400240
----------
0xA5DC8791

... doesn't work?


update_colours behaves weirdly.


## Memory structure

Despite the complications of the initial loading process, the game
seems to assume a flat 512kB of RAM is available, and 1024kB available
if 0x28 is set to 0x100000.

The decompression routine sets the game up for the intro sequence, as
follows:

 * 0x000000-0x000084 Low memory
 * 0x000084-0x05ca20 From initial disk load:
   * 0x000084-0x007f94 Variables
   * 0x007f94-0x0124ca Main game engine
   * 0x0124ca-0x0138b6 Mostly sprite routines
   * 0x0138b6-0x014e78 Sound routines
   * 0x014e78-0x015fe4 Misc hardware routines
   * 0x015fe4-0x016862 Disk routines, identical to those in the
     second-level loader
   * 0x016862-0x0173be Graphics variables
   * 0x0173be-0x01bc3e Other variables? TODO
   * 0x01bc3e-0x04963a Sound data
   * 0x04963a-0x05ca20 Intro sequence
 * Free memory
 * 0x05fbaa-0x06a71c `screen_3_buf`
 * 0x06a71c-0x07528e `screen_2_buf`
 * 0x07528e-0x07fe00 `screen_1_buf`
 * 0x07fe00-0x080000 Stack (512 bytes)

The screens are of size 0x224a = 209 lines of (320 + 16) pixels.

The main game engine is pretty well conserved between the Megadrive
and Amiga versions.

Lots to TODO here...

 * Monitor images 0x173ca-0x1beca

The memory up to 0x1bc3e, including all the key game code (TODO:
AFAICT, right now) stays stable, while the memory above it, up to the
screen buffers, is used by overlays.

### Overlays

The `load_overlay` routine can load chunks from disk into memory. The
chunk directory is stored on-disk - see the "Disk structure" section
below. 

Some of the overlays are just sub-sets of other overlays, and never
used directly. They can be safely ignored.

IFF-based splash image overlays (overlays #12-#17) are loaded into one
of the screen buffers (from where they need to be decompressed into
another buffer). verlay 1 starts with an IFF image, but is not just a
splash image overlay.

The remaining overlays effectively work in a couple of modes:

 * Overlay #0 is loaded at 0x1bc3e-0x36c3e at the start of game, once
   the intro sequence is complete. It overwrites the intro music, data
   and graphics, and prodvides replacement sound (TODO: Anything
   else?).
 * Overlays #1 and #28 are loaded together to provide the graphics for
   the menus and mangement mode.
 * Overlays #18, #26 and #27 are loaded together to provide the
   graphics for game mode.

TODO: The purpose of overlays #27 and# #28 still not clear to
me. Current theory is mode-specific sound?

Memory-wise, these overlays are loaded as follows:

| Overlay number | Start sector | # sectors | RAM range         |
|----------------|--------------|-----------|-------------------|
| #0    		 | 0x26f 		| 0xd8   	| 0x01bc3e-0x036c3e |
| #1    		 | 0x347 		| 0x13f  	| 0x0361d6-0x05dfd6 |
| #18   		 | 0x568 		| 0xae   	| 0x03a2d6-0x04fed6 |
| #26   		 | 0x616 		| 0x75   	| 0x04fed6-0x05e8d6 |
| #27   		 | 0x68b 		| 0x16   	| 0x030d56-0x033956 |
| #28   		 | 0x6a1 		| 0x1c   	| 0x030d56-0x037956 |

In more detail, they provide the following variables:

| Overlay # | RAM start | Contents                                                |
|-----------|-----------|---------------------------------------------------------|
| #0        | 0x01bc3e  | Start of overlay #0 - Sound data                        |
| #0        | 0x0361d6  | End of sound data - TODO: Is this data live?            |
| #0        | 0x036c3e  | End of overlay #0                                       |
| #1        | 0x0361d6  | IFF of menu backdrop - `splash_backdrop`                |
| #1        | 0x03d744  | Management screen backdrop - `sprites_mgmt_background`  |
| #1        | 0x044364  | Small characters - `sprites_font_orange`                |
| #1        | 0x044b5c  | Menu characters - `sprites_menu_font`                   |
| #1        | 0x04631c  | Font - `sprites_fonts_title_top`                        |
| #1        | 0x04677c  | Font - `sprites_fonts_title_bottom`                     |
| #1        | 0x046a9c  | Font - `sprites_fonts_cash`                             |
| #1        | 0x046bdc  | Font - `sprites_fonts_mgr_xfer_gym`                     |
| #1        | 0x04703c  | Font - `sprites_fonts_small_green`                      |
| #1        | 0x0475dc  | Font - `sprites_fonts_white`                            |
| #1        | 0x047b7c  | Management screen lights - `sprites_mgmt_lights`        |
| #1        | 0x04857c  | Management screen buttons - `sprites_mgmt_buttons`      |
| #1        | 0x04d57c  | Management screen armour - `sprites_mgmt_armour`        |
| #1        | 0x0531fc  | Faces - `sprites_player_faces`                          |
| #1        | 0x05b8fc  | Group icons (referenced via faces)                      |
| #1        | 0x05d51c  | Data - `scores_table`                                   |
| #1        | 0x05dd1c  | Data - `gym_tile_map`                                   |
| #1        | 0x05de20  | Data - `manager_transfer_tile_map`                      |
| #1        | 0x05df24  | Blank area                                              |
| #1        | 0x05dfd6  | End of overlay #1                                       |
| #18       | 0x03a2d6  | Small, in-game sprites - `sprites_game_misc`            |
| #18       | 0x03cf56  | Main game character sprites - `sprites_players`         |
| #18       | 0x04d356  | Main game character sprites - `sprites_big_ball`        |
| #18       | 0x04dd56  | Bouncers and ball launcher - `sprites_launcher`         |
| #18       | 0x04fdd6  | Blank area                                              |
| #18       | 0x04fed6  | End of overlay #18                                      |
| #26       | 0x04fed6  | Arena tiles - `sprites_arena`                           |
| #26       | 0x05e896  | Blank area                                              |
| #26       | 0x05e8d6  | End of overlay #26                                      |
| #27       | 0x030d56  | Overlay 27 data - TODO                                  |
| #27       | 0x033956  | End of overlay #27                                      |
| #28       | 0x030d56  | Overlay 28 data - TODO                                  |
| #28       | 0x034556  | End of overlay #28                                      |

It looks like the boot loader initialises 0x000028 with 0x100000 if
the machine has (at least?) 1MB of RAM, and zero otherwise. This is
used by the `start` routine to decide if we can cache the overlays in
the high 512kB.

If so, `preload_data` at 0x8056 copies relevant chunks into higher
memory if available, saving the need to load from disk. It simply
copies the whole preload chunks around, nothing subtle.

TODO: It looks like the overlays are at least mostly just pure data,
very little room for copy-protection shenanighans. If there are any,
they'll be in overlays #27 and #28, and *maybe* around 0x0361d6.

TODO: `todo_generate_player_masks` uses `splash_backdrop` for some
kind of player image masks. This might explain why some data is loaded
in particular locations.

### Intro sequence

Before it is overwritten by overlay #0, the intro sequence uses the
following resources:

 * 0x01bc3e-0x04963a Intro sound data
 * 0x04963a-0x049bce Intro sequence code
 * 0x049bce-0x049e5e Introduction text
 * 0x049e5e-0x052d0e IFF picture - title screen with "Speedball II"
 * 0x052d0e-0x05ae00 IFF picture - archway backdrop
 * 0x05ae00-0x05ca20 Font

## Disk structure

The disk is a standard 80 track, 2 sides, 11 sector, 512 bytes/sector
880kB disk.

Sector 622 contains a list of overlays, loaded into memory at
0x1b7ee. I've statically loaded it into the memory image.

Splash images are IFF ILBMs.

| Start sector | Length | Contents                                        |
|--------------|--------|-------------------------------------------------|
| 0x000        | 0x2    | Boot block                                      |
| 0x002        | 0x5    | Second-level loader                             |
| 0x016        | 0x258  | Main binary image                               |
| 0x26e        | 0x1    | Overlay directory                               |
| 0x26f        | 0xd8   | Overlay #0                                      |
| 0x347        | 0x13f  | Overlay #1: Background splash image etc.        |
| 0x381        | 0x36   | Overlay #2: Part of #1                          |
| 0x3b7        | 0x3    | Overlay #3: Part of #1                          |
| 0x3bb        | 0xb    | Overlay #4: Part of #1                          |
| 0x3c7        | 0x4    | Overlay #5: Part of #1                          |
| 0x3cc        | 0x5    | Overlay #6: Part of #1                          |
| 0x3d1        | 0x2    | Overlay #7: Part of #1                          |
| 0x3d3        | 0x5    | Overlay #8: Part of #1                          |
| 0x3d8        | 0x28   | Overlay #9: Part of #1                          |
| 0x400        | 0x2e   | Overlay #10: Part of #1                         |
| 0x42f        | 0x56   | Overlay #11: Part of #1                         |
| 0x486        | 0x36   | Overlay #12: Victory splash image               |
| 0x4bc        | 0x2c   | Overlay #13: Loss splash image                  |
| 0x4e8        | 0x20   | Overlay #14: League win splash image            |
| 0x508        | 0x20   | Overlay #15: Promotion splash image             |
| 0x528        | 0x20   | Overlay #16: Cup win splash image               |
| 0x548        | 0x20   | Overlay #17: Knockout win splash image          |
| 0x568        | 0xae   | Overlay #18: TODO `sprites_game_misc`           |
| 0x56d        | 0x3    | Overlay #19: Part of #18                        |
| 0x570        | 0x5    | Overlay #20: Part of #18                        |
| 0x575        | 0x8    | Overlay #21: Part of #18                        |
| 0x57e        | 0x78   | Overlay #22: Part of #18                        |
| 0x5f6        | 0xa    | Overlay #23: Part of #18                        |
| 0x600        | 0x5    | Overlay #24: Part of #18                        |
| 0x605        | 0x10   | Overlay #25: Part of #18                        |
| 0x616        | 0x75   | Overlay #26: TODO                               |
| 0x68b        | 0x16   | Overlay #27: TODO                               |
| 0x6a1        | 0x1c   | Overlay #28: ???? Loaded with background splash |
| 0x6bd        | 0x23   | Game crack intro                                |
