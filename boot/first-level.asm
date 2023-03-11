            ;These fields are in the disk image, but not necessarily RAM.
            ;For example, address 4 is taken over by the IExec pointer.
00000000        char[4]     "DOS"                                   ;ID
00000004        long        3344D80Fh                               ;Checksum
00000008        long        0h                                      ;Rootblock
            ;Boot code starts here
            entry:
0000000c        movea.l     A1,A4
0000000e        bsr.w       run_intro                               ;undefined run_intro()
00000012        nop
            ;Set trap #0 vector to following routine, and trigger interrupt.
00000014        lea         (0xa,PC)=>ivec,A0
00000018        move.l      A0,(00000080).l
0000001e        trap        0x0

            ;Interrupt goes to here.
            ivec:
00000020        move.w      #0x1a0,(DMACON).l                       ;Disable bitplane, copper, sprite DMA.
00000028        move.w      #0x0,(COLOR_TABLE_0).l                  ;Set color 0 to black.
00000030        clr.b       (0000001c).l                            ;Clear TRAPV exception handler, used as a memory status flag
00000036        move.l      #0xc8000,D7
0000003c        move.l      D7,D0                                   ;Request 0xc8000 bytes - 800kB
0000003e        move.l      #0x10002,D1                             ;MEMF_CLEAR | MEMF_CHIP
00000044        jsr         -198,A6                                 ;AllocMem
00000048        tst.l       D0
0000004a        beq.b       LAB_00000060
            ;Successful allocation of 800kB.
0000004c        move.l      #0x100000,(00000028).l                  ;1M in 0x28.
00000056        move.b      #0x1,(0000001c).l                       ;1 in 0x1c.
0000005e        bra.b       LAB_000000a2
            ;Failure to allocate 800kB RAM.
            LAB_00000060:
00000060        move.l      #0x6fc00,D7
00000066        move.l      D7,D0                                   ;Request 0x6fc00 bytes - 447kB
00000068        move.l      #0x10004,D1                             ;MEMF_CLEAR | MEMF_FAST
0000006e        jsr         -198,A6                                 ;AllocMem
00000072        tst.l       D0
00000074        beq.b       LAB_00000084
            ;Successful allocation of 447kB.
            ;
            ;Put 2 in 0x1c.
00000076        move.b      #0x2,(0000001c).l
            ;Add 0x6fc00 to D0, so it points to end of allocation.
0000007e        addi.l      0x6fc00,D0
            LAB_00000084:
00000084        move.l      D0,(00000028).l                         ;End of allocation or zero on failure into 0x28.
0000008a        move.l      #0x19000,D7
00000090        move.l      D7,D0                                   ;Request 0x19000 - 100kB
00000092        move.l      #0x10002,D1                             ;MEMF_CLEAR | MEMF_CHIP
00000098        jsr         -198,A6                                 ;AllocMem
0000009c        tst.l       D0
0000009e        beq.w       LAB_000000ac
            ;Successful chip memory allocation of some size, in D0.
            LAB_000000a2:
000000a2        movea.l     D0,A5
000000a4        move.l      D0,(00000084).l                         ;Stash the address at 0x84.
000000aa        bra.b       LAB_000000c4

            ;Failure to allocate 100kB.
            ;
            ;Give up and reboot.
            LAB_000000ac:
000000ac        jsr         -0x78,A6                                ;InitStruct
000000b0        jsr         -0x96,A6                                ;FindResident
000000b4        move.l      #0x4e704ef9,(00000000).l                ;Write "RESET" instruction to 0x00000000.
000000be        jmp         00000000                                ;Jump to it.

            ;Some RAM allocated. Do stuff.
            ;
            ;Assume 800Kb allocated:
            ; * 1 in 0x1c (4 if 447kB of chip RAM allocated, 0 if none).
            ; * 1M in 0x28 (end of chip RAM if 447kB allocated).
            ; * Address address of chip memory in 0x84.
            ; * Disk device in A4.
            ; * Allocation address in A5 (same as 0x84).
            LAB_000000c4:
000000c4        move.l      #0x1,(0x24,A4)                          ;Motor on.
000000cc        move.w      #0x9,(0x1c,A4)                          ;TD_MOTOR
000000d2        movea.l     A4,A1
000000d4        movea.l     (00000004).l,A6                         ;Load IExec into A6.
000000da        jsr         -456,A6                                 ;DoIO
000000de        move.l      #0xa00,(0x24,A4)                        ;Load 2560 bytes (5 sectors).
000000e6        movea.l     (00000084).l,A1
000000ec        move.l      A1,(0x28,A4)                            ;To the start of the chip memory allocation
000000f0        move.w      #0x2,(0x1c,A4)                          ;CMD_READ
000000f6        move.l      #0x600,(0x2c,A4)                        ;Block offset 0x600 (sector 3).
000000fe        movea.l     (00000004).l,A6                         ;Move IExec into A6.
00000104        movea.l     A4,A1
00000106        movea.l     A5,A0
00000108        jsr         -456,A6                                 ;DoIO
0000010c        movea.l     (00000084).l,A0                         ;And jump to the start of it.
00000112        jmp         A0

00000114        ds          "SPEEDBALL II  COPYRIGHT 90/91 THE BI...
00000177        ds          "SPEEDBALL II  COPYRIGHT 90/91 THE BI...
000001da        ds          "SPEEDBALL II  COPYRIGHT 90/91 THE BI...
0000023d        ds          "SPEEDBALL II  COPYRIGHT 90/91 THE BI...
000002a0        char[96]    "SPEEDBALL II  COPYRIGHT 90/91 THE BI...

            ;************************************************************************************************
            ;*  This routine, part of the disk crack, loads and runs the intro located in the final 35      *
            ;*  sectors of the disk.                                                                        *
            ;*                                                                                              *
            ;*  I do not bother reversing the intro.                                                        *
            ;************************************************************************************************
            run_intro:
00000300        movem.l     {  A6 A5 A4 A3 A...,SP
00000304        move.l      #intro,(0x28,A1)                        ;Destination
0000030c        move.l      #0xd7a00,(0x2c,A1)                      ;Block offset: Track 78, sector 9.
00000314        move.l      #0x4600,(0x24,A1)                       ;# bytes to read - 35 sectors worth, takes us to the end of disk.
0000031c        jsr         -456,A6                                 ;DoIO: Perform the read.
00000320        jsr         intro                                   ;undefined intro()
00000326        movem.l     SP=>local_3c,{ D0 D1 D2 D3 D4 D5 D6 D...
0000032a        movea.l     (00000004).w,A6                         ;Restore IExec from address 4 into A6.
0000032e        rts

00000330        ds          "HERS\r\rV1.00  VERSION 07:01:91\rSER...
00000366        ds          "SPEEDBALL II  COPYRIGHT 90/91 THE BI...
000003c9        char[55]    "SPEEDBALL II  COPYRIGHT 90/91 THE BI...
