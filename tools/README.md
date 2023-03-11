# Speedball II reverse-engineering custom tools for Amiga

 * `unpack` - The image loaded off disk is compressed, and needs to be
   unpacked before execution. A sensible person would just run the
   code in an emulator to get the uncompressed memory image, but I
   decided to decompress it externally. This is my implementation of
   the unpacker.
 * `extract_images` - Start of tooling to extract bitmapped images
   from the binary.
