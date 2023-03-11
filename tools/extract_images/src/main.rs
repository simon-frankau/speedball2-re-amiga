//
// Image extractor
//
// Extract bit-planed Amiga images.
//

use std::fs;
use std::path::Path;

use image::RgbImage;

// Game seems to use 5-bit images.
const DEPTH: usize = 5;

// 32 colour palette
const PALETTE_SIZE: usize = 1 << DEPTH;

const PALETTE_ADDRS: [(usize, &str); 2] = [(0x0000f2, "palette_game"), (0x000132, "palette_mgmt")];

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


fn extract_set(data: &[u8], offset: usize, w: usize, h: usize, count: usize, palette: &[u8]) -> Image {
    let available_bits = (data.len() - offset) * 8;
    let available = available_bits / (w * h * DEPTH);
    let count = count.min(available);
    
    let mut img = Image::new(w, h * count, build_palette(palette));
    let data = &data[offset..];
    for (idx, block) in data.chunks_exact(w * h * DEPTH / 8).enumerate().take(count) {
        draw_image(block, w, h, DEPTH, &mut img, 0, idx * h);
    }

    img
}

/* Images (locations in RAM, not file):
0x173ca-0x1beca: 96 x 64 x 5 - 4 monitor images
0x5ae00-0x5c840: 16x16 font
 */

// Sizes tried: Widths: 96, 32, 48, 320, 256

fn main() -> anyhow::Result<()> {
    let data = fs::read("../unpack/out/unpacked.bin")?;

    fs::create_dir_all(OUT_DIR)?;

    let img_data = &data;
    for (palette_addr, palette_name) in PALETTE_ADDRS.iter() {
        println!("Running for palette {}", palette_name);
        let palette = &data[*palette_addr - IMAGE_BASE..];
	// Monitor images
//        let img = extract_set(img_data, 0x173CA - IMAGE_BASE, 96, 64, 10, palette);
	// Font
	let img = extract_set(img_data, 0x5ae00 - IMAGE_BASE, 16, 16, 42, palette);
        img.save(Path::new(
            format!("{}/extract-{}.png", OUT_DIR, palette_name).as_str(),
        ))?;
    }

    Ok(())
}
