//
// Amiga Speedball 2 unpacker
//
// Takes a Speedball 2 ADF image "Speedball 2 - Brutal Deluxe
// (1990)(ImageWorks)[cr CLS - RZR]"
// https://www.planetemu.net/rom/commodore-amiga-games-adf/speedball-2-brutal-deluxe-1990-imageworks-cr-cls-rzr-3
// and unpacks it into memory.
//
// Also decodes "Speedball 2 - Brutal Deluxe (1990)(ImageWorks)[cr
// DC].adf" and "Speedball 2 - Brutal Deluxe (1990)(ImageWorks)[cr
// CSL].adf".
//

use std::fs;
use std::path::Path;
use std::str;

// Override these, if you need to!
const IN_FILE: &str = "../../in/speedball2-cls.adf";
const OUT_FILE: &str = "../../overlays/unpacked.bin";
const IN_TYPE: Crack = Crack::ByCLSRZR;

// Memory image starts 22 sectors into the disk image.
const DISK_OFFSET: usize = 22 * 512;
// Unpackable region starts 10 bytes into the memory image.
const MEM_OFFSET: usize = 10;
// Packed length in image.
const PACKED_LEN_CLS: usize = 0x48814;
// Length of area checksummed.
const CHECK_LEN: usize = 150000;

// Quick enum for the different kinds of crack we can unpack.
enum Crack {
    ByCLSRZR,
    ByDC,
    ByCSL,
}

////////////////////////////////////////////////////////////////////////
// Decompression algorithm for CLS RZR.
//

struct Decompressor {
    data: Vec<u8>,
    unpacked_length: usize,
    byte_offset: usize,
    bit_offset: usize,
    output: Vec<u8>,
}

impl Decompressor {
    fn new(data: &[u8]) -> Decompressor {
        let len_offset = data.len() - 4;
        let mut d = Decompressor {
            data: Vec::from(data),
            unpacked_length: 0,
            byte_offset: len_offset,
            bit_offset: 7,
            output: Vec::new(),
        };
        d.unpacked_length = d.long_at(len_offset);
        d.fudge();
        d
    }

    fn bit(&mut self) -> u8 {
        self.bit_offset += 1;
        if self.bit_offset == 8 {
            self.byte_offset -= 1;
            self.bit_offset = 0;
        }
        (self.data[self.byte_offset] >> self.bit_offset) & 1
    }

    fn bits(&mut self, n: usize) -> usize {
        let mut res = 0;
        for _ in 0..n {
            res = (res << 1) | self.bit() as usize;
        }
        res
    }

    fn long_at(&mut self, addr: usize) -> usize {
        (self.data[addr] as usize) << 24
            | (self.data[addr + 1] as usize) << 16
            | (self.data[addr + 2] as usize) << 8
            | (self.data[addr + 3] as usize)
    }

    fn fudge(&mut self) {
        // Horribly, the first long is not fully packed. We repack it
        // so that the leading one bit falls off the top of the long.
        let mut to_fudge = self.long_at(self.byte_offset - 4);
        // Push '1' bit to MSB.
        while to_fudge & 0x80000000 == 0 {
            to_fudge <<= 1;
            self.bit_offset += 1;
        }
        // And push it out.
        to_fudge <<= 1;
        self.bit_offset += 1;
        // Write the bytes back.
        self.data[self.byte_offset - 4] = ((to_fudge >> 24) & 0xff) as u8;
        self.data[self.byte_offset - 3] = ((to_fudge >> 16) & 0xff) as u8;
        self.data[self.byte_offset - 2] = ((to_fudge >> 8) & 0xff) as u8;
        self.data[self.byte_offset - 1] = (to_fudge & 0xff) as u8;
        // Convert excess bits to bytes.
        self.byte_offset -= self.bit_offset >> 3;
        self.bit_offset &= 7;
    }
}

