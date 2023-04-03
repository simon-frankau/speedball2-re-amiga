# Reverse-engineering the post-crack copy protection on Amiga Speedball II

I've been having a bunch of fun reverse engineering the
copy-protection bits of Speedball II for the Amiga. I'd already
reverse engineered the Megadrive (Genesis) version, so picking apart
the copy protection elements of the Amiga version was one of the most
interesting bits of this version.

Note that I was working on an already-cracked image, but with plenty
of copy-protection bits left in, so on the one hand this is nothing
like on par with people cracking the original game, but it was still a
fun little intellectual challenge to work out what's left, and what
was probably cracked.

This doc covers how I approached the reversing (with what worked and
what didn't), and what I discovered (the mechanisms in the game). My
goal was to do as much reversing as possible from simply reading the
dissassembly, rather than by debugging the running game (I had
reversed pretty much the whole Megadrive game without relying on
running it).

Reversing a game on a machine thousands of times faster with thousands
of times as much storage is also a much, much easier challenge. While
I don't have the time and effort to attempt an old-school cracking
attempt, I'll write a little section at the end hypothesising what
would have been a good way to approach it.

## How I pulled this thing apart

My starting point for this exercise was Ghidra holding an in-memory
image of the game after the main binary had been loaded. By this point
I'd reversed the boot-loader, the second-level loader, and the main
binary's decompression engine. As this was a cracked image, none of
those components had copy-protection-checking elements in them,
although they did have components that were involved in copy
protection - more on that later. There were also areas in these
loaders that were full of no-ops. I had a strong suspicion that copy
protection used to live there, but had been removed.

First, I did a bunch of general reverse-engineering of the binary as a
whole - I matched up most of the core game engine with the Megaadrive
equivalent, pulled apart the platform-specific code for the disks,
sound engine, some of the graphics and interrupt routines, etc. I
pulled apart the overlay mechanisms, since not all the game could fit
in RAM on a 512kB machine. There were a few weirdnesses that looked
like corruption or something.

When pulling these things apart I noticed things that looked not
corrupted, but deliberately weird. I had found the copy protection
mechanisms and started piecing it together.

The thing about this copy-protection code was that it was clearly
layered/chained together: Later stages rely on early stages, so if I
missed an early feature, I could be totally mislead on later
features. Therefore, it made sense to trace the code in strict
execution order. A slow and inefficient approach, perhaps, but I
wanted to reverse the whole binary anyway, so I wasn't *really*
wasting time.

### Tracing through the start-up process

What I had noticed is that the various loaders did some slightly weird
things, so that the state when the main binary finished loading was
not simply "binary image loaded from 0x84 onwards, executing starts
there". In particular, we had:

 * 0x00 contains 0x3460.
 * 0x1c contains some number, dependent on memory configuration.
 * 0x28 points high up in memory if we have lots of RAM, 0 otherwise.
 * 0x2c contains 0x01506c
 * D6 contains a checksum of RAM

The first instruction when execution starts at 0x84, setting the stack
and jumping to the main game set-up routine at 0x7f94 (which I called
`start`). The very first instruction there is ``move.l
D6,(LONG_00000080).w``, stashing that checksum in a low variable.

It's useful to note that these low memory locations are interrupt
vectors for the 68K. This means these locations might be genuine
variable, they might be interrupt vectors, or they might be variables
stuffed into interrupt vectors crackers would like to use, in order to
frustrate them!

Relevant vectors include:

 * 0x00: Reset SP
 * 0x04: Reset PC
 * 0x10: Illegal instruction vector
 * 0x24: Trace mode vector
 * 0x28: A-line instruction vector
 * 0x2c: F-line instruction vector
 * 0x68: Keyboard interrupt
 * 0x6c: Copper (vsync) interrupt
 * 0x70: Audio interrupt
 * 0x80: Trap 0 interupt
 
From this, for example, it looks like they might be building the Trap
0 interrupt from a checksum - any tweaking of memory contents would
have to be very careful to avoid breaking Trap 0.

Following the start-up process step-by-step, and using my names for
the functions, I found the following weirdnesses:

 * `init_bitmaps`: `0000843c move.l #0xF39A83C9,D6` - yet D6 wasn't
   immediately used anywhere. Was it picked up much later?
 * `init_periodic`: All interrupt vectors from reset PC (0x04) to just
   before Trap 0 (0x7c) are pointed at `trap0` (0x14f88), except
   levels 2, 3, 4, line A (0x28) and line F (0x2c).
   * The `trap0` function causes a Trap 0 interrupt, vectoring to
     0x80. 0x80 has been filled in with a checksum value that doesn't
     appear to point at a useful routine. Have I got the checksum
     wrong?
   * The levels 2, 3, and 4 (aka keyboard, copper and audio
     interrupts) vectors are initialised with plausible-looking
     interrupt handlers.
   * The line A vector is being used by a variable determined by the
     amount of RAM the machine has. I'm pretty sure at this point it's
     not an interrupt handler.
   * The line F vector was initialised by the loader to 0x01506c, but
     we'll get to that later.
 * `init_periodic`: `00014f50 move.l A5,(DAT_000173b6).l`, but I'm not
   sure if anything else cares about 0x173b6. Is this a simple
   "initialisation complete" flag that's never read, or
   copy-protection?
 * Looking at the newly-installed vertical blanking interrupt,
   `int_vertb`, there's some self-modifying XOR-based decryption going
   on.
   
The start routine then kicks off the intro routine, loads an overlay,
and probably does more copy-protection stuff, but let's take a look at
what we have so far:

The VERTB interrupt handler starts with:

```
000159c0 58 b9 00        addq.l     #0x4,(LAB_000159c6+6).l
         01 59 cc
000159c6 0a b9 38        eori.l     #0x38b767ac,(0x0001506c).l
         b7 67 ac 
         00 01 50 6c
000159d0 ...
```

What this does is, every vertical blanking period, increase the target
address in the second instruction by 4, and then XOR-decrypt the
target location. Eventually the XOR targets the ADDQ, disabling it:

```
000159c0 60 0e           bra.b      LAB_000159d0
000159c2 67 ad 59 cc     long       67AD59CCh
000159c6 0a b9 38        eori.l     #0x38b767ac,(0x0001506c).l
         b7 67 ac 
         00 01 50 6c
000159d0 ...
```

Decrypting the ~2400 bytes (4 bytes per frame, 50 frames/second) takes
about 11 seconds, so by the time the unskippable parts of the intro
are done and the overlay's loaded, it should be complete.

In Ghidra we can statically undo this encryption by XORing 0x38b767ac
into 0x015070-0x159c0:

```
memory = currentProgram.getMemory()
for addr in range(0x15070, 0x159c4, 4):
    memory.setInt(toAddr(addr), 0x38b767ac ^ memory.getInt(toAddr(addr)))
```

At this point, we notice that the loader-installed line F interrupt
vector, at 0x01506c, points into this region, and now it looks like
legitimate code. We'll call it `trap_f_1` (Why '1'? There may be more
F line handlers elsewhere).

