            ;Set the stack pointer sufficiently far after the end of the code.

00000084        lea         (0xcbe,PC)=>stack_pointer,SP
            ;Set DMA for enable all, blitter and disk.
00000088        move.w      #0x8250,(registers:DMACON).l

            ;We choose a transfer location we assume is way past
            ;whatever address this code has been loaded into, and
            ;low enough that we can still read 300kB in on a 512kB
            ;machine.
00000090        movea.l     #0x32000,A0                             ;200kB in.
00000096        movea.l     SP,A1                                   ;Put raw disk buffer after stack.
00000098        move.w      #22,D0w
0000009c        move.w      #600,D1w
000000a0        exg         D0,D1
000000a2        moveq       0x0,D2
000000a4        exg         D0,D2
000000a6        moveq       0x0,D3
            ;D0 = 0 - drive number. (Bit 2 = single-sided?)
            ;D1 = 22 - # sectors to skip. i.e. Start track 1.
            ;D2 = 600 - # sectors to read. 300kB.
            ;D3 = 0 - mode (vanilla read)
            ;A0 = 0x32000 - decode destination
            ;A1 = SP - raw disk buffer
000000a8        bsr.b       loader
            ;Hang with an infinite loop on failure.
            LAB_000000aa:
000000aa        tst.b       D0b
000000ac        bne.b       LAB_000000aa
000000ae        moveq       0x8,D1                                  ;8?
000000b0        addq.w      0x3,D1w                                 ;11?
000000b2        add.w       D1w,D1w                                 ;22?
000000b4        add.w       D1w,D1w                                 ;44?
000000b6        movea.l     D1,A6                                   ;Set as address...
            ;Write some magic?
000000b8        move.l      #0x21570d25,(A6)
            ;Jump to the start.
000000be        movea.l     #0x32000,A0
000000c4        jmp         A0

            ;* Target address is passed in A0, D0 returns 0 on success.
            ;*
            ;* `loader` defines a bunch of local variables:
            ;*
            ;* -0x02(w): Fake INTREQR for uninterrupted reading.
            ;* -0x04(w): Bitmask of sectors read on this track.
            ;* -0x06(w): Actually transferred size for this track (sectors)
            ;* -0x08(w): Number of sector transfers attempted on current track
            ;* -0x0a(w): Sectors gone, according to last-read sector
            ;* -0x0c(w): Sectors remaining, according to on last-read sector
            ;* -0x0e(w): Current track transfer request size (sectors)
            ;* -0x10(w): Number of sectors to skip.
            ;* -0x12(w): Current track/side
            ;* -0x14(w): Track/side increment to step
            ;* -0x18(l): Raw disk buffer
            ;* -0x1c(l): Memory source/destination
            ;* -0x1d(b): Mode: Read (0), write (1) or overwrite (2).
            ;* -0x1e(w): Word version of 0x1d.
            ;* -0x20(w): Remaining to read, in sectors.
            ;* -0x22(w): Number of sectors to skip.
            ;* -0x24(w): Drive number to read/write.
            loader:
000000c6        bset.l      0xf,D3
            ;Save 13 registers - 52 bytes, 0x34.
