#!/usr/bin/env python3
"""Builds the scene mode's assets from tool/scenes/scenes.json.

For every scene:
  assets/scenes/<id>/background.png  the empty scene: sky, horizon, grass and
                                      a river, black lines on white (L)
  assets/scenes/<id>/<piece>.png      each piece at its own slot's size: the
                                      bundled coloring page outlined again so
                                      the line keeps the scene's width; white
                                      inside, transparent outside (RGBA)
  lib/data/builtin_scenes.dart        the slots and pieces for the app
  plan/img/manzara-prototip.png       the empty scene, Minik and Büyük with
                                      every piece in its own slot

It also checks that slots never overlap and stay inside the scene, and prints
the regions of both full scenes: share of the scene and whether a finger-sized
circle fits (the counting rule the council proposed, condition 9).

Usage, from the repo root:
  python3 tool/scenes/build_scenes.py
Needs Pillow and numpy.
"""
import json
import os
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
PAGES = os.path.join(ROOT, "assets", "pages")
ASSETS = os.path.join(ROOT, "assets", "scenes")
DART_FILE = os.path.join(ROOT, "lib", "data", "builtin_scenes.dart")
PREVIEW = os.path.join(ROOT, "plan", "img", "manzara-prototip.png")

# The bundled pages' lines are about this wide on a 1024 px page.
PAGE_LINE = 15.0


def horizon_y(x):
    """The horizon: a gentle arc, highest in the middle."""
    return 440 + 30 * ((x - 512) / 512) ** 2


def cubic(p0, p1, p2, p3, n=240):
    pts = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        pts.append((
            u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
            u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1],
        ))
    return pts


def background(size, line, ss=4):
    """The garden: the horizon and a river that comes from far away and
    leaves at the bottom. Drawn four times larger and scaled down, so the
    curves are smooth, then made pure black and white like the pages."""
    big = Image.new("L", (size * ss, size * ss), 255)
    draw = ImageDraw.Draw(big)

    def stroke(points):
        draw.line([(x * ss, y * ss) for x, y in points], fill=0, width=line * ss, joint="curve")

    stroke([(x, horizon_y(x)) for x in range(-30, size + 31, 4)])
    stroke(cubic((475, horizon_y(475)), (420, 620), (500, 820), (520, size + 30)))
    stroke(cubic((535, horizon_y(535)), (530, 620), (630, 800), (665, size + 30)))
    small = big.resize((size, size), Image.LANCZOS)
    return small.point(lambda v: 0 if v < 128 else 255)


def exterior(white):
    """White pixels joined to the border: the outside of a piece."""
    h, w = white.shape
    out = np.zeros_like(white)
    queue = deque()
    for x in range(w):
        for y in (0, h - 1):
            if white[y, x] and not out[y, x]:
                out[y, x] = True
                queue.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if white[y, x] and not out[y, x]:
                out[y, x] = True
                queue.append((y, x))
    while queue:
        y, x = queue.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < h and 0 <= nx < w and white[ny, nx] and not out[ny, nx]:
                out[ny, nx] = True
                queue.append((ny, nx))
    return out


