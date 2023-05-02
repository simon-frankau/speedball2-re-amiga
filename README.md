# Reverse engineering of Speedball 2 for Commodore Amiga

**Project status: This is incomplete. I've put a decent amount of work
into understanding the copy protection (as it is, post-crack), which I
wanted to put up, but large chunks of the image that are different
from the Megadrive version are still unexamined.**

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
([here](https://www.planetemu.net/rom/commodore-amiga-games-adf/speedball-2-brutal-deluxe-1990-imageworks-cr-cls-rzr-3)). The
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

Everything is then checksummed by a routine that places the result
(0xfbef) in D6. This routine adds 0xdeaa4347(l) to address 0x00002c,
and writes 0x3460(w) to 0x000000.

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
< 0001549c  75 20 e7 0d 9c 38 95 0d  b8 04 13 09 1a c0 73 09  19 20
> 0001549c  1d fb a0 29 69 fb 46 b9  8b 69 a1 29 9f 69 87 28  e1 6a
```

This change is inside the XOR-protected region, deep in the obfuscated
copy protection routines.

```
< 0003f09a  3f ff
> 0003f09a  f8 f1
```

This is literally one sample different in an audio sample. I have no
idea why it's changed!

The interesting thing about this is, though, that it appears the
different cracks leave the loaded memory image pretty much the same,
modulo adjustments to the core of the copy protection routines.

### Third opinion: CSL crack

If you have two different things, it's hard to tell what's original,
and what isn't. Does a third data point give us any triangulation? I
pulled apart "Speedball 2 - Brutal Deluxe (1990)(ImageWorks)[cr
CSL]". The compression mechanism is the same as DC's, and it's a very
similar image with just a few changes, if we ignore a rather lame
credits-overwriting in the intro, and an even lamer check to make sure
no-one changes their credits hack. What remains is:

```
< 0000cc74  41 f9 00 03 61 d6
> 0000cc74  4e b9 00 07 f8 00
```

This replaces the first instruction of `init_screen_status_bar` with a
rather surprising `jsr 0x7f800`. The routine at 0x7f800 is installed
by the boot sector, as follows:

```
lea        (DAT_000361d6).l,A0
move.l     #0x4d9780a1,(DAT_0001549c).l
move.l     #0xA48FE0A1,(DAT_000154a0).l
move.w     #0xA767,(DAT_000154a4).l
move.l     #0x41f90003,(DAT_0000cc74).l
move.w     #0x61d6,(DAT_0000cc78).l
rts
```

The first instruction is the one overwritten, the rest are
patches. The first three of those patch an area inside the bit that
already differs between the DC and CLS-RZR cracks, inside the
encrypted region. The last two undo the patch to
`init_screen_status_bar`!

All this doesn't teach me much, except that that encrypted region
looks pretty key to copy protection!

## Program start-up

### Main binary environment

As well as decompressing the binary into 0x000084-0x05ca20, the
bootstrap system has left various odds-and-ends over the place:

 * First-level loader initialises, 0x1c, 0x28, 0x84 (address where
   compressed image was initially loaded).
 * Second-level loader writes 0x21570d25 to address 0x00002c.
 * Decompressor adds 0xdeaa4347 to address 0x00002c.
 * Decompressor writes 0x3460(w) to 0x000000.
 * Decompressor checksums 150,000 bytes into D6.
 * D6 gets saved to address 0x000080 by the start of the SB2 binary.

Note that the checksum produces different values for the different
cracks, which should have been a hint to me that nothing really
depends on it.

### Copy protection measures

After more effort than it really should have taken, I reversed the
remains of the copy protection. It's slightly epic, so I've put it in
[COPY_PROTECTION.md](./COPY_PROTECTION.md).

## Comparison with the Megadrive port

### Binary comparison

I should start by saying that
[BinDiff](https://www.zynamics.com/software.html) was an excellent
starting point, able to very effectively identify the equivalent
functions between the Amiga and Megadrive ports. It got a bit useless
on the less similar functions, but when the differences were small it
did really well. While Ghidra integration is clearly a lot poorer than
that for the other mainstream RE tools, it can still mark up the
matching symbols. I wish it were able to also do variables, but I
slowly ploughed through and matched them manually.

There is a lot of similarity between the versions. The core engine of
the game is even largely identical. The bits that are a bit graphical
had some fairly consistent changes - code to do with flipping buffers
(Amiga) or updating cells (Megadrive) for example, is pretty
pervasive, and makes for a bunch of minor changes.

Obviuosly there are huge changes around I/O: Graphics code, mostly
involving heavy Blitter usage needed to be reversed, as did controls
(the keyboard being a bit yuck), disk access (the base layer of which
is shared with the second-level loader) and sound. The latter was a
separate chaunk of code on both platforms. They share a data format,
but the Amiga is more flexible, so some no-ops on the Megadrive were
implemented on the Amiga, helping the data make sense.

There was some dead code on the Megadrive that finally made sense in
the context of the Amiga - for example around saving replays to
disk. There's also some dead code of its own on the Amiga side - like
a menu that allows you to select a team, that's never used.

In a few places there are minor code differences that are not
well-motivated by the port; they're just little tidy-ups between the
versions. I suspect this just means the port was branched from a
slightly different version than the Amiga version.

A lot of the code and data is laid out in the same sequence on both
platforms, as you'd expect starting from the same assembly source. In
places things are juggled about. This is inevitable when the Megadrive
has a lot of ROM and a little RAM, while the Amiga is purely RAM based
and can load overlays from disk. There are a few different places
where you can see how they've squeezed storage for the Megadrive
version.

### On commenting

I commented the implementation of most of the Megadrive
functions. Unfortunately, I don't see a simple way of automating the
transfer of comments from the Megadrive edition to the Amiga edition,
and I'm not doing it by hand (soooo many comments, sooo tedious). So
my Amiga edition reversing only comments on the Amiga-specific
things. If you want to understand a specific piece of uncommented
code, look up the same function in my Megadrive reversing!

A second effect on commenting of starting with the Megadrive version
is that, despite the Amiga port being the earlier release, I treat the
Megadrive version as the baseline, and explain the Amiga port in terms
of diffs from that. In some ways, this is a bit ridiculous, but I'm
sure you can work it out. ;)

### Symbol table comparison

TODO

### Gameplay comparison

In terms of functional differences between the Amiga and Megadrive
versions, there are a few bug-fixes, but the main visible differences
are:

 * The Amiga has (significantly) better sound.
 * The Amiga has a better arena backdrop when playing the game.
 * Amiga has better load/save - games can be saved to disk at more
   regular points, controlled via the mangament menus, rather than
   getting a code at the end of a season that represents a compressed
   state.
 * Amiga allows you to save action replays.
 * Amiga UI relies on a single fire button (but supports some keyboard
   shortcuts).
 * Amiga does not have goal marker objects (little dots at the screen
   edge when the goal is offscreen).
 * Amiga AI is more cautious about doing a high pass near an enemy player.
 * Items are dropped on 16-pixel boundary, vs. 32-pixel for Megadrive.

I think the key takeaway is that the gameplay itself is really very
similar between the two versions. In my opinoin, the Megadrive version
is an excellent conversion given the constraints.

## Memory structure

Despite the complications of the initial loading process, the game
seems to assume a flat 512kB of RAM is available, and the upper limit
of RAM in 0x28 if there's more.

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
   * 0x0173be-0x01afbe Images used on the "monitor" overlay
   * 0x01afbe-0x01b55e Font used in monitor overlays.
   * 0x01b55e-0x01bc3e Variables and buffers.
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

The memory up to 0x1bc3e, including all the key game code stays
stable, while the memory above it, up to the screen buffers, is used
by overlays.

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
   and graphics, and prodvides replacement sound.
 * Overlays #1 and #28 are loaded together to provide the graphics for
   the menus and mangement mode.
 * Overlays #18, #26 and #27 are loaded together to provide the
   graphics for game mode. The space between 0x361d6 and 0x3a2d6 is
   initialised at runtime, rather than loaded from disk.

Overlays #27 and #28 contain sound data. Overlay 28 is actually an
almost verbatim copy of the data in overlay 0 that it overwrites (I
looks to me like there are about 10 samples at the end that don't
match, and they're extremely low amplitude).

It looks like Overlay #27 provides Sample 22 for game mode, while Overlay
#28/Overlay #0 provide Samples 25, 26 and 27 for management mode.

Memory-wise, these overlays are loaded as follows:

| Overlay number | Start sector | # sectors | RAM range         |
|----------------|--------------|-----------|-------------------|
| #0             | 0x26f        | 0xd8      | 0x01bc3e-0x036c3e |
| #1             | 0x347        | 0x13f     | 0x0361d6-0x05dfd6 |
| #18            | 0x568        | 0xae      | 0x03a2d6-0x04fed6 |
| #26            | 0x616        | 0x75      | 0x04fed6-0x05e8d6 |
| #27            | 0x68b        | 0x16      | 0x030d56-0x033956 |
| #28            | 0x6a1        | 0x1c      | 0x030d56-0x034456 |

In more detail, they provide the following variables:

| Overlay # | RAM start | Contents                                               |
|-----------|-----------|--------------------------------------------------------|
| #0        | 0x01bc3e  | Start of overlay #0 - Sound data                       |
| #0        | 0x0361d6  | Status bar image                                       |
| #0        | 0x036bd6  | Blank area                                             |
| #0        | 0x036c3e  | End of overlay #0                                      |
| #1        | 0x0361d6  | IFF of menu backdrop - `splash_backdrop`               |
| #1        | 0x03d744  | Management screen backdrop - `sprites_mgmt_background` |
| #1        | 0x044364  | Small characters - `sprites_font_orange`               |
| #1        | 0x044b5c  | Menu characters - `sprites_menu_font`                  |
| #1        | 0x04631c  | Font - `sprites_fonts_title_top`                       |
| #1        | 0x04677c  | Font - `sprites_fonts_title_bottom`                    |
| #1        | 0x046a9c  | Font - `sprites_fonts_cash`                            |
| #1        | 0x046bdc  | Font - `sprites_fonts_mgr_xfer_gym`                    |
| #1        | 0x04703c  | Font - `sprites_fonts_small_green`                     |
| #1        | 0x0475dc  | Font - `sprites_fonts_white`                           |
| #1        | 0x047b7c  | Management screen lights - `sprites_mgmt_lights`       |
| #1        | 0x04857c  | Management screen buttons - `sprites_mgmt_buttons`     |
| #1        | 0x04d57c  | Management screen armour - `sprites_mgmt_armour`       |
| #1        | 0x0531fc  | Faces - `sprites_player_faces`                         |
| #1        | 0x05b8fc  | Group icons (referenced via faces)                     |
| #1        | 0x05d51c  | Data - `scores_table`                                  |
| #1        | 0x05dd1c  | Data - `gym_tile_map`                                  |
| #1        | 0x05de20  | Data - `manager_transfer_tile_map`                     |
| #1        | 0x05df24  | Blank area                                             |
| #1        | 0x05dfd6  | End of overlay #1                                      |
| (#18)     | 0x0361d6  | `sprites_players_team_mask` - runtime generated        |
| #18       | 0x03a2d6  | Small, in-game sprites - `sprites_game_misc`           |
| #18       | 0x03cf56  | Main game character sprites - `sprites_players`        |
| #18       | 0x04d356  | Main game character sprites - `sprites_big_ball`       |
| #18       | 0x04dd56  | Bouncers and ball launcher - `sprites_launcher`        |
| #18       | 0x04fdd6  | Blank area                                             |
| #18       | 0x04fed6  | End of overlay #18                                     |
| #26       | 0x04fed6  | Arena tiles - `sprites_arena`                          |
| #26       | 0x05e896  | Blank area                                             |
| #26       | 0x05e8d6  | End of overlay #26                                     |
| #27       | 0x030d56  | Overlay 27 data - game sound overlay                   |
| #27       | 0x033956  | End of overlay #27                                     |
| #28       | 0x030d56  | Overlay 28 data - management sound overlay             |
| #28       | 0x034556  | End of overlay #28                                     |

It looks like the boot loader initialises 0x000028 with 0x100000 if
the machine has (at least?) 1MB of RAM, and zero otherwise. This is
used by the `start` routine to decide if we can cache the overlays in
the high 512kB.

If so, `preload_data` at 0x8056 copies relevant chunks into higher
memory if available, saving the need to load from disk. It simply
copies the whole preload chunks around, nothing subtle.

`generate_player_team_masks` uses `splash_backdrop` to create the
bitplane images for the second player. This is why overlay #18 is
loaded in slightly higher memory, to make space for that bufer.

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

| Start sector | Length | Contents                                         |
|--------------|--------|--------------------------------------------------|
| 0x000        | 0x2    | Boot block                                       |
| 0x002        | 0x5    | Second-level loader                              |
| 0x016        | 0x258  | Main binary image                                |
| 0x26e        | 0x1    | Overlay directory                                |
| 0x26f        | 0xd8   | Overlay #0: Base data (mostly music) after intro |
| 0x347        | 0x13f  | Overlay #1: Management mode graphics etc.        |
| 0x381        | 0x36   | Overlay #2: Part of #1                           |
| 0x3b7        | 0x3    | Overlay #3: Part of #1                           |
| 0x3bb        | 0xb    | Overlay #4: Part of #1                           |
| 0x3c7        | 0x4    | Overlay #5: Part of #1                           |
| 0x3cc        | 0x5    | Overlay #6: Part of #1                           |
| 0x3d1        | 0x2    | Overlay #7: Part of #1                           |
| 0x3d3        | 0x5    | Overlay #8: Part of #1                           |
| 0x3d8        | 0x28   | Overlay #9: Part of #1                           |
| 0x400        | 0x2e   | Overlay #10: Part of #1                          |
| 0x42f        | 0x56   | Overlay #11: Part of #1                          |
| 0x486        | 0x36   | Overlay #12: Victory splash image                |
| 0x4bc        | 0x2c   | Overlay #13: Loss splash image                   |
| 0x4e8        | 0x20   | Overlay #14: League win splash image             |
| 0x508        | 0x20   | Overlay #15: Promotion splash image              |
| 0x528        | 0x20   | Overlay #16: Cup win splash image                |
| 0x548        | 0x20   | Overlay #17: Knockout win splash image           |
| 0x568        | 0xae   | Overlay #18: In-game graphics etc.               |
| 0x56d        | 0x3    | Overlay #19: Part of #18                         |
| 0x570        | 0x5    | Overlay #20: Part of #18                         |
| 0x575        | 0x8    | Overlay #21: Part of #18                         |
| 0x57e        | 0x78   | Overlay #22: Part of #18                         |
| 0x5f6        | 0xa    | Overlay #23: Part of #18                         |
| 0x600        | 0x5    | Overlay #24: Part of #18                         |
| 0x605        | 0x10   | Overlay #25: Part of #18                         |
| 0x616        | 0x75   | Overlay #26: In-game graphics                    |
| 0x68b        | 0x16   | Overlay #27: In-game sound                       |
| 0x6a1        | 0x1c   | Overlay #28: Management mod sound.               |
| 0x6bd        | 0x23   | Game crack intro                                 |

## Graphics

### Overview

The graphics code makes good use of the Copper and Blitter.

The screen buffer supports efficient vertical scrolling by being
structured like a ring buffer. To scroll down one line, a line is
repurposed from being the old top line to the new bottom line.

In terms of memory, this can be viewed as two contiguous chunks of
memory, representing the latter part of screen memory, displayed
first, and then the earlier part of memory, displayed second.

The sprite drawing mechanisms need to be aware of this, breaking
sprites into two if they cross the wrap-around point.

Horrizontal scrolling is similarly managed by moving the start point
along the line, and patching up the horizontal wrap-arounds.

The in-game status bar is implemented is implemented as a third
buffer. These three chunks (with status bar optional) are assembled by
the Copper list. The Copper list also controls which of the three
screen buffers is currently displayed, and the colour palette, so that
everything gets synchronised with the vertical sync.

Sprite drawing, both with a mask and without, is accelerated by the
Blitter.

### Details of scrolling and the game pitch

The game pitch is broken into 16x16 blocks. The total game area is
40x72 blocks (making 1152x640 pixels). The screen memory is a 21x13
block window into this (336x208 pixels), of which 320x184 pixels are
shown onscreen with the hardware assisting in sub-block scrolling. The
last 16 rows of the 200 row screen are the status bar, as mentioned
above.

Horizontal scrolling is achieved by changing the starting block within
a row, and making the block that was the end of one row now the end of
another. Since there is no wrap around within horizontal scrolling,
the screen memory buffer is 209 rows long rather than 208, and the
pitch is two screens wide.

Most of this is implemented by `redraw_pitch`, a surprisingly messy
function. The pitch structure is drawn from `pitch_map` where
needed. Need is determined by `dirty_map`. The `dirty_map` entries for
the blocks around the edge of the screen are always set, to ensure the
screen displays correctly when scrolling.

`line_table` maps from the pitch's absolute Y coordinates to screen
offset. Since the screen behaves as a circular buffer, this is just
increasing addresses in the screen buffer that wrap around a few
times.

This is used to populate `screen_line_table`, which is dynamically
updated to represent where to find the on-screen lines in memory.

### Sprites

All the in-game sprites drawn through `draw_sprite` then delegate to
one of four sprite-drawing functions, called through function
pointers:

 * `sprite_fn_32x32_masked`
 * `sprite_fn_32x32_no_mask`
 * `sprite_fn_16x16_masked`
 * `sprite_fn_16x16_no_mask`

As you can tell by the names I've given them, all sprites are 16x16 or
32x32. The in-game sprites are natively this size, while management
screens sometimes have to combine sets of sprites to make the images
they need (e.g. the tiles that make up the faces).

These functions handle clipping and the display wrap-around neeeded
for vertical scrolling, then delegate to the actual blitting
functions. The wrap-around is implemented by calling doing two
blits. Vertical clipping is implemented by changing the start/end rows
of the blit, while horizontal clipping is split into several cases:
fully onscreen, < 1 block clipped to the left, < 2 blocks clipped to
the left, and the same to the right (16x16 blocks only clip up to one
block!). These are called via function pointers in an array.

The 32x32 masked blits have an extra special case - for player 1 one
of the bitplanes gets replaced such that colour 15 becomes colour 13,
changing red to blue. (Yes, it's just a single palette entry
distinguishing the two teams!)

The 16x16 cases delegate to the 32x32 blit functions at the lowest
level, which makes sense, since these functions already have to deal
with the smaller sprites, due to clipping.

At the lowest levels, the blit functions do, unsurprisingly, use the
Blitter. Only word-aligned unmasked sprites do a simple copy. All
other cases use masking, since they may start/stop on a sub-word
boundary.

Somewhat to my surprise, masks are generated on the fly: Masks are
generated by ORing together all the bitplanes of the image, so that
the mask is equivalent to "not colour zero".

There are a few non-`draw_sprite` drawing routine that call into the
blitting functions:

 * `add_monitor_overlay` calls `blit_32x32_no_mask_shared`.
 * `replay_frame` calls `sprite_fn_32x32_masked`.

I was somewhat surprised by the quality of the sprite transfer
code. Reversing most of the codebase, I can read a clear,
well-designed intent and structure; no matter what the pressures of
game development look like, it looks well-maintained.

This code did not have that feel. There's a lot of copy-and-paste code
here, not justified by performance optimisation (it would be trivial
to merge the red and blue player-drawing code, for example). Moreover,
the code differs in meaningless ways, as if one path was changed
without changing another. There are suboptimal bits of code, and I
found at least one bug (in `blit_32x32_no_mask_far_right`).

I found the bug interesting: It wouldn't be exercised in practice,
since the sprites the routine is used for don't get clipped, but it
was definitely present when I synthetically induced it with the fs-uae
debugger. This implies the sprite routines were never properly tested
separately, but only as part of the game. I'm kind of surprised, as
these generic sprite routines are about the most reusable routines in
a computer game.

Anyway, enough whinging.

### Save games and goal replays

Unlike the Megadrive version, there's disk access! The disk code is
fairly simplistic: Each replay is pretty much just the 6kB replay
buffer saved, with a couple of extra fields and identifying magic
("goal"). Each replay gets a track to itself, starting with the third
track.

Save game is similar, with the serialised state being written to the
first track for league (magic "leag") and second track for cup ("cup ").

## Artificial Intelligence

There's a lot that could be said about the algorithms the game uses,
but I don't have the energy for that right now. One thing I really
want to note, though, is that it doesn't cheat: The AI interacts with
the rest of the game via the controller variables, providing the same
input a human could. Not all games are like this!
