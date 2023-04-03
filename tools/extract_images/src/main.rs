//
// Image extractor
//
// Extract bit-planed Amiga images.
//

use std::fs;
use std::path::Path;

use image::RgbImage;

// Game seems to go up to 5-bit images.
const MAX_DEPTH: usize = 5;

// 32 colour palette
const PALETTE_SIZE: usize = 1 << MAX_DEPTH;

const PALETTE_ADDRS: [(usize, &str); 2] = [(0x0000f2, "game"), (0x000132, "mgmt")];

// Memory locations don't match file locations, since image is loaded
// at 0x84.
const IMAGE_BASE: usize = 0x84;

const OUT_DIR: &str = "out";

////////////////////////////////////////////////////////////////////////
// Cheap wrapper around the image we're producing.
//

struct Image {
    width: usize,
    height: usize,
    data: Vec<u8>,
    palette: Vec<(u8, u8, u8)>,
}

impl Image {
    fn new(width: usize, height: usize, palette: Vec<(u8, u8, u8)>) -> Image {
        Image {
            width,
            height,
            data: vec![192; width * height * 3],
            palette,
        }
    }

    fn set_pixel(&mut self, x: usize, y: usize, value: u8) {
        let idx = (y * self.width + x) * 3;
        let (r, g, b) = self.palette[value as usize];
        self.data[idx] = r;
        self.data[idx + 1] = g;
        self.data[idx + 2] = b;
    }

    fn save(&self, path: &Path) -> anyhow::Result<()> {
        let img =
            RgbImage::from_vec(self.width as u32, self.height as u32, self.data.clone()).unwrap();
        img.save(path)?;
        Ok(())
    }
}

////////////////////////////////////////////////////////////////////////
// Draw a bit-plane image.
//

fn draw_image(
    data: &[u8],
    w: usize,
    h: usize,
    depth: usize,
    target: &mut Image,
    x_off: usize,
    y_off: usize,
) {
    fn bit_at(data: &[u8], bit_addr: usize) -> bool {
        data[bit_addr >> 3] & (1 << (7 - (bit_addr & 7))) != 0
    }

    let plane_size = w * h;

    fn slice_at(data: &[u8], depth: usize, plane_size: usize, bit_addr: usize) -> u8 {
        let mut colour = 0;
        for i in 0..depth {
            let bit = bit_at(data, bit_addr + i * plane_size);
            colour >>= 1;
            if bit {
                colour += 1 << (depth - 1);
            }
        }
        colour
    }

    for x in 0..w {
        for y in 0..h {
            let bit_addr = y * w + x;
            let colour = slice_at(data, depth, plane_size, bit_addr);
            target.set_pixel(x + x_off, y + y_off, colour);
        }
    }
}

////////////////////////////////////////////////////////////////////////
// Entry point
//

fn extract_colour(data: &[u8]) -> (u8, u8, u8) {
    // 3-bit RGB values.
    let r = data[0] & 0xf;
    let g = data[1] >> 4;
    let b = data[1] & 0xf;

    (r * 0x11, g * 0x11, b * 0x11)
}

// Build a palette from a piece of memory.
fn build_palette(data: &[u8]) -> Vec<(u8, u8, u8)> {
    data.chunks(2)
        .take(PALETTE_SIZE)
        .map(|v| extract_colour(v))
        .collect()
}

fn extract_set(
    name: &str,
    data: &[u8],
    offset: usize,
    w: usize,
    h: usize,
    depth: usize,
    count: usize,
    palette: &[u8],
) -> Image {
    let available_bits = (data.len() - offset) * 8;
    let available = available_bits / (w * h * depth);
    let count = count.min(available);

    if w * h * depth * count != available_bits {
        eprintln!(
            "{}: Used 0x{:06x} vs. 0x{:06x} bytes",
            name,
            w * h * depth * count / 8,
            available_bits / 8
        );
    }

    let mut img = Image::new(w, h * count, build_palette(palette));
    let data = &data[offset..];
    for (idx, block) in data.chunks_exact(w * h * depth / 8).enumerate().take(count) {
        draw_image(block, w, h, depth, &mut img, 0, idx * h);
    }

    img
}

struct Block<'a> {
    file_name: &'a str,
    palette: &'a str,
    start: usize,
    end: usize,
    width: usize,
    height: usize,
    depth: usize,
}