def piece(page_path, size, line, fill=0.94):
    """The page's drawing fitted into a size x size square, its lines grown
    back to [line] px after the scaling thinned them; transparent outside."""
    im = Image.open(page_path).convert("L")
    ys, xs = np.nonzero(np.asarray(im) < 128)
    im = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    scale = size * fill / max(im.size)
    im = im.resize((max(1, round(im.width * scale)), max(1, round(im.height * scale))), Image.LANCZOS)
    canvas = Image.new("L", (size, size), 255)
    canvas.paste(im, ((size - im.width) // 2, (size - im.height) // 2))
    mask = Image.fromarray(((np.asarray(canvas) < 160) * 255).astype(np.uint8))
    grow = max(0, round((line - PAGE_LINE * scale) / 2))
    if grow:
        mask = mask.filter(ImageFilter.MaxFilter(2 * grow + 1))
    # Close pinholes the scaling opened, as emoji2page does.
    mask = mask.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.MinFilter(3))
    lines = np.asarray(mask) > 127
    outside = exterior(~lines)
    rgba = np.zeros((size, size, 4), np.uint8)
    rgba[..., :3] = np.where(lines[..., None], 0, 255)
    rgba[..., 3] = np.where(outside, 0, 255)
    return Image.fromarray(rgba, "RGBA")


def slot_rect(slot):
    return (slot["x"], slot["y"], slot["x"] + slot["size"], slot["y"] + slot["size"])


def check_slots(scene):
    size = scene["size"]
    slots = scene["slots"]
    for s in slots:
        l, t, r, b = slot_rect(s)
        assert 0 <= l and 0 <= t and r <= size and b <= size, f"slot {s['id']} leaves the scene"
    for i, a in enumerate(slots):
        for b in slots[i + 1:]:
            al, at, ar, ab = slot_rect(a)
            bl, bt, br, bb = slot_rect(b)
            assert ar <= bl or br <= al or ab <= bt or bb <= at, f"slots {a['id']} and {b['id']} overlap"
    ids = {s["id"] for s in slots}
    for p in scene["pieces"]:
        assert p["slot"] in ids, f"{p['key']}: no slot {p['slot']}"
        own = next(s for s in slots if s["id"] == p["slot"])
        assert own.get("big", False) == p.get("big", False), f"{p['key']}: its slot is in another mode"
    for big in (False, True):
        n_slots = sum(1 for s in slots if big or not s.get("big"))
        n_pieces = sum(1 for p in scene["pieces"] if big or not p.get("big"))
        assert n_slots == n_pieces, f"{'Büyük' if big else 'Minik'}: {n_slots} slots for {n_pieces} pieces"


def compose(scene, back, pieces, big):
    out = back.convert("RGBA")
    slots = {s["id"]: s for s in scene["slots"]}
    for p in scene["pieces"]:
        if p.get("big") and not big:
            continue
        s = slots[p["slot"]]
        art = pieces[p["key"]]
        if art.width != s["size"]:
            art = art.resize((s["size"], s["size"]), Image.LANCZOS)
        out.alpha_composite(art, (s["x"], s["y"]))
    return out.convert("L").point(lambda v: 0 if v < 153 else 255)


def regions(page, scale=2, finger=0.06):
    """(share of the scene, a finger-sized circle fits) for every region,
    biggest first, on a half-size copy."""
    small = page.resize((page.width // scale, page.height // scale), Image.LANCZOS)
    white = np.asarray(small) >= 153
    h, w = white.shape
    labels = np.zeros((h, w), np.int32)
    sizes = []
    for y0 in range(h):
        for x0 in range(w):
            if not white[y0, x0] or labels[y0, x0]:
                continue
            n = len(sizes) + 1
            labels[y0, x0] = n
            queue = deque([(y0, x0)])
            count = 0
            while queue:
                y, x = queue.popleft()
                count += 1
                for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                    if 0 <= ny < h and 0 <= nx < w and white[ny, nx] and not labels[ny, nx]:
                        labels[ny, nx] = n
                        queue.append((ny, nx))
            sizes.append(count)
    # A circle of finger * width fits where the white survives that many
    # one-pixel erosions (a square, close enough for a report).
    radius = int(finger * w / 2)
    eroded = Image.fromarray((white * 255).astype(np.uint8))
    for _ in range(radius):
        eroded = eroded.filter(ImageFilter.MinFilter(3))
    thick = set(np.unique(labels[np.asarray(eroded) > 127]).tolist()) - {0}
    total = h * w
    order = sorted(range(1, len(sizes) + 1), key=lambda n: -sizes[n - 1])
    return [(sizes[n - 1] / total, n in thick) for n in order]


def dart_file(scenes):
    out = [
        "// Generated by tool/scenes/build_scenes.py from tool/scenes/scenes.json.",
        "// Do not edit by hand.",
        "import 'dart:ui';",
        "",
        "import '../models/scene.dart';",
        "",
    ]
    names = []
    for scene in scenes:
        name = f"{scene['id']}Scene"
        names.append(name)
        sid = scene["id"]
        out.append(f"const {name} = SceneDefinition(")
        out.append(f"  id: '{sid}',")
        out.append(f"  size: {scene['size']},")
        out.append(f"  background: 'assets/scenes/{sid}/background.png',")
        out.append("  slots: [")
        for s in scene["slots"]:
            extra = ""
            if s.get("sky"):
                extra += ", sky: true"
            if s.get("big"):
                extra += ", bigOnly: true"
            out.append(f"    SceneSlot(id: {s['id']}, rect: Rect.fromLTWH({s['x']}, {s['y']}, {s['size']}, {s['size']}){extra}),")
        out.append("  ],")
        out.append("  pieces: [")
        for p in scene["pieces"]:
            extra = ", bigOnly: true" if p.get("big") else ""
            out.append(
                f"    ScenePiece(key: '{p['key']}', asset: 'assets/scenes/{sid}/{p['key']}.png', slot: {p['slot']}, "
                f"tr: '{p['tr']}', en: '{p['en']}'{extra}),"
            )
        out.append("  ],")
        out.append("  ground: [")
        for g in scene["ground"]:
            out.append(f"    SceneWord(key: '{g['key']}', tr: '{g['tr']}', en: '{g['en']}'),")
        out.append("  ],")
        out.append(");")
        out.append("")
    out.append(f"const builtInScenes = [{', '.join(names)}];")
    return "\n".join(out) + "\n"


def main():
    with open(os.path.join(HERE, "scenes.json"), encoding="utf-8") as f:
        catalog = json.load(f)
    previews = []
    for scene in catalog["scenes"]:
        check_slots(scene)
        size, line = scene["size"], scene["line"]
        folder = os.path.join(ASSETS, scene["id"])
        os.makedirs(folder, exist_ok=True)
        back = background(size, line)
        back.save(os.path.join(folder, "background.png"), optimize=True)
        slots = {s["id"]: s for s in scene["slots"]}
        pieces = {}
        for p in scene["pieces"]:
            art = piece(os.path.join(PAGES, p["page"] + ".png"), slots[p["slot"]]["size"], line)
            art.save(os.path.join(folder, p["key"] + ".png"), optimize=True)
            pieces[p["key"]] = art
        little = compose(scene, back, pieces, big=False)
        big = compose(scene, back, pieces, big=True)
        for label, page in (("Minik", little), ("Büyük", big)):
            found = regions(page)
            counted = [r for r in found if r[0] >= 0.01 and r[1]]
            print(f"{scene['id']} {label}: {len(found)} regions, {len(counted)} counted;"
                  f" biggest {', '.join(f'{a * 100:.1f}%' + ('' if t else ' thin') for a, t in found[:10])}")
        previews.append(Image.fromarray(np.hstack([np.asarray(back), np.full((size, 24), 255, np.uint8),
                                                   np.asarray(little), np.full((size, 24), 255, np.uint8),
                                                   np.asarray(big)])))
    with open(DART_FILE, "w", encoding="utf-8") as f:
        f.write(dart_file(catalog["scenes"]))
    sheet = previews[0]
    sheet = sheet.resize((sheet.width * 380 // sheet.height, 380), Image.LANCZOS)
    sheet.save(PREVIEW, optimize=True)
    print(f"wrote {len(catalog['scenes'])} scene(s), {DART_FILE} and {PREVIEW}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
