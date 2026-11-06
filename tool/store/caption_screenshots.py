#!/usr/bin/env python3
"""Adds App Store captions to the raw simulator screenshots.

Input: a folder of raw frames (build/store_screenshots/<set>/NN_name.png, the
exact App Store Connect pixel sizes). Output: the same sizes with a caption
band on top, the frame scaled below it with rounded corners, and a thin
"no ads / no internet / no accounts" strip at the bottom, in the order the
marketing review asks for (fill, lines, celebration, drawing, home, artworks,
gate). The first three frames are the ones a search result shows; a set
without a raw frame for one of them simply skips it.

    python3 tool/store/caption_screenshots.py build/store_screenshots/iphone61_tr tr
    python3 tool/store/caption_screenshots.py build/store_screenshots/iphone61_en en

Writes to <set>_captioned/ next to the input folder plus a contact sheet
(_contact.png) for a quick look. Needs Pillow. App Review 2.3.3 allows text
and touch overlays on screenshots as long as the UI is the real app.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

BACKGROUND = (255, 244, 230)  # the app's page colour, 0xFFFFF4E6
TEXT = (45, 49, 66)  # 0xFF2D3142, about 12:1 on the page colour
STRIP = (255, 213, 79)  # the home button yellow, 0xFFFFD54F

# Upload order -> (file prefix in the raw set, caption tr, caption en)
FRAMES = [
    ("02", "Dokun, hemen boyansın", "Tap and it fills"),
    ("03", "Boya çizgiden taşmaz", "Paint stays in the lines"),
    ("07", "Biten resim kutlanır", "Finish a page, get confetti"),
    ("05", "Fırçalar, çıkartmalar, ayna", "Brushes, stickers, mirror"),
    ("01", "9 kategori, 310 sayfa", "310 pages, 9 categories"),
    ("04", "Kendiliğinden kaydedilir", "Saves itself, nothing lost"),
    ("06", "Ayarlar ebeveyn kapısının ardında", "Settings behind a parent gate"),
]
STRIP_TEXT = {
    "tr": "Reklam yok  ·  İnternet yok  ·  Hesap yok",
    "en": "No ads  ·  No internet  ·  No accounts",
}

FONT_CANDIDATES = [
    ("/System/Library/Fonts/Avenir Next.ttc", "Bold"),
    ("/System/Library/Fonts/HelveticaNeue.ttc", "Bold"),
    ("/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf", None),
]


def load_font(size):
    for path, face in FONT_CANDIDATES:
        if not os.path.exists(path):
            continue
        if face is None:
            return ImageFont.truetype(path, size)
        for index in range(0, 16):
            try:
                font = ImageFont.truetype(path, size, index=index)
            except OSError:
                break
            if font.getname()[1] == face:
                return font
    raise SystemExit("no usable font found")


def wrap(draw, text, font, max_width):
    words = text.split()
    lines, line = [], ""
    for word in words:
        trial = f"{line} {word}".strip()
        if draw.textlength(trial, font=font) <= max_width or not line:
            line = trial
        else:
            lines.append(line)
            line = word
    lines.append(line)
    return lines


def rounded(image, radius):
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, image.width - 1, image.height - 1], radius=radius, fill=255)
    out = Image.new("RGBA", image.size, (0, 0, 0, 0))
    out.paste(image, (0, 0), mask)
    return out


def caption_frame(src, caption, strip_text):
    frame = Image.open(src).convert("RGB")
    width, height = frame.size
    scale = width / 1206  # metrics tuned on the required iPhone size
    canvas = Image.new("RGB", (width, height), BACKGROUND)
    draw = ImageDraw.Draw(canvas)

    # Caption band: 14% of the height, two lines at most, 84 px at 1206 wide.
    band_h = int(height * 0.14)
    font_size = int(84 * scale)
    font = load_font(font_size)
    lines = wrap(draw, caption, font, width - int(120 * scale))
    while len(lines) > 2 and font_size > int(56 * scale):
        font_size -= int(4 * scale)
        font = load_font(font_size)
        lines = wrap(draw, caption, font, width - int(120 * scale))
    line_h = int(font_size * 1.18)
    y = (band_h - line_h * len(lines)) // 2 + int(10 * scale)
    for line in lines:
        w = draw.textlength(line, font=font)
        draw.text(((width - w) / 2, y), line, font=font, fill=TEXT)
        y += line_h

    # Bottom strip: 4% of the height.
    strip_h = int(height * 0.045)
    strip_font = load_font(int(34 * scale))
    draw.rectangle([0, height - strip_h, width, height], fill=STRIP)
    sw = draw.textlength(strip_text, font=strip_font)
    draw.text(((width - sw) / 2, height - strip_h + (strip_h - int(34 * scale) * 1.1) / 2), strip_text, font=strip_font, fill=TEXT)

    # The frame itself, scaled to the room between band and strip.
    room_h = height - band_h - strip_h - int(40 * scale)
    ratio = min(room_h / height, (width - int(80 * scale)) / width)
    shot = frame.resize((int(width * ratio), int(height * ratio)), Image.LANCZOS)
    shot = rounded(shot, int(48 * scale))
    x = (width - shot.width) // 2
    y = band_h + (room_h - shot.height) // 2 + int(10 * scale)
    shadow = Image.new("RGBA", (shot.width + int(80 * scale), shot.height + int(80 * scale)), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [int(40 * scale), int(52 * scale), shot.width + int(40 * scale), shot.height + int(52 * scale)],
        radius=int(48 * scale), fill=(0, 0, 0, 60))
    shadow = shadow.filter(ImageFilter.GaussianBlur(int(22 * scale)))
    canvas.paste(shadow, (x - int(40 * scale), y - int(40 * scale)), shadow)
    canvas.paste(shot, (x, y), shot)
    return canvas


def main():
    if len(sys.argv) != 3 or sys.argv[2] not in STRIP_TEXT:
        raise SystemExit(__doc__)
    src_dir, lang = sys.argv[1].rstrip("/"), sys.argv[2]
    out_dir = f"{src_dir}_captioned"
    os.makedirs(out_dir, exist_ok=True)
    files = sorted(os.listdir(src_dir))
    made = []
    for index, (prefix, tr, en) in enumerate(FRAMES, start=1):
        match = [f for f in files if f.startswith(prefix + "_") and f.endswith(".png")]
        if not match:
            print(f"skip {prefix}: no raw frame")
            continue
        caption = tr if lang == "tr" else en
        out = caption_frame(os.path.join(src_dir, match[0]), caption, STRIP_TEXT[lang])
        name = f"{index:02d}_{match[0].split('_', 1)[1]}"
        out.save(os.path.join(out_dir, name), optimize=True)
        made.append(out)
        print(f"{name}: {out.size[0]}x{out.size[1]} '{caption}'")
    if made:
        thumb_h = 700
        thumbs = [m.resize((int(m.width * thumb_h / m.height), thumb_h), Image.LANCZOS) for m in made]
        sheet = Image.new("RGB", (sum(t.width for t in thumbs) + 20 * (len(thumbs) + 1), thumb_h + 40), (230, 230, 230))
        x = 20
        for t in thumbs:
            sheet.paste(t, (x, 20))
            x += t.width + 20
        sheet.save(os.path.join(out_dir, "_contact.png"))
        print(f"contact sheet: {os.path.join(out_dir, '_contact.png')}")


if __name__ == "__main__":
    main()