const BLOCKS: [Block; 24] = [
    // Monitor screeens.
    Block {
        file_name: "unpacked.bin",
        palette: "game",
        start: 0x17346,
        end: 0x1af46,
        width: 96,
        height: 64,
        depth: 5,
    },
    // 16x16 title sequence font. TODO: What palette?
    Block {
        file_name: "unpacked.bin",
        palette: "mgmt",
        start: 0x5ad9c,
        end: 0x5c91c,
        width: 16,
        height: 16,
        depth: 5,
    },
    // Blank at end of file.
    Block {
        file_name: "unpacked.bin",
        palette: "mgmt",
        start: 0x5c91c,
        end: 0x5c99c,
        width: 16,
        height: 1,
        depth: 1,
    },
    // Start of the file is just music.
    Block {
        file_name: "overlay_00.bin",
        palette: "mgmt",
        start: 0x0,
        end: 0x1b000,
        width: 32,
        height: 1,
        depth: 1,
    },
    // The chunk at the end is the status bar.
    Block {
        file_name: "overlay_00.bin",
        palette: "game",
        start: 0x1A598,
        end: 0x1af98,
        width: 320,
        height: 16,
        depth: 4,
    },
    // Blank at end of file.
    Block {
        file_name: "overlay_00.bin",
        palette: "game",
	start: 0x1af98,
	end: 0x1b000,
        width: 16,
        height: 1,
        depth: 1,
    },
    // 0x0000-0x756e is compressed IFF of menu backdrop.
    Block {
        file_name: "overlay_01_full.bin",
        palette: "none",
        start: 0x0,
        end: 0x756e,
        width: 1,
        height: 1,
        depth: 1,
    },
    // Management screen backdrop, management palette.
    Block {
        file_name: "overlay_01_full.bin",
        palette: "mgmt",
        start: 0x756e,
        end: 0xe18e,
        width: 16,
        height: 16,
        depth: 5,
    },
    // Small characters.
    Block {
        file_name: "overlay_01_full.bin",
        palette: "mgmt",
        start: 0xe18e,
        end: 0xe986,
        width: 8,
        height: 8,
        depth: 5,
    },
    // 16x16 characters for menu. TODO: Palette might need to be stolen from backdrop IFF?
    Block {
        file_name: "overlay_01_full.bin",
        palette: "mgmt",
        start: 0xe986,
        end: 0x10146,
        width: 16,
        height: 16,
        depth: 5,
    },
    // Various 8x8 fonts. Palette clearly incorrect in places, but I'm
    // not sure what the alternatives are...
    Block {
        file_name: "overlay_01_full.bin",
        palette: "mgmt",
        start: 0x10146,
        end: 0x119a6,
        width: 8,
        height: 8,
        depth: 5,
    },
    // Management screen lights.
    Block {
        file_name: "overlay_01_full.bin",
        palette: "mgmt",
        start: 0x119a6,
        end: 0x123a6,
        width: 16,
        height: 16,
        depth: 5,
    },
    // Management screen: Buttons, armour.
    Block {
        file_name: "overlay_01_full.bin",
        palette: "mgmt",
        start: 0x123a6,
        end: 0x1d026,
        width: 32,
        height: 32,
        depth: 5,
    },
    // 16x16 chunks of face.
    Block {
        file_name: "overlay_01_full.bin",
        palette: "mgmt",
        start: 0x1d026,
        end: 0x25726,
        width: 16,
        height: 16,
        depth: 4,
    },
    // 16x16 chunks of group icons
    Block {
        file_name: "overlay_01_full.bin",
        palette: "mgmt",
        start: 0x25726,
        end: 0x27346,
        width: 16,
        height: 16,
        depth: 5,
    },
    // TODO: Some data at end of file?
    Block {
        file_name: "overlay_01_full.bin",
        palette: "mgmt",
        start: 0x27346,
        end: 0x27e00,
        width: 16,
        height: 1,
        depth: 1,
    },
    // Small in-game sprites.
    Block {
        file_name: "overlay_18_full.bin",
        palette: "game",
        start: 0,
        end: 0x2c80,
        width: 16,
        height: 16,
        depth: 4,
    },
    // Main character sprites (includes medidroid, large ball).
    Block {
        file_name: "overlay_18_full.bin",
        palette: "game",
        start: 0x2c80,
        end: 0x13a80,
        width: 32,
        height: 32,
        depth: 4,
    },
    // Bouncers, ball launcher.
    Block {
        file_name: "overlay_18_full.bin",
        palette: "game",
        start: 0x13a80,
        end: 0x15b00,
        width: 32,
        height: 32,
        depth: 5,
    },
    // Blank area at end of file.
    Block {
        file_name: "overlay_18_full.bin",
        palette: "game",
        start: 0x15b00,
        end: 0x15c00,
        width: 32,
        height: 32,
        depth: 1,
    },
    // Arena tiles.
    Block {
        file_name: "overlay_26.bin",
        palette: "game",
        start: 0,
        end: 0xe9c0,
        width: 16,
        height: 16,
        depth: 5,
    },
    // Blank are at end of file.
    Block {
        file_name: "overlay_26.bin",
        palette: "game",
        start: 0xe9c0,
        end: 0xea00,
        width: 32,
        height: 1,
        depth: 1,
    },
    // Data?
    Block {
        file_name: "overlay_27.bin",
        palette: "game", // TODO
        start: 0,
        end: 0x2c00,
        width: 32,
        height: 1,
        depth: 1,
    },
    // Data?
    Block {
        file_name: "overlay_28.bin",
        palette: "game", // TODO
        start: 0,
        end: 0x3800,
        width: 32,
        height: 1,
        depth: 1,
    },
];

fn main() -> anyhow::Result<()> {
    // let data = fs::read("../unpack/out/unpacked.bin")?;
    let palette_source = fs::read("../unpack/out/unpacked.bin")?;

    fs::create_dir_all(OUT_DIR)?;

    for (palette_addr, palette_name) in PALETTE_ADDRS.iter() {
        println!("Running for palette {}", palette_name);
        let palette = &palette_source[*palette_addr - IMAGE_BASE..];

        for block in BLOCKS.iter() {
            if *palette_name != block.palette {
                continue;
            }

            let data = fs::read(&format!("../../overlays/{}", block.file_name))?;
            let data = if block.end > 0 {
                &data[..block.end]
            } else {
                &data
            };
            let data = if block.start > 0 {
                &data[block.start..]
            } else {
                &data
            };

            let img = extract_set(
                block.file_name,
                &data,
                0x0,
                block.width,
                block.height,
                block.depth,
                1000000,
                palette,
            );
            img.save(Path::new(
                format!(
                    "{}/{}-{:06x}-{:06x}.png",
                    OUT_DIR, block.file_name, block.start, block.end
                )
                .as_str(),
            ))?;
        }
    }

    Ok(())
}