fn decompress_cls(data: &[u8]) -> Vec<u8> {
    let mut d = Decompressor::new(data);

    fn copy_out(n: usize, d: &mut Decompressor) {
        println!("Reproducing {} bytes", n);
        for _ in 0..n {
            let byte = d.bits(8);
            d.output.push(byte as u8);
        }
    }

    fn var_dist_short(d: &mut Decompressor) -> usize {
        if d.bit() == 0 {
            d.bits(14)
        } else {
            d.bits(8)
        }
    }

    fn var_dist(d: &mut Decompressor) -> usize {
        if d.bit() == 0 {
            d.bits(16)
        } else if d.bit() == 0 {
            d.bits(12)
        } else {
            d.bits(8)
        }
    }

    fn copy_back(len: usize, distance: usize, d: &mut Decompressor) {
        println!(
            "Copying {} bytes from history ({} vs {})",
            len,
            distance,
            d.output.len()
        );
        for _ in 0..len {
            let val = d.output[d.output.len() - distance];
            d.output.push(val);
        }
    }

    println!("Upacked length: {}", d.unpacked_length);

    loop {
        let header = d.bits(3);
        println!("Emitted: {}", d.output.len());
        println!(
            "Header ({}@{:x}): {:x}",
            d.bit_offset, d.byte_offset, header
        );
        match header {
            // A non-zero verbatim copy header is /always/ followed by
            // lookback header (why would you ever do two verbatim
            // copies in a row? So, 0 does nothing, other values
            // trigger a verbatim copy, and then a lookback copy
            // always follows.
            0 => {}
            7 => {
                let ext_bit = d.bit();
                if ext_bit != 0 {
                    let mut n = d.bits(10);
                    if n == 0 {
                        n = d.bits(12);
                    }
                    copy_out(n, &mut d);
                } else {
                    let n = d.bits(4) + 7;
                    copy_out(n, &mut d);
                }
            }
            // 1-6 byte copy.
            i => {
                copy_out(i, &mut d);
            }
        }

        // Check for end.
        if d.byte_offset == 0 && d.bit_offset == 7 {
            // All bits have been read. As the start is not fully
            // packed, the end is precisely aligned to the bit.
            assert_eq!(d.output.len(), d.unpacked_length);
            break;
        }

        // Lookback step
        let copy_mode = d.bits(2);
        println!(
            "Lookback ({}@{:x}): {:x}",
            d.bit_offset, d.byte_offset, copy_mode
        );
        match copy_mode {
            0 => {
                let len = 2;
                let dist = d.bits(8);
                copy_back(len, dist, &mut d);
            }
            1 => {
                let len = 3;
                let dist = var_dist_short(&mut d);
                copy_back(len, dist, &mut d)
            }
            2 => {
                let len = 4;
                let dist = var_dist(&mut d);
                copy_back(len, dist, &mut d);
            }
            3 => {
                let copy_mode_ext = d.bits(2);
                match copy_mode_ext {
                    3 => {
                        let len = d.bits(8);
                        let dist = var_dist(&mut d);
                        copy_back(len, dist, &mut d);
                    }
                    2 => {
                        let len = d.bits(2) + 7;
                        let dist = var_dist(&mut d);
                        copy_back(len, dist, &mut d);
                    }
                    i => {
                        let len = i + 5;
                        let dist = var_dist(&mut d);
                        copy_back(len, dist, &mut d);
                    }
                }
            }
            _ => panic!("Can't happen"),
        }
    }

    d.output.reverse();

    d.output
}

// Perform the checksum done inside the Speedball 2 decompressor.
fn checksum(v: &[u8], n: usize) -> u16 {
    let mut sum: u16 = 0;
    let mut counter = n; 
    for val in v[..n].iter() {
        sum = sum.wrapping_add(*val as u16);
        sum = sum.rotate_left((counter + 1) as u32 & 7);
        counter -= 1;
    }
    sum
}

////////////////////////////////////////////////////////////////////////
// DC Decompressor
//

// Read a 16-bit little-endian value.
fn read16le<'a>(data: &'a [u8]) -> (u16, &'a [u8]) {
    let val = (data[0] as u16) | (data[1] as u16) << 8;
    let rest = &data[2..];
    (val, rest)
}

fn dc_inner(data: &[u8]) -> Vec<u8> {
    let mut d = data;
    let mut result = Vec::new();

    while !d.is_empty() {
        let op = d[0];
        d = &d[1..];

        if op & 0x80 == 0 {
            // Top bit not set: Copy bytes from input.
            result.extend(d[..op as usize].iter());
            d = &d[op as usize..];
            continue;
        }

        // Top bit set is a look-back. If op is 0xff, read a length
        // word, otherwise the low bits of op are the length.
        let len = if op == 0xff {
            let len;
            (len, d) = read16le(d);
            len as usize
        } else {
            (op & !0x80) as usize
        };

        // Read the start offset.
        let start;
        (start, d) = read16le(d);

        for index in 0..len {
            let source = result[start as usize + index];
            result.push(source);
        }
    }

    result
}

fn decompress_dc(data: &[u8]) -> Vec<u8> {
    let mut d = data;
    let mut result = Vec::new();

    loop {
        let segment_length;
        (segment_length, d) = read16le(d);
        if segment_length == 0 {
            break;
        }
        eprintln!("Seg len {}", segment_length);
        result.extend(dc_inner(&d[..segment_length as usize]));
        d = &d[segment_length as usize..];
    }

    result
}

////////////////////////////////////////////////////////////////////////
// Main function
//

fn main() -> anyhow::Result<()> {
    let data = fs::read(IN_FILE)?;

    let decompressed = match IN_TYPE {
	Crack::ByDC => {
            let unpackable_data = &data[DISK_OFFSET + MEM_OFFSET..];
            decompress_dc(unpackable_data)
	},
	Crack::ByCSL => {
            let unpackable_data = &data[DISK_OFFSET + MEM_OFFSET..];
            decompress_dc(unpackable_data)
	},
	Crack::ByCLSRZR => {
	    let unpackable_data = &data[DISK_OFFSET + MEM_OFFSET..][..PACKED_LEN_CLS];
            decompress_cls(unpackable_data)
	},
    };
    
    fs::write(&Path::new(OUT_FILE), &decompressed)?;
    println!("Checksum is 0x{:04x}", checksum(&decompressed, CHECK_LEN));
    Ok(())
}
