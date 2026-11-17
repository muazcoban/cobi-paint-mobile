#!/usr/bin/env python3
"""Google Play's two fixed graphics: the 512 px icon and the 1024x500 feature
graphic, in Turkish and English.

The icon is the App Store icon scaled down (Play wants 512x512, 32-bit PNG,
no rounded corners of its own: Play masks it). The feature graphic is the
icon on the left and the name with one line on the right, on the home
screen's yellow; Play shows it above the screenshots and in promotions, and
crops nothing from a 1024x500 image. No price, no "free", no ranking claims
(Play's metadata policy).

    python3 tool/store/play_graphics.py build/store_screenshots/play_graphics

Needs Pillow; uses the fonts of tool/store/caption_screenshots.py.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(__file__))
from caption_screenshots import TEXT, load_font, rounded  # noqa: E402

ICON = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"
YELLOW = (255, 213, 79)  # the home button yellow, 0xFFFFD54F
ORANGE = (255, 183, 77)
CREAM = (255, 244, 230)  # the app's page colour

TAGLINE = {
    "tr": "Küçük eller için boyama",
    "en": "Coloring for little hands",
}
STRIP = {
    "tr": "Reklam yok  ·  İnternet yok  ·  Hesap yok",
    "en": "No ads  ·  No internet  ·  No accounts",
}


def icon_512(out):
    Image.open(ICON).convert("RGBA").resize((512, 512), Image.LANCZOS).save(os.path.join(out, "icon_512.png"))


def feature_graphic(out, lang):
    width, height = 1024, 500
    canvas = Image.new("RGB", (width, height), YELLOW)
    # A soft diagonal from yellow to orange, and two cream circles behind.
    gradient = Image.linear_gradient("L").rotate(-35, expand=True).resize((width, height))
    canvas = Image.composite(Image.new("RGB", (width, height), ORANGE), canvas, gradient.point(lambda v: v * 0.55))
    draw = ImageDraw.Draw(canvas)
    draw.ellipse([-140, -180, 300, 260], fill=(255, 226, 130))
    draw.ellipse([780, 300, 1180, 700], fill=(255, 200, 110))

    # The icon with a soft shadow.
    size = 300
    icon = rounded(Image.open(ICON).convert("RGB").resize((size, size), Image.LANCZOS), 68)
    shadow = Image.new("RGBA", (size + 60, size + 60), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([30, 38, size + 30, size + 38], radius=68, fill=(120, 70, 0, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    x, y = 64, (height - size) // 2
    canvas.paste(shadow, (x - 30, y - 30), shadow)
    canvas.paste(icon, (x, y), icon)

    # The name, the line and the strip, left-aligned on the right half; each
    # shrinks until it fits the room left of the right margin.
    left = x + size + 52
    room = width - left - 44

    def fitted(text, start, smallest):
        size = start
        while size > smallest and draw.textlength(text, font=load_font(size)) > room:
            size -= 2
        return load_font(size)

    title_font = fitted("Cobi Paint", 112, 70)
    tag_font = fitted(TAGLINE[lang], 44, 30)
    strip_font = fitted(STRIP[lang] + "    ", 26, 18)
    draw.text((left, 122), "Cobi Paint", font=title_font, fill=TEXT)
    draw.text((left + 4, 268), TAGLINE[lang], font=tag_font, fill=TEXT)
    strip = STRIP[lang]
    sw = draw.textlength(strip, font=strip_font)
    draw.rounded_rectangle([left, 346, left + sw + 40, 396], radius=25, fill=CREAM)
    draw.text((left + 20, 356), strip, font=strip_font, fill=TEXT)

    canvas.save(os.path.join(out, f"feature_graphic_{lang}.png"))


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "build/store_screenshots/play_graphics"
    os.makedirs(out, exist_ok=True)
    icon_512(out)
    for lang in ("tr", "en"):
        feature_graphic(out, lang)
    print(f"wrote {out}/icon_512.png, feature_graphic_tr.png, feature_graphic_en.png")


if __name__ == "__main__":
    main()
