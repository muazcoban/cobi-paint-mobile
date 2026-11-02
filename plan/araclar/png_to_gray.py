"""Converts every <category>/<name>.png under a folder into raw .gray files for resim_olcumu.dart.

Usage: python3 png_to_gray.py <categories_dir> <out_dir>
Transparent pixels are composited on white first, like the app does when it shows a page.
"""
import glob
import os
import sys

from PIL import Image

src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
for f in sorted(glob.glob(os.path.join(src, '*', '*.png'))):
    rgba = Image.open(f).convert('RGBA')
    white = Image.new('RGBA', rgba.size, (255, 255, 255, 255))
    white.alpha_composite(rgba)
    gray = white.convert('L')
    w, h = gray.size
    rel = os.path.relpath(f, src)[:-4].replace(os.sep, '__')
    with open(os.path.join(out, rel + '.gray'), 'wb') as fh:
        fh.write(w.to_bytes(4, 'little') + h.to_bytes(4, 'little') + gray.tobytes())
