#!/bin/sh
dd if=../bits/speedball2.adf of=../overlays/boot_block.bin bs=512 skip=0x000 count=0x2
dd if=../bits/speedball2.adf of=../overlays/second-level.bin bs=512 skip=0x002 count=0x5
dd if=../bits/speedball2.adf of=../overlays/main.bin bs=512 skip=0x016 count=0x258
dd if=../bits/speedball2.adf of=../overlays/overlay_dir.bin bs=512 skip=0x26e count=0x1
dd if=../bits/speedball2.adf of=../overlays/overlay_00.bin bs=512 skip=0x26f count=0xd8
dd if=../bits/speedball2.adf of=../overlays/overlay_01_full.bin bs=512 skip=0x347 count=0x13f
# Overlapping part truncated
dd if=../bits/speedball2.adf of=../overlays/overlay_01.bin bs=512 skip=0x347 count=0x3a
dd if=../bits/speedball2.adf of=../overlays/overlay_02.bin bs=512 skip=0x381 count=0x36
dd if=../bits/speedball2.adf of=../overlays/overlay_03.bin bs=512 skip=0x3b7 count=0x3
dd if=../bits/speedball2.adf of=../overlays/overlay_04.bin bs=512 skip=0x3bb count=0xb
dd if=../bits/speedball2.adf of=../overlays/overlay_05.bin bs=512 skip=0x3c7 count=0x4
dd if=../bits/speedball2.adf of=../overlays/overlay_06.bin bs=512 skip=0x3cc count=0x5
dd if=../bits/speedball2.adf of=../overlays/overlay_07.bin bs=512 skip=0x3d1 count=0x2
dd if=../bits/speedball2.adf of=../overlays/overlay_08.bin bs=512 skip=0x3d3 count=0x5
dd if=../bits/speedball2.adf of=../overlays/overlay_09.bin bs=512 skip=0x3d8 count=0x28
dd if=../bits/speedball2.adf of=../overlays/overlay_10.bin bs=512 skip=0x400 count=0x2e
dd if=../bits/speedball2.adf of=../overlays/overlay_11.bin bs=512 skip=0x42f count=0x56
dd if=../bits/speedball2.adf of=../overlays/overlay_12.bin bs=512 skip=0x486 count=0x36
dd if=../bits/speedball2.adf of=../overlays/overlay_13.bin bs=512 skip=0x4bc count=0x2c
dd if=../bits/speedball2.adf of=../overlays/overlay_14.bin bs=512 skip=0x4e8 count=0x20
dd if=../bits/speedball2.adf of=../overlays/overlay_15.bin bs=512 skip=0x508 count=0x20
dd if=../bits/speedball2.adf of=../overlays/overlay_16.bin bs=512 skip=0x528 count=0x20
dd if=../bits/speedball2.adf of=../overlays/overlay_17.bin bs=512 skip=0x548 count=0x20
dd if=../bits/speedball2.adf of=../overlays/overlay_18_full.bin bs=512 skip=0x568 count=0xae
# Overlapping parts truncated
dd if=../bits/speedball2.adf of=../overlays/overlay_18.bin bs=512 skip=0x568 count=0x5
dd if=../bits/speedball2.adf of=../overlays/overlay_19.bin bs=512 skip=0x56d count=0x3
dd if=../bits/speedball2.adf of=../overlays/overlay_20.bin bs=512 skip=0x570 count=0x5
dd if=../bits/speedball2.adf of=../overlays/overlay_21.bin bs=512 skip=0x575 count=0x8
dd if=../bits/speedball2.adf of=../overlays/overlay_22.bin bs=512 skip=0x57e count=0x78
dd if=../bits/speedball2.adf of=../overlays/overlay_23.bin bs=512 skip=0x5f6 count=0xa
dd if=../bits/speedball2.adf of=../overlays/overlay_24.bin bs=512 skip=0x600 count=0x5
dd if=../bits/speedball2.adf of=../overlays/overlay_25.bin bs=512 skip=0x605 count=0x10
dd if=../bits/speedball2.adf of=../overlays/overlay_26.bin bs=512 skip=0x616 count=0x75
dd if=../bits/speedball2.adf of=../overlays/overlay_27.bin bs=512 skip=0x68b count=0x16
dd if=../bits/speedball2.adf of=../overlays/overlay_28.bin bs=512 skip=0x6a1 count=0x1c
dd if=../bits/speedball2.adf of=../overlays/crack_.bin bs=512 skip=0x6bd count=0x23