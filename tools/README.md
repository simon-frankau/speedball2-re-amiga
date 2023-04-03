# Speedball II reverse-engineering custom tools for Amiga

There are various Rust tools I've built here to pull out bits of the
Speedball II image:

 * `unpack` - The image loaded off disk is compressed, and needs to be
   unpacked before execution. A sensible person would just run the
   code in an emulator to get the uncompressed memory image, but I
   decided to decompress it externally. This is my implementation of
   the unpacker.
 * `extract_images` - Extract bitmapped images from the binary.
 * `extract_iff_images` - Extract ILBM files.
 * `make_label` - Generate Ghidra python to create labels for sounds
   that are accessed as offsets from sound_base.

If you want to pull the disk image apart yourself, first run
`./extract_overlays.sh` to pull out sections of the disk image
verbatim, and then run `unpack` to decompress the main binary
image. All the relevant parts will be placed into `../overlays`.

After that, you can run `extract_images` and `extract_iff_images`.

`make_label` would have been better off as a Python script for Ghidra,
but I like Rust and don't like Python!

TODO: `extract_images` seems to use sub-optimal palettes in places. I
think maybe some graphics use the palettes associated with ILBM
images.
