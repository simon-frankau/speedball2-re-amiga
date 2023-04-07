# Copy-protection trace tooling and output

This directory contains the various scripts I attempted to use for
tracing through the [Rob Northen's
copylock](https://en.wikipedia.org/wiki/Rob_Northen_copylock), which
is ana implementation of a[trace vector
decoder](https://en.wikipedia.org/wiki/Trace_vector_decoder). It
includes some dead-ends.

I have given an overview of the end to end process in
[COPY_PROTECTION.md](../COPY_PROTECTION.md), so this is really about
the specific tools and steps I took in detail:

## Ghidra scripts

 * [ghidra_trace_v0.py](ghidra_trace_v0.py) was my first attempt to
   fake the trace behaviour of the 68000 that Ghidra doesn't
   emulate. It did not work well.
 * [ghidra_trace_v1.py](ghidra_trace_v1.py) was a somewhat improved
   attempt, working with rather than against the emulator. If the
   emulator wasn't buggy, this attempt might have worked!

## fs-uae scripts

I think switched to using fs-uae as my emulation engine, since it was
known to run the game! Since getting all the information I needed
required entering lots of commands at the debugger console, I wrote
some `expect` scripts:

 * [uae_trace_v0.expect](uae_trace_v0.expect) simply captures *all*
   interrupts, including things like vertical blanking and keyboard
   presses. It was sufficient to identify which interrupt addresses I
   really wanted to capture during the reverse engineering process.
 * [uae_trace_v1.expect](uae_trace_v1.expect) then just captured
   traces from those addresses.

## fs-uae trace outputs

 * [uae_trace_v0.out](uae_trace_v0.out) is the output of
   uae_trace_v0.expect. It's pretty much correct, as I think removed
   the extraneous interrupts. It includes all the mess of the headers
   and unsynchronised I/O as I wasn't going to tidy up the test run.
 * [uae_trace_v1.out](uae_trace_v1.out) is the output of
   uae_trace_v1.expect. I have polished it up to make it easier to
   process.

## Analysis

 * [ghidra_detrace.py](ghidra_detrace.py) was an attempt to use the
   output of the fs-uae trace to decrypt (and disassemble) the
   encrypted values stored in Ghidra. This was complicated by the need
   to do manual steps, because the details of decryption kept changing
   over the trace, and didn't really provide much value. Since fs-uae
   already provided the instructions in the trace, I decided to give
   up on this approach, leave the unencypted instructions in Ghidra,
   and create a separate file of traced assembly.
 * [trace.asm](trace.asm) was my final analysis of the traced
   routine. It tries to bring together the traced routine in
   assembly-like format, tracking details of which tracer was used for
   which instructions, and analysis of what the code actually does. It
   does not disassemble any dead code, so any original copy-protection
   code left behind unexecuted is not analysed.
