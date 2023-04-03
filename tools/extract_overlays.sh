#!/bin/sh
set -e
mkdir -p ../overlays
dd if=../in/speedball2-cls.adf of=../overlays/boot_block.bin bs=512 skip=0x000 count=0x2
dd if=../in/speedball2-cls.adf of=../overlays/second-level.bin bs=512 skip=0x002 count=0x5
dd if=../in/speedball2-cls.adf of=../overlays/main.bin bs=512 skip=0x016 count=0x258
dd if=../in/speedball2-cls.adf of=../overlays/overlay_dir.bin bs=512 skip=0x26e count=0x1
dd if=../in/speedball2-cls.adf of=../overlays/overlay_00.bin bs=512 skip=0x26f count=0xd8
dd if=../in/speedball2-cls.adf of=../overlays/overlay_01.bin bs=512 skip=0x347 count=0x13f
dd if=../in/speedball2-cls.adf of=../overlays/overlay_12.bin bs=512 skip=0x486 count=0x36
dd if=../in/speedball2-cls.adf of=../overlays/overlay_13.bin bs=512 skip=0x4bc count=0x2c
dd if=../in/speedball2-cls.adf of=../overlays/overlay_14.bin bs=512 skip=0x4e8 count=0x20
dd if=../in/speedball2-cls.adf of=../overlays/overlay_15.bin bs=512 skip=0x508 count=0x20
dd if=../in/speedball2-cls.adf of=../overlays/overlay_16.bin bs=512 skip=0x528 count=0x20
dd if=../in/speedball2-cls.adf of=../overlays/overlay_17.bin bs=512 skip=0x548 count=0x20
dd if=../in/speedball2-cls.adf of=../overlays/overlay_18.bin bs=512 skip=0x568 count=0xae
dd if=../in/speedball2-cls.adf of=../overlays/overlay_26.bin bs=512 skip=0x616 count=0x75
dd if=../in/speedball2-cls.adf of=../overlays/overlay_27.bin bs=512 skip=0x68b count=0x16
dd if=../in/speedball2-cls.adf of=../overlays/overlay_28.bin bs=512 skip=0x6a1 count=0x1c
dd if=../in/speedball2-cls.adf of=../overlays/crack.bin bs=512 skip=0x6bd count=0x23

echo "Now run 'cd unpack && cargo run' to generate unpacked.bin."