However, I don't want to reverse this too much yet, because I want to
find where it's called from, in case there are other booby-traps that
get defused first.

### Hitting the interrupt vectors

Once we get past the intro routine and load overlay 0 (some careful
analysis makes me *reasonably* confident the overlays are pure data),
we're back on the lookout for copy protection routines:

 * `start`: Has another mysterious `00007ffa move.l
   #0xF39A83C9,D6`. Still not seeing anything using D6.
 * `init_tables` differs from the Megadrive version, having a
   suspicious ```000084a6 addi.l #0xAB56EF14,D6```, and ```000084ba
   bset.b D1,(0000836a).l```. 0x836a contains code (part of
   `load_game_data`), so this is clearly some kind of
   obfuscation. However, if I'm reading the code correctly the loop
   it's in will convert the target into an invalid instruction. Have I
   missed something?
 * Tracing through to `load_game_data`, it's clearly doing suspicious
   stuff. It points SP at `sound_base` (as stack pushes are
   predecremented, `sound_base` itself is never corrupted) and
   executes the illegal instruction modified by `init_tables`. Oh,
   hang on, the instruction is 0xffb9, so this triggers the line F
   interrupt that we've just decrypted. Down the rabbit-hole we go!

### Welcome to trace vector decoders
   
For the most part here, I'm going to just describe the code. If you
want to read the actual assembly (you should, it's fun!), go look in
the appropriate files - either my main Ghidra project, or the copy
protection listings.

We enter `trap_f_1`. It bumps the return address by 2 (so that we skip
an instruction in `load_game_data`, installs the next function as
illegal instruction handler, and issues an illegal instruction.

This next function (`trap_illegal_1`) saves *all* the registers
(including A7 aka SP), sets the *next* function as illegal instruction
handler, stores SP in A0, reads a configuration register, saves it,
writes it, and falls through to the next function. Huh?

Ah, that `movec` instruction is not available on the vanilla 68000, so
it triggers an illegal instruction. So, control flows through to the
next function either directly (if supported) or via the trap. To be
more specific, the `movec` disables the cache, presumably we we're
about to get into deeply self-modifying code.

The first thing the next function (`trap_illegal_2`) does is restore
SP, so that it's the same whichever route we came through. Then, it
loads all the registers but SP from the instructions immediately
following it, treated as data. This is pretty neat, as it makes
modifying the code more difficult without affecting the register
values, which'll get checked by the copy protection code.

The following instructions push immediate longs onto the stack at
0x01bbc6 to create that we'll call `trap_trace`:

```
; Re-encrypt old instruction.
; Almost immediately disabled by adjusting vector.
0001bbc6 bd 96           eor.l      D6,(A6)
0001bbc8 bd ae 00 04     eor.l      D6,(0x4,A6)
; Alternate entry point.
; Get the parameters for next instruction.
0001bbcc 2c 6f 00 02     movea.l    (0x2,SP),A6         ; Saved return address.
0001bbd0 3c 17           move.w     (SP),D6w            ; Saved SR
; Construct decryptor value:
0001bbd2 02 46 a7 1f     andi.w     #0xA71F,D6w         ; Mask out bits undefined on 68000.
0001bbd6 d0 46           add.w      D6w,D0w             ; Add to D0 - doesn't feed into the key. Probably checked by traced code.
0001bbd8 d2 46           add.w      D6w,D1w             ; Mix through D1 with an add...
0001bbda b3 86           eor.l      D1,D6               ; and XOR.
0001bbdc b5 86           eor.l      D2,D6               ; Take further entropy from D2.
Decrypt next 8 bytes.
0001bbde bd 96           eor.l      D6,(A6)
0001bbe0 bd ae 00 04     eor.l      D6,(0x4,A6)
; Ensure that reverse engineers don't get to use illegal instructions
0001bbe4 dd b9 00        add.l      D6,(trap_illegal_vector).l
         00 00 10
0001bbea 4e 73           rte
0001bbec 00 00           dw         0h
```

This is a fun little routine that keeps an address in A6 and a key in
D6. It decodes 8 bytes at time. First it re-encodes the last lot, then
it updates the target address to be the next instruction executed,
builds a key from various bits and pieces *including all the condition
flags*, and uses that to decrypt the next 8 bytes. Finally, it ensures
the illegal instruction vector remains trashed before returning.

I only looked this up later, but this is called a [trace vector
decoder](https://en.wikipedia.org/wiki/Trace_vector_decoder) (the
example on Wikipedia looks *extremely* similar to this!), and more
specifically is an implementation of [Rob Northen's
copylock](https://en.wikipedia.org/wiki/Rob_Northen_copylock), [series
2](https://github.com/orionfuzion/dec0de/blob/master/src/dec0de.c#L2384).

Note there's a fun little initialisation issue: The routine tries to
re-encrypt the old D6/A6 pair, but when we start this isn't valid. The
start-up code gets around this by skipping the code on first pass
(it's restored soon after):

```
000150e0 23 cf 00        move.l     SP,(trap_trace_vector).l
         00 00 24
000150e6 00 7c a7 1f     ori        #0xA71F,SR
; Skip decode
000150ea 5c b9 00        addq.l     #0x6,(trap_trace_vector).l
         00 00 24
```

While this might look like it'll happen after `trap_trace` is called
for the first time, the trace routine is called *after* an instruction
completes, and the OR that enabled trace mode doesn't count, so the
first call into `trap_trace` *does* skip the re-encode steps.

There's no way I'm going to decode this thing by hand, so it's time to
use an emulator.

### Ghidra emulation

Fortunately, Ghidra has a built-in emulator. Slightly less
fortunately, it's very poorly documented. The documentation appears to
be the Javadocs for the exposed classes, plus a few third-party blogs
of how they used the emulator to handle their RE needs.

The fact that Ghidra is written in Java, the scripting interface I
used was Python, and someone doesn't know how to interface the two
lead to a particular headache for me. Occasionally I'd get random
failures to write short values to RAM. Eventually I figured out that
this was because Ghidra, being Java, expected values to be
signed. Apparently `0x8000` is not a valid 16-bit value, and could not
possibly be automatically cast. I added plenty of " if x >= 0x8000: x
-= 0x8000" code to my trace code.

The other thing that Ghidra doesn't understand is trap-generating
instructions. Line A, line F, illegal instructions, etc. are all a
mystery to it, so I had to build it myself. Very helpful in
a... reverse engineering tool? I guess it gets a bye because 68000 is
pretty obscure nowadays. :(

Anyway I hooked it altogether with some hacky Python (being a
strongly-typed fan, I never really learnt python, so this was
amazingly hacky), kicked it off, and... foom. I kept getting an
instruction triggering the line A trap. That sounds all well and good
for obfuscated code. You know what I'd do really early in a trace
vector decoder? A weird exception-generating instruction to make it
look like the decoding had gone wrong! Unfortuantely, I didn't have a
valid handler in Line A. I ran through a few more scenarios, and they
all seemed to involve valid handlers for reset or line A or one of the
other ones that just didn't have valid handlers. What had I missed?!

Eventually, after scouring the start-up sequence repeatedly, I traced
the whole start-up sequence using [fs-uae](https://fs-uae.net/),
and... nope nothing weird in memory. The saved registers at the time
the trace started matched up... except... they're off by a word?!

Turns out Ghidra was mis-emulating `movem.l (0x2,PC),{ D0..D7 A0..A6
}`. Correct emulation and I got a few good instructions!
*Aaaaaaaaaaaarrrrrrrrrrrrgggggggggghhhhhhhhhhhhh*.

**Ghidra's 68000 emulation is broken.**

As I had been so puritan in avoiding full Amiga emulation for so long,
trying to brainpower my way through it, my trust in Ghidra had cost me
many hours of reversing effort!

After a few more instructions Ghidra started diverging from fs-uae,
but at this point I was confident that this was because Ghidra was
crap, not because I'd missed some subtle copy-protection state.

### Comparing state with fs-uae

Before I dive into tracing with fs-uae, I'm going to talk a little bit
about how I used it to get memory and CPU state to compare with what I
had with Ghidra. It was cheap and fun.

To extract the data I wanted, I simply created a save game, and pulled
it apart. The format is undocumented, but the
[source](https://github.com/FrodeSolheim/fs-uae/blob/15a51e33916f87b4d74510ad99ed7297f5f3f18a/src/savestate.cpp)
is easy to follow! By default, save state is compressed, but
thoughtfully someone had provided a useful flag, and
`save_state_compression = 0` did just the trick. The format is
IFF-based, making it incredibly easy to find the chunk I wanted and
extract it to load into Ghidra. In fact, I just used emacs to do
so. Similarly to inspect the registers.

The only trickiness was that I wanted to see the registers *exactly*
at the moment tracing started. I could have learnt the debugger,
but... I just edited the save state to put an infinite loop where the
tracer would start, loaded the save, ran for a while, and saved
again. Job done!

### Tracing with fs-uae for fun and profit

Once I'd decided that I was going to use fs-uae seriously to follow
the trace decoder, I looked at the options available. I didn't want to
have to patch and recompile it if I could avoid it.

Fortunately, while fs-uae doesn't really like to talk about its
debugger, but it has one, and it's just the tool for this job.

I set `console_debugger = 1`, ran fs-uae from the command line (it's
got a very nice launcher GUI!), mashing F12-d, and I was in!

My plan was to generate a trace of the encrypted code as it's
executed. I had a theory that this deactivated copy-protection code
wouldn't have huge loops or anything like that, so the trace would be
relatively straightforward. As it turns out, I was right (I believe
the original would have been doing a whole bunch of disk access
etc. while in trace mode, so a different approach would be needed).

Unfortunately, the debugger, while providing various useful commands,
didn't seem to be scriptable. So, I wrote an `expect` script to run
through all the trace steps. It generated about 350 steps.

This is both long enough to read through, but also too long to
sensibly inline here. So, I'm including the full trace in the repo,
and will summarise the tricks used here:

 * Once tracing starts properly, the trace vector is moved back 6
   bytes, re-enabling the re-encryption steps.
 * The illegal instruction vector is overwritten to prevent its use by
   reverse engineers.
 * The integrity of the trace routine and trace vector is checked by
   reading the values.
 * They are also overwritten to destroy reverse engineer changes.
 * There are various NOPs, that look like things disabled by crackers.
 * Sometimes the overwriting modifies the key generation code, so that
   the you can't keep using the old key algorithm.
 * Eventually another trace routine is pushed onto the stack and
   installed (`trap_trace_2`). See below for details.
 * The registers that were saved by `trap_illegal_1` are inspected.
 * Some patches are applied to memory.
 * Some encrypted instructions are inspected, to check they've not
   been modified.
 * It then switches back to the first tracer, which pushes a third
   tracer onto the stack (`trap_trace_3`). This routine disables
   tracing and unwinds the stack: All done!

The `trap_trace_2` routine looks like this:

```
; First time through, comes through here, to undo the previous encryption step under the old routine.
0001bb76 bd 96           eor.l      D6,(A6)
0001bb78 bd ae 00 04     eor.l      D6,(0x4,A6)
0001bb7c 4e 71           nop                    Hmmm. No-op originally, or cracked?
0001bb7e 4e 71           nop                    Probably the latter.
0001bb80 4e 71           nop
; Entry point moved here after the first instruction using trap_trace_2.
0001bb82 48 e7 80 80     movem.l    {  A0 D0},-(SP)
0001bb86 02 7c ff ff     andi       #0xFFFF,SR
; Fetch the address...
0001bb8a 20 79 00        movea.l    (cp_addr).l,A0
         00 00 0c
; Key is built from previous key and value before last encrypted.
0001bb90 20 28 ff fc     move.l     (-0x4,A0),D0
0001bb94 d0 b9 00        add.l      (cp_key).l,D0
         00 00 08
; Re-encrypt next two longs.
; On the first pass, cp_addr points to trap_illegal_vector, scrambling it.
0001bb9a b1 98           eor.l      D0,(A0)+
0001bb9c b1 90           eor.l      D0,(A0)
; Build new address to encrypt from the return address.
0001bb9e 20 6f 00 0a     movea.l    (local_res2,SP),A0
0001bba2 23 c8 00        move.l     A0,(cp_addr).l
         00 00 0c
; Actual key used is built from static part in cp_key and previous long.
;
; This is fun because trying to modify any of this stream causes further decryption to fail...
0001bba8 20 28 ff fc     move.l     (-0x4,A0),D0
0001bbac d0 b9 00        add.l      (cp_key).l,D0
         00 00 08
; Apply decryption.
0001bbb2 b1 98           eor.l      D0,(A0)+
0001bbb4 b1 90           eor.l      D0,(A0)
; Bonus side function, if previous operation was 0xcf47XXXX.
; Interestingly, none of the instructions end 0xcf47XXXX in the cracked trace, so this never happens.
0001bbb6 0c 68 cf        cmpi.w     #0xCF47,(-0x4,A0)
         47 ff fc
0001bbbc 66 02           bne.b      LAB_0001bbc0
0001bbbe 4e 92           jsr        (A2)
                     LAB_0001bbc0:
0001bbc0 4c df 01 01     movem.l    (SP=>local_8)+,{ D0 A0}
0001bbc4 4e 73           rte
```

This routine changes the encryption (relying on the previous
instruction to create the key, thus linking instructions together in a
different way), adding another layer of complexity.

Finally, `trap_trace_3` really just unwinds does a memory move/clear
(which has been deactivated by the crack), and unwinds everything:

```
; Undo the previous decryption step.
0001bb22 bd 96           eor.l      D6,(A6)
0001bb24 bd ae 00 04     eor.l      D6,(0x4,A6)
; Set up an illegal instruction vector below, to catch if movec fails on 68000.
0001bb28 48 7a 00 14     pea        (0x14,PC)=>trap_illegal_3
0001bb2c 23 df 00        move.l     (SP)+,(trap_illegal_vector).l
         00 00 10
; Get the start of this function in A6.
0001bb32 4d fa ff ee     lea        (-0x12,PC)=>trap_trace_3,A6
; Retrieve s the saved D0, which was the register where the old value was stored.
0001bb36 20 2e 00 b8     move.l     (0xb8,A6)=>LAB_0001bbda,D0
0001bb3a 4e 7b 00 02     movec      D0,CACR
; Either falls through, or traps here on unknown instruction.
; Copy A2 bytes from A0 to A1. Copies nothing in the cracked code.
0001bb3e 20 0a           move.l     A2,D0               ; 0
0001bb40 67 20           beq.b      LAB_0001bb62        ; So, skips to end.
; Copy D0 bytes from A0 to A1, allowing for overlap (memmove-style)
0001bb42 b3 c8           cmpa.l     A0,A1
0001bb44 6f 0c           ble.b      LAB_0001bb52
; Copy D0 bytes from A0 to A1.
0001bb46 d1 c0           adda.l     D0,A0
0001bb48 d3 c0           adda.l     D0,A1
                     LAB_0001bb4a:
0001bb4a 23 20           move.l     -(A0),-(A1)
0001bb4c 59 80           subq.l     #0x4,D0
0001bb4e 66 fa           bne.b      LAB_0001bb4a
0001bb50 60 06           bra.b      LAB_0001bb58
; Copy D0 bytes from A0 to A1.
                     LAB_0001bb52:
0001bb52 22 d8           move.l     (A0)+,(A1)+
0001bb54 59 80           subq.l     #0x4,D0
0001bb56 66 fa           bne.b      LAB_0001bb52
; If A3 is non-zero clear that many bytes after the A1 copy target.
                     LAB_0001bb58:
0001bb58 20 0b           move.l     A3,D0
0001bb5a 67 06           beq.b      LAB_0001bb62
                     LAB_0001bb5c:
0001bb5c 42 99           clr.l      (A1)+
0001bb5e 59 80           subq.l     #0x4,D0
0001bb60 66 fa           bne.b      LAB_0001bb5c
; Unwind trap_illegal_1's register-saving.
                     LAB_0001bb62:
0001bb62 2d 4c 00 be     move.l     A4,(0xbe,A6)=>LAB_0001bbe0                       Copy cp_end to the illegal instruction exception return address.
0001bb66 4f ee 00 7c     lea        (0x7c,A6)=>LAB_0001bb9e,SP                       Point SP to the saved registers (0x01bbee).
0001bb6a 4c df 7f ff     movem.l    (SP=>LAB_0001bb9e)+,{ D0 D1 D2 D3 D4 D5 D6 D7    Restore all registers *except* A7/SP.
0001bb6e 58 4f           addq.w     #0x4,SP                                          Drop the saved A7/SP.
0001bb70 02 57 7f ff     andi.w     #0x7fff,(SP)=>LAB_0001bbde                       Ensure T is not set on the illegal instruction saved SR.
0001bb74 4e 73           rte                                                         Unwind illegal instruction exception, jumping to cp_end.
```

### What, exactly was the point of that?

Within all that encrypted malarky, the routine performed 3 patches,
based on data at 0x39c6 (`cp_junk`):

* Add 0x78d4c924 to 0x00dcc8: 0xd5a10a2c -> 0x4e75d350
* Add 0x78d4c924 to 0x011006: 0xd59c8551 -> 0x4e714e75
* Add 0x78d4c924 to 0x0025d6: 0x8a2e7f1d -> 0x03034841

For the first of these, it modifies the RTS at the end of a function,
and the first instruction in the next function, setting off a chain of
reinterpretation of about half-a-dozen instructions. I hadn't noticed
the the fall-through of the pre-patched code, but I had noticed that
the following function differed weirdly from the Megadrive
version. Once patched, it matches perfectly!

The second of these had a comment from me about how the RTS was
missing, it looked wrong, and it was different from the Megadrive
version. My hypothesis at the time had been that I'd missed a corner
case in the loader's decompression code, but later I suspected it had
something to do with copy protection.

The final of these patches fixes a corrupt string for the half-time
overlay message. I had a note to work out why this string looked wrong.

So, at the end of all this copy protection reversing (which would have
been a lot harder and more complicated if the binary hadn't already
been cracked!), the sum total effect of all this code is to modify
three longs of memory, which I'd already spotted as being weird!

### Goodbye, copy protection

Why am I confident that the copy protection is complete at this point?
Well... I guess I can't be totally sure there isn't another zombie
lurking somewhere, but after returning from the trace vector routine
`load_game_data` restores the old stack pointer and clears up the
memory associated with both the traced/encrypted code and the tracing
routines. It replaces the line F vector (originally installed by the
loader) with `trap_f_2`, a short routine that is near enough a no-op,
so that the trace routines aren't called again. We've tracked all the
places that set weird values etc., so unless there's a whole separate
implementation of copy protection elsewhere (and by this point I've
reversed most of the game), that's it!

## Summary of the (post-crack) copy protection mechanisms

The above goes into some depth on both how I reversed the mechanisms
that were left in by the crack, and what they were, but here I'll give
a brief summary of just the latter:

 * The loader puts some key values in certain registers and memory
   locations.
 * `int_vertb`, the vertical-blanking interrupt, decrypts a chunk of
   memory. Once complete (after about 11 seconds), it
   self-deactivates.
 * `init_tables` modifies an instruction in `load_game_data` into a
   trigger for a line F interrupt.
 * `load_game_data` does a bunch of set-up before triggering the line
   F interrupt, reaching an interrupt handler installed by the loader.
 * This interrupt handler builds a trace interrupt handler on the
   stack, and uses this to run a Rob Northen Copylock trace vector
   decoder.
 * This routine, even in its cracked state, uses a bunch of tricks to
   try to frustrate reverse engineers, but at its core it patches
   three locations in memory.
 * Once this routine completes, the memory holding copy protection
   code is zero'd and the trap F vector is replaced with a no-op
   vector.

There may be things I'm missing given this is the cracked game, but I
reversed three different cracks of the game, and they're very similar,
with the differences mostly being being in the encrypted trace region.

## Thoughts on the mechanism

Having played about with this, I now have a few opinions! Obviously my
opinions are not as well-based as someone who has cracked a pristine
image on original hardware, but I'm going to opine anyway.

### Things I liked

There's a bunch of stuff I liked. I remember crackers of the '90s
always going on about how lame copy protection schemes are,
and... sure. If you're given unlimited time to work on a fixed target,
you're going to get there in the end. I'm sure there are easy ways to
bypass all these things if you're an expert, but I still enjoyed the
effort that was clearly put in, even if I'm reversing the cracked
version:

 * It does seem like there are red herrings in place. They might just
   be the remains of broken and removed parts of the copy protection,
   but I do rather like to imagine they're deliberate.
   * For example, vectors were installed that called trap 0, but it
     was never actually used! The trap 0 vector is initialised, but
     not with a real routine!
   * Elsewhere, there appears to be the occasional pointless MOVE
     instruction.
 * Using otherwise-unused vectors as variables or overwriting them
   (e.g. line A vector, trap 0 vector), to make it harder to use them for
   reverse-engineering.
 * Installing the copy protection checks after the intro has been run
   and removed from memory, so that if you use a post-protection
   snapshot you lose the intro sequence.
 * F-line and illegal instruction exceptions used to create non-local
   control.
 * Relying on values installed by multiple stages of loader for the
   checks to work.
 * Set-up steps before the main Copylock routine are spread across
   various bits of code, fairly quietly, including in interrupt
   service routines.
 * The trace vector routine tries to keep only a single instruction
   decoded at any point.
 * Trace routines are generated by code at runtime and put on the
   stack, making them a little bit harder to find and hook.
 * Copy protection routines keep checking the trace routines and
   various interrupt vectors have not been interfered with.
 * The trace routine is modified and switched over.
 * Dependencies are chained between instructions to make it harder to
   modify the encrypted instruction stream.
 * At the end, there's an effort to erase all the copy protection code
   from memory, to make it harder to inspect.

### It could have been worse

As I decoded everything, there were various things that I was grateful
weren't done, as it made my life easier! For example:

 * It doesn't look like there's any copy protection elements in the
   overlays - they appear to be data-only.
 * More widely, there don't appear to be copy protecetion elements
   hidden in the data - e.g. chunks of code stuffed into an unused
   sound sample. There's a small table at 0x39c6, but that's about it.
 * There's no ongoing copy protection checks in the main game, after
   the initial checks.
 * While there was a little bit of stack-tweaking, significant
   modifications of the stack to create non-local control, coroutines
   and other annoyances wasn't done.
 * The set of exceptions used was relatively limited, and the code the
   tracer ran looked like normal code. Using more weird instructions
   could have helped mislead a reverse engineer into thinking they'd
   got something wrong.
 * While illegal instruction vectors were protected, there were
   e.g. plenty of trap vectors that were still available for reverse
   engineers.
 * It's possible that it had been disabled in the cracked version I
   used, but there wasn't much in the way of whole-memory checking, so
   that there's the opportunity to put all kinds of reversing tools
   all over the place in memory to trace execution.

### How to go old-school

While I played about with a pre-cracked image and the advantage of
modern hardware, I've had a bit of a think about how I'd have
approached this on the original hardware.

Even basic things like disassembling a collected image and
following/annotating the disassembly would be significantly harder on
an old machine with limited RAM, screen size etc., but for the most
part I will ignore that limitation.

I have also been trying to reverse the whole thing, rather than
finding *just* the protection routines and ripping them out. To crack
the game, you'd want to find just the relevant routines. I guess I'd
just modify the program, putting probes in to upset the copy
protection, and divide and conquer until I found where it gets
triggered. Again, though, I'm mostly ignoring that. :)

The first big question is how to chain along access until you have a
memory image that you can decode. I'm more used to applying pokes to
ZX Spectrum games, but the technique would be pretty similar:

 * The boot sector loader, loadable by ROM, must be pretty
   accessible. You can simply dump it and reverse it.
 * It will tell you how to load and execute the next stage. You can
   use this to build your own dumper for the next stage.
 * Repeat until you've reached the stage you want.

You might want to patch and run your own version of pieces of
code. You can either do this by writing a loader that loads their
code, applies patches, and then executes their code, or just copying
their code onto your disk, and directly patching that.

In either case, I think the approach is to have two disks, one the
original game disk, the other your disk, and you build cracked
versions of the routines on your disk, and at the appropriate time
step you switch over to their disk and read the next step, before
returning control to your code for analysis/patching, rather than
immmediately executing their code.

If you don't want to get have a really tedious life, an Amiga with two
disk drives and 1MB of RAM to crack 512kB games seems a really good
idea.

All this should get you so far, but how do you crack the core copy
protection routines?

#### Tracing the trace

An execution-free route seems pretty darn painful. I mean... I guess
you could build a 68000 emulator that gets all the corner cases right,
but I think the way to go remains to find a way to hook the original
routine and trace its progress.

I'm going to assume you can reverse and patch the
binary to be able to insert a breakpoint just before trace mode is
enabled. How do you trace?

I would go for replacing the tracer's RTE with a TRAP instruction,
since it's a 2-byte instruction that vectors somewhere that apparently
the tracing code doesn't check.

As the copy protection code runs with interrupts enabled, we're safe
to use a bit more stack interposing ourselves there. If we're
installed out of the way, we can trace everything without upsetting
state up to the point where either it checks the RTE instruction or
does anything to check performance.

To deal with this, our trace-hooking should track and report its
progress (draw PC on display? Report PC on serial port?). Once we know
how far we can get before the trace engine spots us, we can modify our
hook to run that far, dump the trace, reverse it, and install patches
to bypass the steps that detect our hook, until we manage to hook
through the entire copy protection process.

Once you've got a dissassembly of the whole thing, you can work out
how to modify it to skip the checks.

#### vs. cutting the Gordian knot

One thing I realised is that the Speedball II copy protection routine,
once you take out the checks, doesn't do much: It patches three memory
locations. We could just simply dump the memory state before and after
the copy protection routine runs, and diff them! It wouldn't take a
huge amount of effort to understand which were variable updates as
part of the game running, and which bits were copy protection
modifications. The crack can then remove this code wholesale and patch
those locations.

There is the question of how to hook the return point of the copy
protection routines. Assuming the copy protection routines are very
tough about spotting tampering (and they've all been removed from the
cracked version I have), the backstop is a reboot. DRAM [decays much
slower than people
think](https://github.com/simon-frankau/teensy_simm), so a reboot is
no problem. You'd need a boot ROM that doesn't start off by clearing
out RAM, though. I wonder how hard it was to get yourself some custom
EPROMs in the early '90s? I remember access to erasers and programmers
was not super-easy. Hopefully, though, there'll be some other hookable
point not checked by the routines.

### Bonus feature: Hard disk installers

Through luck, I inherited a tricked-out Amiga (fancy graphics card,
hard disk etc.) in the early 2000s. Even then, an emulator would do
what you need, but this was a nice piece of kit.

A thing that existed were "hard disk installers". These were cracks on
steroids: Not only did they disable copy protection, but they hooked
all the game's floppy disk access code, replacing it with code to read
from the hard disk filing system. How neat is that? Moreoever, while
this required the same cracking skills, the people involved had a very
different set of morals: The installers would only install from an
uncracked image, they refused to install cracks!

Unfortunately (and perhaps relevant to what I'm doing here), both then
and now it seems really very hard to find uncracked images. All the
versions on the web seem to be cracked, making it basically impossible
to play these games from a hard disk on the original hardware! I ended
up passing the Amiga onto a bigger fan and just playing on an
emulator.