000000ca        movem.l     {  A5 A4 A3 A2 A...,SP
            ;And link another 0x24 (plus saving the link register.
000000ce        link.w      A6,-0x24
000000d2        move.w      D0w,D4w
000000d4        andi.w      #0x3,D4w
000000d8        move.w      D4w,(-0x24,A6)                          ;Drive number.
000000dc        move.w      D1w,(-0x22,A6)                          ;Skip count, in sectors.
000000e0        move.w      D2w,(-0x20,A6)                          ;Remaining to read, in sectors.
000000e4        move.w      D3w,(-0x1e,A6)                          ;Read/write mode.
000000e8        move.l      A0,(-0x1c,A6)                           ;Memory source/destination
000000ec        move.l      A1,(-0x18,A6)                           ;Raw disk buffer (just after stack).
000000f0        ror.w       #0x2,D0w
000000f2        andi.w      #0x1,D0w
            ;At this point, single-sided D0=1, double-sided D0=0.
000000f6        addq.w      0x1,D0w
            ;Set track/side increment.
000000f8        move.w      D0w,(-0x14,A6)
            ;Success if zero sectors to read.
000000fc        moveq       0x0,D0
000000fe        move.w      D2w,D3w
00000100        beq.w       LAB_0000018c
            ;Error out if grand total of sectors to read is more than a disk!
00000104        moveq       30,D0                                   ;Error code.
00000106        add.w       D1w,D3w
00000108        cmp.w       #1760,D3w                               ;Total sectors on 80 tracks, 11 sectors/track, 2 sides.
0000010c        bgt.w       LAB_000001ba
00000110        andi.l      #0xffff,D1
            ;Convert sectors to skip count to tracks to skip count.
00000116        divu.w      #11,D1
            ;If single-sided, double track/side count to read.
0000011a        cmpi.w      0x1,(-0x14,A6)
00000120        beq.b       LAB_00000124
00000122        add.w       D1w,D1w
            ;Store whole tracks to skip.
            LAB_00000124:
00000124        move.w      D1w,(-0x12,A6)                          ;Track/side.
00000128        swap        D1
            ;And remainder number of sectors to skip.
0000012a        move.w      D1w,(-0x10,A6)
0000012e        bsr.w       drive_start_motor
            ;If we plan to write, fill the raw buffer with 0xAAs.
00000132        tst.b       (-0x1d,A6)
00000136        beq.b       LAB_0000013c
00000138        bsr.w       fill_aa
            ;Core track-by-track transfer loop.
            ;
            ;Calculate number of sectors to read/write on this
            ;track. Start with all 11 sectors, take away number to
            ;skip. If that's less than remaining-to-read, use that
            ;instead.
            LAB_0000013c:
0000013c        move.w      (-0x10,A6),D0w
00000140        moveq       11,D1                                   ;11 sectors/track.
00000142        sub.w       D0w,D1w
            ;D1 = min(D1, remaining-to-read).
00000144        cmp.w       (-0x20,A6),D1w
00000148        ble.b       LAB_0000014e
0000014a        move.w      (-0x20,A6),D1w
            LAB_0000014e:
0000014e        move.w      D1w,(-0xe,A6)                           ;Set current track transfer size (sectors).
00000152        bsr.w       read_track
00000156        bne.b       LAB_0000018c                            ;Exit on error.
            ;If in writing mode, write.
00000158        tst.b       (-0x1d,A6)
0000015c        beq.b       LAB_00000164
0000015e        bsr.w       write_track
00000162        bne.b       LAB_0000018c                            ;Exit on error.
            ;Reduce remaining-to-read by current read size, leaving loop when done.
            LAB_00000164:
00000164        move.w      (-0x20,A6),D0w
00000168        sub.w       (-0xe,A6),D0w
0000016c        beq.b       LAB_0000018c
0000016e        move.w      D0w,(-0x20,A6)
            ;Increment unpack address (bytes) by read size (sectors) * 512 (bytes / sector).
00000172        move.w      (-0xe,A6),D0w
00000176        lsl.l       #0x8,D0
00000178        add.l       D0,D0
0000017a        add.l       D0,(-0x1c,A6)                           ;Unpack location
            ;Clear skip count, as we only skip sectors on the first track we access.
0000017e        clr.w       (-0x10,A6)
            ;Increment track/side source pointer.
00000182        move.w      (-0x14,A6),D0w                          ;Track/side increment
00000186        add.w       D0w,(-0x12,A6)                          ;Track/side
0000018a        bra.b       LAB_0000013c
            ;Once finished, wait for completion.
            LAB_0000018c:
0000018c        move.l      D0,-(SP)
0000018e        bsr.w       drive_stop_if_reading
00000192        bsr.w       blitter_wait_dma_completion
00000196        move.l      (SP)+,D0
            ;Skip to the end if no error.
00000198        beq.b       LAB_000001ba
            ;Get read track count in D1.
0000019a        moveq       0x0,D1
0000019c        move.w      (-0x12,A6),D1w                          ;Track/side
000001a0        cmpi.w      0x1,(-0x14,A6)                          ;Track/side increment
000001a6        beq.b       LAB_000001aa                            ;If track/side increment is not 1 (single-sided??), divide track/side counter by 2.
000001a8        lsr.w       #0x1,D1w
            ;Multiply by 11 sectors/track to get read sector count of whole tracks in D1.
            LAB_000001aa:
000001aa        mulu.w      #11,D1
            ;Add on other values. I think this gets us to the absolute (i.e. not relative to the start of the transfer) sector where the error occurred.
000001ae        add.w       (-0x10,A6),D1w                          ;Add on current track skip count.
000001b2        add.w       (-0x6,A6),D1w                           ;And sectors read on this track.
000001b6        move.l      D1,(0x28,SP)                            ;Store it so that the stack unwind puts this in D1.
            ;Unwind the local storage and stack.
            LAB_000001ba:
000001ba        unlk        A6=>local_38
000001bc        tst.l       D0
000001be        movem.l     SP=>local_34,{  D1 D2 D3 D4 D5 D6 D7 ...
000001c2        rts

            ;* Read a track's-worth of data.
            ;*
            ;* Lots of things are spaced 0x440 bytes apart, as that's
            ;* a raw sector size.
            ;*
            ;* This finds a sector header, then reads the next sector
            ;* through to the end of the track, then from the start of
            ;* the track to the point we started at.
            ;*
            ;* It assumes each track is contiguous, so sectors are
            ;* perfectly spaced from the start of the track.
            read_track:
000001c4        moveq       0x4,D4                                  ;5 attempts.
            LAB_000001c6:
000001c6        clr.w       (-0x4,A6)                               ;Clear sector-read bitmap for the track.
000001ca        clr.w       (-0x6,A6)                               ;Zero sectors read so far.
000001ce        clr.w       (-0x8,A6)                               ;No sectors attempted so far.
            ;Go to the track we want to read.
000001d2        move.w      (-0x12,A6),D2w                          ;Track/side.
000001d6        bsr.w       drive_seek_track_side
000001da        bne.w       LAB_0000029a                            ;Error check.
            ;Error if disk changed.
000001de        moveq       29,D0
000001e0        btst.b      0x2,(8520-A:PRA_A).l                    ;DSKCHANGE
000001e8        beq.w       LAB_0000029a
            ;If -0x1d is 2, plain overwrite mode: return early, don't read.
000001ec        moveq       0x0,D0
000001ee        cmpi.b      0x2,(-0x1d,A6)
000001f4        beq.w       LAB_000002ac
000001f8        movea.l     (-0x18,A6),A5                           ;Raw disk buffer.
000001fc        lea         (0x400,A5),A5                           ;Add 1kB
            ;* Find some sector header.
            ;Since we only start DMA after the sync value is read, we write the sync value we'd have expected to see into the buffer by hand.
00000200        move.l      #0xAAAAAAAA,(A5)
00000206        move.w      #0x4489,(0x4,A5)
0000020c        bsr.w       clear_sector_ends
00000210        bsr.w       blitter_wait_dma_completion             ;Ensure previous operation is complete.
00000214        bsr.w       read_next_sector_header
00000218        bne.w       LAB_0000029a                            ;On error, seek and retry.
0000021c        move.w      (-0xc,A6),D0w                           ;Get sectors remaining.
00000220        beq.b       LAB_00000270                            ;Only read remaining sectors on track if there's >0 of them!
            ;* Read the rest of the track.
            ;Read the remaining D0 sectors of the track.
00000222        mulu.w      #0x440,D0                               ;0x440 bytes per sector, MFM-encoded and with header.
00000226        lea         (0x6,A5),A0                             ;Offset over where we'd store the 6 byte sync header (not read).
0000022a        bsr.w       drive_read_dma                          ;Initiate read.
            ;We then decode sectors until the read has completed.
            ;If the read completes, we kick off the next read and then do an uninterruptible call to `decode_sectors`.
0000022e        lea         (registers:INTREQR).l,A4                ;Get pointer to interrupts.
00000234        bsr.w       decode_sectors                          ;Decode until the initial read has completed.
00000238        bne.b       LAB_000002a8                            ;On error, retry without seek.
            ;If -0x1d is 1, read & rewrite, we always read the full track.
0000023a        cmpi.b      0x1,(-0x1d,A6)
00000240        beq.b       LAB_0000024c
            ;Otherwise, if we've read enough sectors, we can early out of reading the rest of the track.
00000242        move.w      (-0x6,A6),D0w                           ;Actually read size.
00000246        sub.w       (-0xe,A6),D0w                           ;Current read size, in sectors.
0000024a        beq.b       LAB_000002ac                            ;Leave loop if all read.
            ;Having read a bunch of sectors at the end of the track, prepare the space for the sectors from the start of the track to be read:
            LAB_0000024c:
0000024c        movea.l     (-0x18,A6),A5                           ;Raw disk buffer.
00000250        lea         (0x400,A5),A5                           ;Again, skip 1kB.
00000254        move.w      (-0xc,A6),D0w                           ;Get the number of tail sectors we've already read. Don't stomp on them.
00000258        mulu.w      #0x440,D0                               ;Offset where we intend to land the start of the sector.
0000025c        adda.l      D0,A5                                   ;Convert to address.
0000025e        move.l      #0xAAAAAAAA,(A5)                        ;Write the missing sync bytes.
00000264        move.w      #0x4489,(0x4,A5)
0000026a        movea.l     A5,A0
0000026c        bsr.w       mfm_fixup                               ;Patch up the MFM pattern across the edge.
            ;* Read the start of the track.
            LAB_00000270:
00000270        move.w      (-0xa,A6),D0w                           ;Sectors already passed when the read started gives us the number of sectors still to read.
00000274        beq.b       LAB_0000028e                            ;Early out if nothing left to read.
00000276        mulu.w      #0x440,D0                               ;Read skipped count of sectors.
0000027a        lea         (0x6,A5),A0                             ;Starting after the sync bytes.
0000027e        bsr.w       drive_read_dma
            ;This call to `decode_sectors` is uninterruptible (and may still be processing sectors that were read in the last read attempt).
00000282        lea         (-0x2,A6),A4                            ;Set fake INTREQR that's always zero'd.
00000286        clr.w       (A4)
00000288        bsr.w       decode_sectors
0000028c        bne.b       LAB_000002a8                            ;Retry on error.
            LAB_0000028e:
0000028e        move.w      (-0x6,A6),D0w                           ;Actual read size.
00000292        sub.w       (-0xe,A6),D0w                           ;Current read size, in sectors.
00000296        beq.b       LAB_000002ac                            ;Leave loop if all read.
00000298        moveq       26,D0                                   ;Error code.
            ;Error condition.
            ;
            ;Seek to track one, side zero, and back to track zero, side zero.
            LAB_0000029a:
0000029a        move.l      D0,-(SP)=>local_4
0000029c        moveq       0x2,D2
0000029e        bsr.w       drive_seek_track_side
000002a2        bsr.w       drive_seek_track_zero
000002a6        move.l      (SP)+,D0
            ;Then try again, unless retries are out.
            LAB_000002a8:
000002a8        dbf         D4w,LAB_000001c6
            ;Done.
            LAB_000002ac:
000002ac        bsr.w       drive_clear_dskblk
000002b0        rts

            write_track:
000002b2        moveq       0x4,D4                                  ;5 attempts
000002b4        clr.w       (-0x6,A6)                               ;Zero sectors done.
            ;Check write mode:
000002b8        cmpi.b      0x2,(-0x1d,A6)                          ;2 is complete-track-writing mode.
000002be        bne.b       LAB_000002cc
            ;If in pure overwrite (not read/write) mode, we need to create the sector headers, as we have not read them.
000002c0        move.w      (-0x12,A6),D0w                          ;Track/side.
000002c4        movea.l     (-0x18,A6),A0                           ;Raw disk buffer.
000002c8        bsr.w       create_sector_headers
            ;Seek to write location, check not write protected.
            LAB_000002cc:
000002cc        bsr.w       drive_set_side
000002d0        move.l      #100,D0
000002d6        bsr.w       wait
000002da        moveq       0x1c,D0
000002dc        btst.b      0x3,(8520-A:PRA_A).l                    ;DSKPROT
000002e4        beq.b       LAB_00000334
            ;Disk is not write-protected. Write the track.
000002e6        lea         (0xdff000).l,A0
000002ec        move.w      #0x4000,(offset registers:DSKLEN &0xf...;Disable DMA, set writing.
000002f2        move.l      (-0x18,A6),(offset registers:DSKPT &0...;Set target address to raw disk buffer.
000002f8        move.w      #0x6600,(offset registers:ADKCON &0xf...;Reset MSBSYNC, WORDSYNC.
000002fe        move.w      #0x9100,(offset registers:ADKCON &0xf...;Set FAST, MFMPREC.
00000304        cmpi.w      80,(-0x12,A6)                           ;If track > 40...
0000030a        bcs.b       LAB_00000312
0000030c        move.w      #0xA000,(offset registers:ADKCON &0xf...;set precompensation 140ns.
            LAB_00000312:
00000312        move.w      #0x8010,(offset registers:DMACON &0xf...;Enable disk DMA.
00000318        move.w      #0x2,(offset registers:INTREQ &0xff,A0) ;Clear DSKBLK interrupt.
0000031e        move.w      #0xD961,(offset registers:DSKLEN &0xf...;DMA write of 0x1961 words, 12994 bytes - 11 encoded sectors plus 1024B lead in, plus a word?
00000324        move.w      #0xD961,(offset registers:DSKLEN &0xf...;Same value twice to start DMA.
0000032a        bsr.w       drive_wait_block_finished
0000032e        beq.b       LAB_00000334                            ;Break from loop if successful.
00000330        dbf         D4w,LAB_000002cc                        ;If failed, retry.
            ;Little wait at the end.
            LAB_00000334:
00000334        move.l      D0,-(SP)=>local_4
00000336        moveq       0x2,D0
00000338        bsr.w       wait
0000033c        move.l      (SP)+,D0
0000033e        rts

            ;* If writing tracks from scratch, without reading an
            ;* existing track, we need to create the sector
            ;* headers. This function does that.
            ;*
            ;* D0 holds track/side.
            ;* A0 the raw track buffer.
            create_sector_headers:
            ;Initialise D3 with format and track number for the info header, initial SS and SG.
00000340        move.l      D0,D3
00000342        ori.w       0xFF00,D3w
00000346        swap        D3
00000348        move.w      #0xb,D3w
            ;Write header after 1024B lead-in.
0000034c        lea         (0x400,A0),A0
            ;Write sync value.
            LAB_00000350:
00000350        addq.w      0x4,A0
00000352        move.l      #0x44894489,(A0)+=>LAB_00000404
            ;Write info value.
00000358        move.l      D3,D0
0000035a        bsr.w       mfm_encode
            ;Patch MFM signal across entries.
0000035e        lea         (-0x8,A0),A0
00000362        bsr.w       mfm_fixup
00000366        moveq       40,D1
            ;Checksum the header and write it in.
00000368        bsr.w       mfm_checksum
0000036c        bsr.w       mfm_encode
00000370        lea         (-0x8,A0),A0
            ;Patch MFM signal across entries.
00000374        bsr.w       mfm_fixup
            ;Skip ahead to next sector start.
00000378        lea         (0x410,A0),A0
            ;Increment SS.
0000037c        addi.w      0x100,D3w
            ;Decrement SG.
00000380        subq.b      0x1,D3b
            ;And loop until done.
00000382        bne.b       LAB_00000350
00000384        rts

            ;* If writing tracks from scratch, without reading an
            ;* existing track, we need to create the sector
            ;* headers. This function does that.
            ;*
            ;* D0 holds track/side.
            ;* A0 the raw track buffer.
            read_next_sector_header:
00000386        moveq       0xa,D2                                  ;11 attempts. Maybe because 11 sectors??
            ;Read 64 bytes of data into A5 + 6.
            ;(We assume the read doesn't read the 0xAAAA 0xAAAA 0x4489, that's prepopulated.)
            LAB_00000388:
00000388        lea         (0x6,A5),A0
0000038c        move.w      #64,D0w
00000390        bsr.w       drive_read_dma
00000394        bsr.w       drive_wait_block_finished
00000398        bne.b       LAB_000003d0                            ;Early out on error.
0000039a        bsr.w       mfm_check_header_checksum
0000039e        beq.b       LAB_000003a6                            ;Next step if successful.
            ;Try again.
000003a0        dbf         D2w,LAB_00000388
            ;After 11 tries, no success.
000003a4        bra.b       LAB_000003d2
            ;Ok, header checksum matches...
            LAB_000003a6:
000003a6        bsr.w       mfm_get_info
000003aa        bne.b       LAB_000003d6                            ;Error out if not Amiga format.
000003ac        cmp.w       (-0x12,A6),D1w                          ;Track/side
000003b0        bne.b       LAB_000003d6                            ;Error out if track number doesn't match.
000003b2        cmp.b       #11,D2b
000003b6        bge.b       LAB_000003d6                            ;Error out if sector # too high.
000003b8        cmp.b       #11,D3b
000003bc        bgt.b       LAB_000003d6                            ;Error out if SG too high.
000003be        subq.b      0x1,D3b
000003c0        move.w      D3w,(-0xc,A6)                           ;Store 0-based SG (sectors remaining to write) in -0xc.
000003c4        move.w      #11,(-0xa,A6)
000003ca        sub.w       D3w,(-0xa,A6)                           ;And sectors passed already in -0xa.
000003ce        moveq       0x0,D0                                  ;Success!
            LAB_000003d0:
000003d0        rts
            ;Error case.
            LAB_000003d2:
000003d2        moveq       24,D0
000003d4        rts
            ;Another error case.
            LAB_000003d6:
000003d6        moveq       27,D0
000003d8        rts
            ;Some other error code.
            LAB_000003da:
000003da        moveq       25,D0
000003dc        rts

            ;* Given sector data, either convert it to or from MFM
            ;* data, depending on read/write mode.
            ;*
            ;* Rewrites SG count to give the count left in the order
            ;* we're reading, not the order previously written.
            ;*
            ;* Takes pointer to INTREQR data in A4.
            ;* Variables in A6.
            ;* We put buffer in A5.
            ;*
            ;* If we put a pointer to a constant zero value in A4, it
            ;* reads through to conclusion.
            decode_sectors:
000003de        movea.l     (-0x18,A6),A5                           ;Raw disk buffer.
000003e2        lea         (0x400,A5),A5                           ;Skip 1kB.
000003e6        move.w      (-0x8,A6),D0w                           ;Get number of sectors read so far on track.
000003ea        mulu.w      #0x440,D0                               ;Sector count to bytes.
000003ee        adda.l      D0,A5
            ;Timeout after 6000 timer units.
000003f0        move.l      #6000,D0
000003f6        bsr.w       start_timer
            LAB_000003fa:
000003fa        btst.b      0x1,(0x1,A4)                            ;Check DSKBLK interrupt bit.
00000400        bne.w       LAB_00000502                            ;Bit set? Return so that we can initiate another read.
            LAB_00000404:
00000404        bsr.w       try_continue_timer
00000408        beq.w       LAB_00000506                            ;Timed out? Failure.
0000040c        tst.l       (0x440,A5)                              ;Have we read through to the header end?
00000410        beq.b       LAB_000003fa                            ;If not, loop round.
            ;Check the header on the now-read sector.
00000412        bsr.w       mfm_check_header_checksum
00000416        bne.b       LAB_000003d2                            ;On bad header, return error code.
00000418        bsr.w       mfm_get_info
0000041c        bne.b       LAB_000003d6                            ;On bad header, return error code.
0000041e        cmp.w       (-0x12,A6),D1w                          ;Track/side
00000422        bne.b       LAB_000003d6                            ;If it doesn't match, return error code.
00000424        move.w      D2w,D3w                                 ;Transfer sector # to D3.
            ;Overwrite the SG field.
00000426        lea         (0x8,A5),A0                             ;Decode the info entry of the header, again.
0000042a        bsr.w       mfm_decode_long
0000042e        move.b      #0xb,D0b                                ;Overwrite 11 in the SG entry.
00000432        sub.b       (-0x7,A6),D0b                           ;Subtract current sector number for sectors remaining to process.
00000436        lea         (0x8,A5),A0                             ;And write back updated info entry...
0000043a        bsr.w       mfm_encode
0000043e        bsr.w       mfm_checksum_header
00000442        lea         (0x30,A5),A0
00000446        bsr.w       mfm_encode                              ;With updated header checksum.
            ;Skip decoding sector if it's before/after range we care about.
0000044a        cmp.w       (-0x10,A6),D3w                          ;Check sector number against number of sectors to skip.
0000044e        blt.w       LAB_000004f4                            ;Skip if out of range.
00000452        move.w      (-0xe,A6),D0w                           ;Current read size, in sectors.
00000456        add.w       (-0x10,A6),D0w                          ;Add skip count.
0000045a        cmp.w       D0w,D3w                                 ;Check against the sector number read.
0000045c        bge.w       LAB_000004f4                            ;Skip if out of range.
00000460        btst.b      0x1,(0x1,A4)                            ;Check DSKBLK interrupt bit again.
00000466        bne.w       LAB_00000502
            ;Exit if sector has already been read, according to the bitmask.
0000046a        move.w      (-0x4,A6),D0w
0000046e        btst.l      D3,D0
00000470        bne.w       LAB_000004f4
            ;Check mode...
00000474        cmpi.b      0x1,(-0x1d,A6)
0000047a        bne.b       LAB_000004b2
            ;In write mode, preserving existing sectors.
            ;(`read_track` never even reads if we're in full write-fresh mode.)
            ;This is a sector we care about, so we scribble the data we want to write over the sector just read.
0000047c        bsr.w       sectors_to_bytes
00000480        movea.l     (-0x1c,A6),A0                           ;Target load location for this track.
00000484        adda.l      D1,A0                                   ;Add sector offset.
00000486        lea         (0x40,A5),A1                            ;Get start of MFM-encoded data.
0000048a        bsr.w       blitter_mfm_encode                      ;And encode the data into place.
            ;If disk interrupt has completed, early out to initiate next read.
0000048e        btst.b      0x1,(0x1,A4)
00000494        bne.w       LAB_00000502
            ;Compute and write back the data checksum.
00000498        lea         (0x40,A5),A0
0000049c        move.w      #0x400,D1w
000004a0        bsr.w       mfm_checksum
000004a4        lea         (0x38,A5),A0
000004a8        bsr.w       mfm_encode
000004ac        bsr.w       mark_sector_read
000004b0        bra.b       LAB_000004f4
            ;In read mode. Read data!
            LAB_000004b2:
000004b2        lea         (0x40,A5),A0                            ;Checksum the data...
000004b6        move.w      #0x400,D1w
000004ba        bsr.w       mfm_checksum
000004be        move.l      D0,-(SP)=>local_4
000004c0        lea         (0x38,A5),A0                            ;Read the checksum.
000004c4        bsr.w       mfm_decode_long
000004c8        cmp.l       (SP)+,D0
000004ca        bne.w       LAB_000003da                            ;Return next level with error code if checksum error.
            ;If disk interrupt has completed, early out to initiate next read.
000004ce        btst.b      0x1,(0x1,A4)
000004d4        bne.b       LAB_00000502
000004d6        bsr.b       sectors_to_bytes                        ;Get data offset to write to decode to.
000004d8        lea         (0x40,A5),A0                            ;MFM-encoded data address in A0.
000004dc        movea.l     (-0x1c,A6),A1                           ;Base location to unpack to.
000004e0        adda.l      D1,A1                                   ;Decode address in A1.
000004e2        bsr.w       blitter_mfm_decode                      ;And perform the decode.
000004e6        bsr.w       mark_sector_read                        ;Then mark sector read.
000004ea        move.w      (-0x6,A6),D0w                           ;Fetch read sector count.
000004ee        cmp.w       (-0xe,A6),D0w                           ;Current read size, in sectors.
000004f2        beq.b       LAB_00000502                            ;Leave loop if complete.
            ;Another sector processed, but have not hit any of the "done" conditions.
            ;
            ;If we haven't made 11 sector read attempts, have another go.
            LAB_000004f4:
000004f4        addq.w      0x1,(-0x8,A6)
000004f8        cmpi.w      11,(-0x8,A6)
000004fe        bne.w       decode_sectors
            ;Block read, success.
            LAB_00000502:
00000502        moveq       0x0,D0
00000504        rts
            ;Timeout, failure.
            LAB_00000506:
00000506        moveq       0xFFFF,D0
00000508        rts

            ;* Takes track sector number in D3, converts to track byte
            ;* offset in D1.
            ;*
            ;* Also returns sector length in D0.
            sectors_to_bytes:
0000050a        move.l      D3,D1
0000050c        sub.w       (-0x10,A6),D1w                          ;Take away skip count.
00000510        move.l      #512,D0                                 ;512 bytes/sector.
00000516        mulu.w      D0w,D1
00000518        rts

            ;* Mark sector D3 as read in the bit mask and increment
            ;* the sectors read counter.
            mark_sector_read:
            ;Read, modify, write the sector-read bitmap.
0000051a        move.w      (-0x4,A6),D0w
0000051e        bset.l      D3,D0
00000520        move.w      D0w,(-0x4,A6)
            ;Increment sector read count.
00000524        addq.w      0x1,(-0x6,A6)
00000528        rts

            ;* Clears the end of each sector, so that we can check if
            ;* it's been written yet.
            ;*
            ;* Address in A5.
            ;* Write 11 longs of 0x00000000, spaced out every 0x440 bytes.
            clear_sector_ends:
0000052a        movea.l     A5,A0
0000052c        moveq       0xa,D1
0000052e        moveq       0x0,D0
            LAB_00000530:
00000530        lea         (0x440,A0),A0
00000534        move.l      D0,(A0)
00000536        dbf         D1w,LAB_00000530
0000053a        rts

            ;* Sector data in A5.
            ;* 
            ;* Returns:
            ;*  * D3: SG
            ;*  * D2: SS
            ;*  * D1: TT
            ;*  * D0: Format.
            mfm_get_info:
            ;Get the info long from the sector header (offset 8).
0000053c        lea         (0x8,A5),A0
00000540        bsr.w       mfm_decode_long
            ;Extract SG field.
00000544        move.w      D0w,D3w
00000546        andi.w      #0xff,D3w
            ;Extract SS (sector #) field.
0000054a        move.w      D0w,D2w
0000054c        lsr.w       #0x8,D2w
            ;Extract TT (track) field.
0000054e        swap        D0
00000550        move.w      D0w,D1w
00000552        andi.w      #0xff,D1w
            ;Check it's Amiga 1.0 format (0xff in top byte).
00000556        lsr.w       #0x8,D0w
00000558        cmp.b       #0xFF,D0b
0000055c        rts

            ;* Decode one MFM-encoded long.
            ;* 
            ;* Data pointer in A0 (gets incremented), result in D0.
            ;*
            ;* Read 8 bytes. And both long with 0x55555555, shift the
            ;* first by 1 and then or them together, to interleave.
            mfm_decode_long:
0000055e        move.l      (A0)+,D0
00000560        move.l      (A0)+,D1
00000562        andi.l      #0x55555555,D0
00000568        andi.l      #0x55555555,D1
0000056e        add.l       D0,D0
00000570        or.l        D1,D0
00000572        rts

            mfm_check_header_checksum:
00000574        bsr.w       mfm_checksum_header
00000578        move.l      D0,-(SP)=>local_4
            ;Header checksum is at offset 48.
0000057a        lea         (48,A5),A0
0000057e        bsr.b       mfm_decode_long
            ;Check the checksum matches the calculated value.
00000580        cmp.l       (SP)+,D0
00000582        rts

            ;* Generate the checksum of an MFM sector header -
            ;* computed on MFM longs from offset 8 to 44. Start of
            ;* sector in A5.
            ;*
            ;* Does this by generating an XOR check of 40 bytes
            ;* starting at offset 8 from A5.
            ;* 
            ;* Returns result in D0.
            mfm_checksum_header:
00000584        lea         (0x8,A5),A0
00000588        moveq       40,D1
            ;Fall through.

            ;* Given an address in A0, and a byte count in D1, get a
            ;* "checksum" of the longs XOR'd together and ANDed with
            ;* 0x55555555.
            ;*
            ;* Return it in D0.
            mfm_checksum:
0000058a        move.l      D2,-(SP)=>local_4
0000058c        lsr.w       #0x2,D1w                                ;Byte count to long count.
0000058e        subq.w      0x1,D1w                                 ;dbf loops once until -1, so loop long count times.
00000590        moveq       0x0,D0                                  ;Start with 0.
            LAB_00000592:
00000592        move.l      (A0)+,D2                                ;XOR the values together.
00000594        eor.l       D2,D0
00000596        dbf         D1w,LAB_00000592
0000059a        move.l      (SP)+,D2
0000059c        andi.l      #0x55555555,D0                          ;And mask with 0x55555555 to extract data bits.
000005a2        rts

            ;* Create a blank lead-in/track by writing sync bytes.
            ;*
            ;* Writes 1kB of lead-in sync, unless this is a full
            ;* track write, in which case it fully fills the track
            ;* with sync bytes.
            fill_aa:
000005a4        movea.l     (-0x18,A6),A0                           ;Raw disk buffer.
            ;Fill all registers with 0xaaaaaaaa, for fast fill.
000005a8        move.l      #0xAAAAAAAA,D0
000005ae        move.l      D0,D1
000005b0        move.l      D0,D2
000005b2        move.l      D0,D3
000005b4        move.l      D0,D4
000005b6        move.l      D0,D5
000005b8        move.l      D0,D6
000005ba        move.l      D0,D7
000005bc        lea         (0x400,A0),A1                           ;1kB
000005c0        cmpi.b      0x1,(-0x1d,A6)                          ;Unless in write mode, when we increase it to...
000005c6        beq.b       LAB_000005cc
000005c8        lea         (0x32c0,A0),A1                          ;make it 12992B.
            ;(Note that this is 1kB + 11 * 1088, where 1088 is the raw sector size.)
            ;Fill loop.
            LAB_000005cc:
000005cc        movem.l     {  D7 D6 D5 D4 D3 D2 D1 D0},A1
000005d0        cmpa.l      A1,A0
000005d2        bne.b       LAB_000005cc
000005d4        rts

            ;* Decoded length in D0.
            ;* Sources in A0, A1.
            blitter_mfm_decode:
000005d6        move.l      A2,-(SP)=>local_4
            ;Blitter init sets mask in channel C, end conditions, etc.
000005d8        bsr.w       blitter_init
            ;Set up odd data in A.
000005dc        adda.l      D0,A0
000005de        subq.l      0x1,A0
000005e0        move.l      A0,(0x50,A2)                            ;BLTAPT
            ;Set up even data in B.
000005e4        adda.l      D0,A0
000005e6        move.l      A0,(0x4c,A2)                            ;BLTBPT
            ;Destination in A1.
000005ea        adda.l      D0,A1
000005ec        subq.l      0x1,A1
000005ee        move.l      A1,(0x54,A2)                            ;BLTDPT
            ;11011000
            ;abc ab^c a^b^c ^abc
            ;(c & b) | (~c & a)
            ;i.e. OR together masked bits from A and B.
000005f2        move.w      #0x1dd8,(0x40,A2)                       ;BLTCON0: A source - shift 1, use A, B, D.
000005f8        move.w      #0x2,(0x42,A2)                          ;BLTCON1: Descending.
000005fe        lsl.w       #0x2,D0w
00000600        ori.w       0x8,D0w
00000604        move.w      D0w,(0x58,A2)                           ;BLTSIZE
00000608        movea.l     (SP)+,A2
0000060a        rts

            ;* Source in A0, destination in A1.
            ;* Decoded length in D0.
            ;* Encode D0 bytes of data into D0 * 2 raw MFM-encoded bytes.
            ;*
            ;* 4 passes: Copy odd data bits, construct odd MFM bits,
            ;* then the same for evens.
            blitter_mfm_encode:
0000060c        movem.l     {  A2 D3 D2 D1},SP
00000610        bsr.w       blitter_init
00000614        move.w      D0w,D1w
00000616        lsl.w       #0x2,D1w
00000618        ori.w       0x8,D1w
            ;Encode odd data.
            ;
            ;A and B sourced from same location.
0000061c        move.l      A0,(0x50,A2)                            ;BLTAPT
00000620        move.l      A0,(0x4c,A2)                            ;BLTBPT
            ;D set to destination.
00000624        move.l      A1,(0x54,A2)                            ;BLTDPT
            ;10110001
            ;abc a^bc ab^c ^a^b^c
            ;(c & a) | (^c & ^b)
            ;i.e. copy odd bits, interleave with inverted bits.
            ;
00000628        move.w      #0x1db1,(0x40,A2)                       ;BLTCON0. Source A - shift 1, use A, B, D.
0000062e        move.w      #0x0,(0x42,A2)                          ;BLTCON1. Source B - shift 0. Ascending.
            ;Kick off DMA, wait for completion.
00000634        move.w      D1w,(0x58,A2)                           ;BLTSIZE
00000638        bsr.w       blitter_wait_dma_completion
            ;A from source, B from destination.
0000063c        move.l      A0,(0x50,A2)                            ;BLTAPT
00000640        move.l      A1,(0x4c,A2)                            ;BLTBPT
00000644        move.l      A1,(0x54,A2)                            ;BLTDPT
            ;10001100
            ;abc ^abc ^ab^c
            ;(c & b) | (~c & ~a & b)
            ;i.e. preserve copied bits, construct MFM from NOR.
00000648        move.w      #0x2d8c,(0x40,A2)                       ;BLTCON0: A source - shift 2, use A, B, D.
                                                                    ;(B remains unshifted, ascending.)
            ;Kick off DMA, wait for completion.
0000064e        move.w      D1w,(0x58,A2)                           ;BLTSIZE
00000652        bsr.w       blitter_wait_dma_completion
            ;This blit is descending, point to end of destination buffer.
00000656        move.l      A0,D2
00000658        add.l       D0,D2
0000065a        subq.l      0x2,D2
0000065c        move.l      A1,D3
0000065e        add.l       D0,D3
            ;Writing even bits (another input-buffer-length offset).
00000660        add.l       D0,D3
00000662        subq.l      0x2,D3
            ;A and B sourced from same location.
00000664        move.l      D2,(0x50,A2)                            ;BLTAPT
00000668        move.l      D2,(0x4c,A2)                            ;BLTBPT
0000066c        move.l      D3,(0x54,A2)                            ;BLTDPT
            ;10110001
            ;abc a^bc ab^c ^a^b^c
            ;(c & a) | (^c & ^b)
            ;i.e. copy even bits, interleave with inverted bits.
            ;
00000670        move.w      #0xdb1,(0x40,A2)                        ;BLTCON0. A source - no shift, use A, B, D.
00000676        move.w      #0x1002,(0x42,A2)                       ;BLTCON1. B source - 1 shift, descending.
            ;Kick off DMA, wait for completion.
0000067c        move.w      D1w,(0x58,A2)                           ;BLTSIZE
00000680        bsr.w       blitter_wait_dma_completion
            ;Ascending blit on even data.
00000684        move.l      A1,D3
00000686        add.l       D0,D3
            ;A from source, B from destination.
00000688        move.l      A0,(0x50,A2)                            ;BLTAPT
0000068c        move.l      D3,(0x4c,A2)                            ;BLTBPT
00000690        move.l      D3,(0x54,A2)                            ;BLTDPT
            ;10001100
            ;abc ^abc ^ab^c
            ;(c & b) | (~c & ~a & b)
            ;i.e. preserve copied bits, construct MFM from NOR.
00000694        move.w      #0x1d8c,(0x40,A2)                       ;BLTCON0. Source A - shift 1, use A, B, D.
0000069a        move.w      #0x0,(0x42,A2)                          ;BLTCON1. Source B - no shift, ascending.
            ;Kick off DMA, wait for completion.
000006a0        move.w      D1w,(0x58,A2)                           ;BLTSIZE
000006a4        bsr.w       blitter_wait_dma_completion
000006a8        move.l      D0,D1
            ;Fix up MFM pattern at start of data.
000006aa        movea.l     A1,A0
000006ac        bsr.w       mfm_fixup
            ;Fix up MFM pattern at the switch from odd to even bits.
000006b0        adda.l      D1,A0
000006b2        bsr.w       mfm_fixup
            ;Fix up MFM pattern at the end of the newly added data.
000006b6        adda.l      D1,A0
000006b8        bsr.b       mfm_fixup
000006ba        movem.l     SP=>local_10,{  D1 D2 D3 A2}
000006be        rts

            blitter_wait_dma_completion:
            ;Wait until blitter DMA no longer enabled.
000006c0        btst.b      0x6,(registers:DMACONR).l               ;BLTEN bit.
000006c8        bne.b       blitter_wait_dma_completion
000006ca        rts

            blitter_init:
000006cc        lea         (registers:REG_BASE).l,A2
000006d2        bsr.b       blitter_wait_dma_completion
000006d4        move.w      #0x8040,(offset registers:DMACON &0xf...;Set BLTEN.
000006da        move.l      #0xFFFFFFFF,(offset registers:BLTAFWM...;No first/last word masking.
000006e2        move.w      #0x5555,(offset registers:BLTCDAT &0x...;Source data register.
000006e8        clr.w       (offset registers:BLTAMOD &0xff,A2)     ;Zero modulo for source A & B, destination D.
000006ec        clr.w       (offset registers:BLTBMOD &0xff,A2)
000006f0        clr.w       (offset registers:BLTDMOD &0xff,A2)
000006f4        rts

            ;* Given data in D0, write out two longs of MFM-encoded data to A0.
            mfm_encode:
000006f6        move.l      D0,-(SP)=>local_4
            ;Write out odd bits.
000006f8        lsr.l       #0x1,D0
000006fa        bsr.w       mfm_encode_evens
            ;Then even bits.
000006fe        move.l      (SP)+,D0
00000700        bsr.w       mfm_encode_evens

            ;* A0 points to some MFM-encoded data where the first bit
            ;* should be synchronised against the MFM pattern of
            ;* previous data.
            ;*
            ;* Inserts a one bit between consecutive zero bits over the gap.
            mfm_fixup:
00000704        move.b      (A0),D0b
00000706        btst.b      0x0,(-0x1,A0)                           ;Fetch LSB of previous byte.
0000070c        bne.b       LAB_0000071a
            ;Previous bit was unset.
0000070e        btst.l      0x6,D0                                  ;Is our first data bit set?
00000712        bne.b       LAB_00000720                            ;If so, do nothing.
00000714        bset.l      0x7,D0                                  ;If both unset, insert a set bit.
00000718        bra.b       LAB_0000071e
            ;Previous bit was set.
            LAB_0000071a:
0000071a        bclr.l      0x7,D0                                  ;Clear top bit.
            LAB_0000071e:
0000071e        move.b      D0b,(A0)                                ;Write back and return.
            LAB_00000720:
00000720        rts

            ;* Given data in the even bits of D0, write out full MFM-encoded data to A0++.
            mfm_encode_evens:
00000722        andi.l      #0x55555555,D0                          ;Extract even bits.
00000728        move.l      D0,D2
0000072a        eori.l      0x55555555,D2                           ;Invert.
00000730        move.l      D2,D1
00000732        add.l       D2,D2                                   ;Shift a copy left.
00000734        lsr.l       #0x1,D1                                 ;Shift a copy right.
00000736        bset.l      0x1f,D1                                 ;Set top bit - assume previous bit was a 1.
0000073a        and.l       D2,D1                                   ;MFM bit is made from NOR of bits either side.
0000073c        or.l        D1,D0                                   ;Merge in original.
            ;And clear top bit if previous bit was set, to get edge case correct.
0000073e        btst.b      0x0,(-0x1,A0)
00000744        beq.b       LAB_0000074a
00000746        bclr.l      0x1f,D0
            ;And write it out.
            LAB_0000074a:
0000074a        move.l      D0,(A0)+
0000074c        rts

            ;* Initiate a DMA read.
            ;* 
            ;* Target memory address in A0.
            ;* Length in byte in D0.
            drive_read_dma:
0000074e        lea         (0xdff000).l,A1
00000754        move.w      #0x4000,(offset registers:DSKLEN &0xf...;Disable DMA.
0000075a        move.w      #0x8010,(offset registers:DMACON &0xf...;Set DSKEN bit - enable disk DMA.
00000760        move.w      #0x6600,(offset registers:ADKCON &0xf...;Reset MSBSYNC, WORDSYNC, no precomp.
00000766        move.w      #0x9500,(offset registers:ADKCON &0xf...;Set FAST, WORDSYNC and MFMPREC.
0000076c        move.w      #0x4489,(offset registers:DSKSYNC &0x...;Input stream synchroniser value.
00000772        move.l      A0,(offset registers:DSKPT &0xff,A1)    ;Set target memory address.
00000776        move.w      #0x2,(offset registers:INTREQ &0xff,A1) ;Clear DSKBLK interrupt bit.
0000077c        lsr.w       #0x1,D0w                                ;Convert byte count to word count.
0000077e        ori.w       0x8000,D0w                              ;Set DMAEN bit.
            ;Write twice to initiate DMA.
00000782        move.w      D0w,(offset registers:DSKLEN &0xff,A1)
00000786        move.w      D0w,(offset registers:DSKLEN &0xff,A1)
0000078a        rts

            drive_wait_block_finished:
0000078c        lea         (registers:REG_BASE).l,A1
00000792        move.l      #6000,D0                                ;Timeout value.
00000798        bsr.w       start_timer
            ;Check interrupt in bit 1, DSKBLK - disk block finished.
            LAB_0000079c:
0000079c        btst.b      0x1,(offset registers:INTREQR_L &0xff...
000007a2        bne.b       LAB_000007ae
            ;Otherwise, keep going on the timer.
000007a4        bsr.w       try_continue_timer
000007a8        bne.b       LAB_0000079c
            ;Timeout. D0 = -1.
000007aa        moveq       -0x1,D0
000007ac        bra.b       drive_clear_dskblk
            ;Interrupt. D0 = 0.
            LAB_000007ae:
000007ae        moveq       0x0,D0
            ; Fall-through

            drive_clear_dskblk:
000007b0        move.w      #0x2,(registers:INTREQ).l               ;Clear DSKBLK interrupt bit.
000007b8        move.w      #0x4000,(registers:DSKLEN).l            ;DMA disabled, WRITE enabled, DMA length 0.
000007c0        tst.l       D0                                      ;Set flags based on D0 for return value.
000007c2        rts

            ;* Stop the motor, if we're reading.
            drive_stop_if_reading:
000007c4        move.w      #0x400,(registers:ADKCON).l             ;Clear WORDSYNC
000007cc        tst.w       (-0x1e,A6)                              ;Get read/write mode.
            ;If > 0, writing, do nothing.
000007d0        bpl.b       LAB_000007f0
            ;If reading:
            ;DSKMOTOR set to stop, then set motor state.
000007d2        moveq       0xFFFF,D1

            ;* Writes out D1 to select DSKMOTOR setting, then strobes
            ;* the DSKSEL? line to latch.
            drive_set_motor:
            ;Disk is on PB of CIA B.
            ;
            ;Write the start/stop value.
000007d4        move.b      D1b,(8250-B:PRB_B).l
000007da        move.w      (-0x24,A6),D0w                          ;Drive number.
000007de        addq.l      0x3,D0
            ;Clear bit to select drive, and latch DSKMOTOR.
000007e0        bclr.l      D0,D1
000007e2        move.b      D1b,(8250-B:PRB_B).l
            ;Set bit to deselect drive.
000007e8        bset.l      D0,D1
000007ea        move.b      D1b,(8250-B:PRB_B).l
            LAB_000007f0:
000007f0        rts

            drive_start_motor:
            ;Set all bits high to deselect everything.
000007f2        moveq       0xFFFF,D1
000007f4        move.b      D1b,(8250-B:PRB_B).l
            ;Set DSKMOTOR low, to activate motor when DSKSEL? is strobed.
000007fa        bclr.l      0x7,D1
000007fe        bsr.b       drive_set_motor
            ;And wait (400ms?).
00000800        move.l      #200,D0
00000806        bsr.w       wait
0000080a        rts

            ;* Takes track/side in D2, seeks to appropriate location.
            ;* 
            ;* D0 is zero on success, 30 on failure.
            drive_seek_track_side:
0000080c        movem.l     {  D3 D2},SP
00000810        move.l      D2,D3
00000812        bsr.w       drive_set_side
            ;Fetch current drive/side into D0.
00000816        move.w      (-0x24,A6),D0w                          ;Drive number.
0000081a        add.w       D0w,D0w
0000081c        lea         (0x11e,PC)=>drives,A0
00000820        move.w      (0x0,A0,D0w*0x1)=>drives,D0w
            ;If it's zero, seek back to track zero.
00000824        bpl.b       LAB_0000082c
00000826        bsr.w       drive_seek_track_zero
0000082a        bne.b       LAB_0000085a
            ;Convert current track/side to track.
            LAB_0000082c:
0000082c        lsr.w       #0x1,D0w
            ;Target track/side to track.
0000082e        lsr.w       #0x1,D2w
            ;Default to increasing track number.
00000830        moveq       0x1,D1
            ;Difference in D2.
00000832        sub.w       D0w,D2w
            ;Track diff zero? Done seeking.
00000834        beq.b       LAB_00000846
            ;If negative, step the other way.
00000836        bpl.b       LAB_0000083c
00000838        moveq       -0x1,D1
0000083a        neg.w       D2w
            ;Perform D2 steps.
            LAB_0000083c:
0000083c        moveq       0x3,D0
0000083e        bsr.w       drive_step_head
00000842        subq.w      0x1,D2w
00000844        bne.b       LAB_0000083c
            ;Write back track/side, set side on the hardware.
            LAB_00000846:
00000846        move.w      (-0x24,A6),D0w                          ;Drive number.
0000084a        add.w       D0w,D0w
0000084c        lea         (0xee,PC)=>drives,A0
00000850        move.w      D3w,(0x0,A0,D0w*0x1)=>drives
00000854        bsr.w       drive_set_side
            ;D0 = 0 for success.
00000858        moveq       0x0,D0
            LAB_0000085a:
0000085a        movem.l     SP=>local_8,{  D2 D3}
0000085e        rts

            ;* Returns 0x00 on success, 0x30 on failure, in D0.
            drive_seek_track_zero:
00000860        movem.l     {  D2},SP
00000864        moveq       85,D2                                   ;80 tracks, plus some for luck?
            LAB_00000866:
00000866        btst.b      0x4,(8520-A:PRA_A).l                    ;DSKTRACK0?
0000086e        beq.b       LAB_00000880
00000870        moveq       0x3,D0
            ;Decrease track number.
00000872        moveq       -0x1,D1
00000874        bsr.w       drive_step_head
00000878        dbf         D2w,LAB_00000866
            ;Moved 85 tracks, still not there.
0000087c        moveq       30,D0
0000087e        bra.b       LAB_00000890
            ;Head is at track zero.
            ;
            ;Zero the track number in `drives`.
            LAB_00000880:
00000880        move.w      (-0x24,A6),D0w                          ;Drive number.
00000884        add.w       D0w,D0w
00000886        lea         (0xb4,PC)=>drives,A0
0000088a        clr.w       (0x0,A0,D0w*0x1)=>drives
            ;Return 0 on success.
0000088e        moveq       0x0,D0
            LAB_00000890:
00000890        movem.l     SP=>local_4,{  D2}
00000894        rts

            ;* Direction to move head comes from sign of D1.
            drive_step_head:
00000896        move.l      D0,-(SP)=>local_4
00000898        bsr.w       drive_get_flags
            ;If D1 is positive, increase track number, else decrease track number.
0000089c        tst.b       D1b
0000089e        bmi.b       LAB_000008a4
000008a0        bclr.l      0x1,D0
            ;Strobe DSKSTEP to step the head...
            LAB_000008a4:
000008a4        bclr.l      0x0,D0
000008a8        move.b      D0b,(8250-B:PRB_B).l
000008ae        bset.l      0x0,D0
000008b2        move.b      D0b,(8250-B:PRB_B).l
000008b8        move.l      (SP)+,D0
            ;and wait for the movement.
000008ba        bsr.w       wait
000008be        rts

            drive_set_side:
000008c0        bsr.w       drive_get_flags
000008c4        move.b      D0b,(8250-B:PRB_B).l
000008ca        rts

            ;* Set up the flags to use for a seek (either to a side or
            ;* a track).
            ;*
            ;* Read PB from CIA B to get DSKMOTOR, set DSKSEL? based
            ;* on current disk, and DSKSIDE from the `drives` array.
            ;*
            ;* Returns flags in D0.
            drive_get_flags:
000008cc        movem.w     {  D2w D1w},SP
000008d0        move.w      (-0x24,A6),D0w                          ;Drive number
000008d4        move.b      (8250-B:PRB_B).l,D2b                    ;Read current PRB_B.
            ;Set all bits so that only DSKMOTOR remains.
000008da        ori.b       0x7f,D2b
000008de        addi.b      0x3,D0b
000008e2        bclr.l      D0,D2                                   ;Select drive.
            ;Index into `drives` array.
000008e4        subi.b      0x3,D0b
000008e8        add.w       D0w,D0w
000008ea        move.w      (drives,PC,D0w*0x1),D1w
            ;Bit zero means upper head, reset DSKSIDE.
000008ee        btst.l      0x0,D1
000008f2        beq.b       LAB_000008f8
000008f4        bclr.l      0x2,D2
            LAB_000008f8:
000008f8        move.b      D2b,D0b
000008fa        movem.w     SP=>local_8,{  D1 D2}
000008fe        rts

            ;* Takes a number of timeouts to wait for in D0.
            wait:
            ;Kick off the timer.
00000900        bsr.w       start_timer
            ;Wait until the timer is not running (has completed).
            LAB_00000904:
00000904        btst.b      0x0,(8250-B:CRA_B).l
0000090c        bne.b       LAB_00000904
            ;And loop until done.
0000090e        subq.l      0x1,D0
00000910        bne.b       wait
00000912        rts

            ;* Takes the number of timeouts to try in D0.
            try_continue_timer:
            ;If timer's already running, return.
00000914        btst.b      0x0,(8250-B:CRA_B).l
0000091c        bne.b       LAB_0000093a
            ;If not running, decrement the counter and restart it if counter's non-zero.
            ;Otherwise, we're done.
0000091e        subq.l      0x1,D0
00000920        beq.b       LAB_0000093a
            ;Fall through!

            start_timer:
            ;Timer A: Stop timer, PB6 normal operation, pulse, one-shot.
00000922        move.b      #0x8,(8250-B:CRA_B).l
            ;716 cycles = 1 millisecond, but counts pairs of ticks, so unit is 2ms?
0000092a        move.b      #0xCC,(8250-B:TALO_B).l                 ;Timer A low byte.
            ;NB: A write to TAHI kicks off the one-shot counter.
00000932        move.b      #0x2,(8250-B:TAHI_B).l                  ;Timer A high byte.
            LAB_0000093a:
0000093a        rts

            ;One entry per drive.
            ;Bit zero is set for upper head.
            ;Track number is value >> 1.
            drives:
0000093c        dw[4]

            ;Stack
00000944        db[1020]
