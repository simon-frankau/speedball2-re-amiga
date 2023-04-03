//
// IFF image extractor
//
// Extract an image stored in IFF format. Understands BMHD, CMAP and
// BODY.
//
// Zero error handling as I am very lazy.
//

use image::RgbImage;

use std::fs;
use std::path::Path;
use std::str;

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
// IFF-handling
//

fn to_fourcc(data: &[u8]) -> &str {
    str::from_utf8(&data[..4]).unwrap_or("")
}

fn to_u32(data: &[u8]) -> u32 {
    (data[0] as u32) << 24 | (data[1] as u32) << 16 | (data[2] as u32) << 8 | (data[3] as u32)
}

fn to_u16(data: &[u8]) -> u16 {
    (data[0] as u16) << 8 | (data[1] as u16)
}

fn find_chunk<'a>(data: &'a [u8], fourcc: &str) -> &'a [u8] {
    let mut p = data;
    loop {
        assert!(p.len() >= 8, "Chunk {} not found", fourcc);
        let this_fourcc = to_fourcc(p);
        println!("  Chunk {}", this_fourcc);
        if this_fourcc == fourcc {
            return p;
        }
        // Round length up.
        let len = to_u32(&p[4..]) + 1 & !1;
        p = &p[len as usize + 8..];
    }
}

fn get_cmap(data: &[u8]) -> Vec<(u8, u8, u8)> {
    let v = &data[8..][..to_u32(&data[4..]) as usize];
    v.chunks_exact(3).map(|v| (v[0], v[1], v[2])).collect()
}

fn decompress(data: &[u8]) -> Vec<u8> {
    let mut data = &data[8..][..to_u32(&data[4..]) as usize];
    let mut v = Vec::new();
    while data.len() > 0 {
	let x = data[0];
	if x < 128 {
	    v.extend(data[1..][..x as usize + 1].iter());
	    data = &data[x as usize + 2..];
	} else if x > 128 {
	    let c = data[1];
	    for _i in 0..(257 - x as usize) {
		v.push(c);
	    }
	    data = &data[2..];
	}
    }
    v
}


fn pixel_at(data: &[u8], width: usize, _height: usize, n_planes: usize, x: usize, y: usize) -> u8 {
    let line_stride = width * n_planes;
    let mut addr = y * line_stride + x;

    let mut value = 0;
    for _ in 0..n_planes {
	let bit = (data[addr >> 3] << (addr & 7)) >> 7;
	value = (value | bit << n_planes) >> 1;
	addr += width;
    }
    value
}

fn decode(data: &[u8]) -> Option<Image> {
    let form_type = to_fourcc(data);
    println!(" FORM type: {}", form_type);

    if form_type != "ILBM" && form_type != "PBM " {
        return None;
    }

    let bmhd = find_chunk(&data[4..], "BMHD");
    let cmap = find_chunk(bmhd, "CMAP");
    let body = find_chunk(cmap, "BODY");

    let (width, height) = (to_u16(&bmhd[8..]) as usize, to_u16(&bmhd[10..]) as usize);
    let n_planes = bmhd[16] as usize;
    let palette = get_cmap(cmap);
    // Like the decoder in the SB2 binary, we're assuming compressed,
    // not checking the BMHD flags.
    let image_data = decompress(body);

    println!("  {}x{}, {} planes", width, height, n_planes);
    let mut image = Image::new(width, height, palette);
    for y in 0..height {
        for x in 0..width {
            image.set_pixel(x, y, pixel_at(&image_data, width, height, n_planes, x, y));
        }
    }
    Some(image)
}

fn main() -> anyhow::Result<()> {
    fs::create_dir_all(OUT_DIR)?;

    for file in ["../../in/speedball2-cls.adf", "../../overlays/unpacked.bin"] {
	let data = fs::read(file)?;

	for (idx, window) in data.windows(8).enumerate() {
            let fourcc = to_fourcc(window);
            let len = to_u32(&window[4..]);
            // Plausible form?
            if fourcc == "FORM" && len < data.len() as u32 {
		println!("FORM at offset 0x{:x}, length 0x{:x}", idx, len);
		if let Some(image) = decode(&data[idx + 8..][..len as usize]) {
                    image.save(Path::new(format!("{}/iff-{:x}.png", OUT_DIR, idx).as_str()))?;
		}
            }
	}
    }

    Ok(())
}
