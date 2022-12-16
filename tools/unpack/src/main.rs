//
// Screen displayer
//
//
// Pulls a static screen structure from the Speedball 2 ROM and
// converts it into an image file. Understands the specific structure
// used, with a palette, tile map, and set of cells.
//

use std::fs;
use std::path::Path;
use std::str;

const OUT_DIR: &str = "out";

// Memory image starts 22 sectors into the disk image.
const DISK_OFFSET: usize = 22 * 512;
// Unpackable region starts 10 bytes into the memory image.
const MEM_OFFSET: usize = 10;
// Packed length in image.
const PACKED_LEN: usize = 0x48814;

////////////////////////////////////////////////////////////////////////
// Main algorithm
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

fn decompress(data: &[u8]) -> Vec<u8> {
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
        println!("Copying {} bytes from history ({} vs {})", len, distance, d.output.len());
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

fn main() -> anyhow::Result<()> {
    let data = fs::read("../../speedball2.adf")?;
    fs::create_dir_all(OUT_DIR)?;
    let out_file_name = format!("{}/{}", OUT_DIR, "unpacked.bin");

    let unpackable_data = &data[DISK_OFFSET + MEM_OFFSET..][..PACKED_LEN];
    let decompressed = decompress(unpackable_data);

    fs::write(&Path::new(&out_file_name), &decompressed)?;
    
    Ok(())
}
