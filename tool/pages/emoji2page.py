#!/usr/bin/env python3
"""Turns flat-colour artwork (a rendered PNG with transparency) into a
toddler coloring page: bold black outlines on white, every colour area a
closed region. Also writes the flat art on white as a colour reference.

Usage: python3 emoji2page.py OUT_DIR [--size 1024] [--line 11] [--fill 0.8] [--thr 60] PNG...
Output names: <parent dir>_<basename>.png and <parent dir>_<basename>_ref.png
Needs Pillow and numpy. Used by build_pages.py; also fine on its own.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter


def page(im, size=1024, line=11, fill=0.8, thr=60):
    """Returns (page, reference) images or (None, None) for an empty input."""
    rgba = np.asarray(im.convert("RGBA"))
    ys, xs = np.nonzero(rgba[:, :, 3] > 16)
    if xs.size == 0:
        return None, None
    im = im.convert("RGBA").crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    w, h = im.size
    s = size * fill / max(w, h)
    im = im.resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.paste(im, ((size - im.width) // 2, (size - im.height) // 2), im)

    arr = np.asarray(canvas).astype(np.int16)
    rgb, alpha = arr[:, :, :3], arr[:, :, 3]
    inside = alpha >= 128
    edge = np.zeros(inside.shape, bool)
    # Compare each pixel with neighbours 1 and 2 px away: the 2 px step sees
    # the full colour difference across an anti-aliased boundary, so a line
    # never breaks into dashes.
    for step in (1, 2):
        for dy, dx in ((0, step), (step, 0), (step, step), (step, -step)):
            n_rgb = np.roll(rgb, (dy, dx), axis=(0, 1))
            n_in = np.roll(inside, (dy, dx), axis=(0, 1))
            diff = np.abs(rgb - n_rgb).sum(axis=2)
            edge |= inside & n_in & (diff > thr)
            edge |= inside != n_in

    mask = Image.fromarray((edge * 255).astype(np.uint8))
    k = line if line % 2 else line + 1
    mask = mask.filter(ImageFilter.MaxFilter(k))
    # Close pinholes between lines and round the corners a little.
    mask = mask.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(5))
    lines = np.asarray(mask) > 127
    out = Image.fromarray(np.where(lines, 0, 255).astype(np.uint8))

    ref = Image.new("RGB", (size, size), (255, 255, 255))
    ref.paste(canvas, mask=canvas.split()[3])
    return out, ref


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 64
    out_dir = argv[0]
    os.makedirs(out_dir, exist_ok=True)
    opts = {"size": 1024, "line": 11, "fill": 0.8, "thr": 60}
    paths = []
    i = 1
    while i < len(argv):
        a = argv[i]
        if a.startswith("--") and a[2:] in opts:
            kind = type(opts[a[2:]])
            opts[a[2:]] = kind(argv[i + 1])
            i += 2
        else:
            paths.append(a)
            i += 1
    for p in paths:
        base = os.path.basename(p)
        for ext in (".svg.png", ".png"):
            if base.endswith(ext):
                base = base[: -len(ext)]
                break
        name = f"{os.path.basename(os.path.dirname(p))}_{base}"
        out, ref = page(Image.open(p), **opts)
        if out is None:
            print(f"{p}: empty")
            continue
        out.save(os.path.join(out_dir, name + ".png"), optimize=True)
        ref.save(os.path.join(out_dir, name + "_ref.png"), optimize=True)
        print(f"{name}: ok")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
