#!/usr/bin/env python3
"""Builds the bundled coloring pages from flat-colour open-licensed art.

Pipeline, all on this machine:
  catalog.json -> download SVGs (pinned commit) -> render 1024 px (QuickLook)
  -> emoji2page.py (outlines) -> dart tool/page_report.dart (metrics, level)
  -> assets/pages/<category>/<code>.png + lib/data/builtin_images.dart

Usage, from the repo root:
  python3 tool/pages/build_pages.py --work /tmp/cobi-pages [--dart ~/flutter/sdk/flutter/bin/dart]

Needs macOS (qlmanage), Pillow and numpy. Re-running skips files already in
the work directory, so a changed catalog only fetches what is new.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import urllib.parse
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from emoji2page import page as make_page  # noqa: E402
from PIL import Image  # noqa: E402

ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
ASSETS = os.path.join(ROOT, "assets", "pages")
DART_FILE = os.path.join(ROOT, "lib", "data", "builtin_images.dart")


def level_for(regions, finger):
    """Same rule as PageCheck.level in lib/engine/region/page_check.dart."""
    if finger <= 4 and regions <= 10:
        return 1
    if finger >= 8 or regions >= 16:
        return 3
    return 2


def fluent_urls(source, name):
    """Raw URLs to try for a subject's flat SVG.

    The folder is the name with a capital first letter; the file is the
    folder name in lower case with spaces as underscores, hyphens and
    accented letters kept (Yo-yo/yo-yo_flat.svg; the pinata file keeps its
    accented n). The old rule, every other character an underscore, is
    tried first.
    """
    seen = set()
    for variant in (name, name.replace("-", " ")):
        folder = variant[0].upper() + variant[1:]
        for file in (re.sub(r"[^a-z0-9]+", "_", variant.lower()).strip("_"), variant.lower().replace(" ", "_")):
            path = f"assets/{folder}/Flat/{file}_flat.svg"
            if path not in seen:
                seen.add(path)
                yield f"https://raw.githubusercontent.com/{source['repo']}/{source['commit']}/{urllib.parse.quote(path)}"


def fetch(url, path):
    try:
        data = urllib.request.urlopen(url, timeout=30).read()
    except Exception:
        return False
    if not data:
        return False
    with open(path, "wb") as f:
        f.write(data)
    return True


def title(name, turkish=True):
    """Capital first letter; only Turkish names use the dotted capital I."""
    first = {"i": "İ", "ı": "I"}.get(name[:1]) if turkish else None
    return (first or name[:1].upper()) + name[1:]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--work", required=True, help="scratch directory for downloads and renders")
    ap.add_argument("--dart", default="dart", help="dart executable (Flutter's own, 3.10+)")
    ap.add_argument("--catalog", default=os.path.join(HERE, "catalog.json"))
    ap.add_argument("--force", action="store_true", help="convert every page again (after a converter change)")
    args = ap.parse_args()

    catalog = json.load(open(args.catalog, encoding="utf-8"))
    source = catalog["source"]
    pages = [p for p in catalog["pages"] if not p.get("skip")]
    svg_dir, fixed_dir, render_dir, page_dir = (os.path.join(args.work, d) for d in ("svg", "fixed", "render", "pages"))
    for d in (svg_dir, fixed_dir, render_dir, page_dir):
        os.makedirs(d, exist_ok=True)

    missing = []
    for p in pages:
        svg = os.path.join(svg_dir, p["code"] + ".svg")
        if os.path.exists(svg):
            continue
        if not any(fetch(u, svg) for u in fluent_urls(source, p["name"])):
            missing.append(p["name"])
    if missing:
        print("not in the source, skipped:", ", ".join(missing))
    pages = [p for p in pages if os.path.exists(os.path.join(svg_dir, p["code"] + ".svg"))]

    # QuickLook renders an SVG at its own width/height; dropping them makes
    # it fill the requested size.
    to_render = []
    for p in pages:
        src = os.path.join(svg_dir, p["code"] + ".svg")
        dst = os.path.join(fixed_dir, p["code"] + ".svg")
        if not os.path.exists(dst):
            s = open(src, encoding="utf-8").read()
            s = re.sub(r'<svg([^>]*?)\swidth="[^"]*"', r"<svg\1", s, count=1)
            s = re.sub(r'<svg([^>]*?)\sheight="[^"]*"', r"<svg\1", s, count=1)
            open(dst, "w", encoding="utf-8").write(s)
        if not os.path.exists(os.path.join(render_dir, p["code"] + ".svg.png")):
            to_render.append(dst)
    if to_render:
        subprocess.run(["qlmanage", "-t", "-s", "1024", "-o", render_dir, *to_render], check=True, capture_output=True)

    for p in pages:
        out = os.path.join(page_dir, p["code"] + ".png")
        if os.path.exists(out) and not args.force:
            continue
        img, _ref = make_page(Image.open(os.path.join(render_dir, p["code"] + ".svg.png")))
        if img is None:
            print(p["code"], "rendered empty")
            continue
        img.save(out, optimize=True)

    report = subprocess.run(
        [args.dart, "run", "tool/page_report.dart", *(os.path.join(page_dir, p["code"] + ".png") for p in pages)],
        cwd=ROOT, capture_output=True, text=True,
    ).stdout
    metrics = {}
    for line in report.splitlines():
        m = re.match(r".*/(\w+)\.png\s+\d+x\d+\s+regions (\d+)\s+finger (\d+).*?(PROBLEM.*)?$", line)
        if m:
            metrics[m.group(1)] = (int(m.group(2)), int(m.group(3)), bool(m.group(4)))

    kept = []
    for p in pages:
        regions, finger, problem = metrics.get(p["code"], (0, 0, True))
        if problem:
            print(p["code"], p["name"], "fails the page check, skipped")
            continue
        p["level"] = level_for(regions, finger)
        cat_dir = os.path.join(ASSETS, p["category"])
        os.makedirs(cat_dir, exist_ok=True)
        shutil.copyfile(os.path.join(page_dir, p["code"] + ".png"), os.path.join(cat_dir, p["code"] + ".png"))
        kept.append(p)

    lines = [
        "// GENERATED by tool/pages/build_pages.py from tool/pages/catalog.json. Do not edit.",
        f"// Source art: {source['name']} ({source['license']}), {source['repo']} @ {source['commit'][:12]}.",
        "",
        "import '../models/coloring_image.dart';",
        "",
        "/// Coloring pages bundled with the app under assets/pages, grouped by category.",
        "const List<ColoringImage> builtInImages = [",
    ]
    for p in kept:
        name_tr = title(p["nameTr"].replace(" yüzü", "")).replace("'", r"\'")
        name_en = title(p["nameEn"].replace(" face", ""), turkish=False).replace("'", r"\'")
        lines.append(
            f"  ColoringImage(id: '{p['category']}_{p['code']}', name: '{name_tr}', nameEn: '{name_en}', "
            f"category: '{p['category']}', imagePath: 'assets/pages/{p['category']}/{p['code']}.png', level: {p['level']}"
            f"{', free: true' if p.get('free') else ''}),"
        )
    lines += ["];", ""]
    open(DART_FILE, "w", encoding="utf-8").write("\n".join(lines))
    by_level = {}
    for p in kept:
        by_level[p["level"]] = by_level.get(p["level"], 0) + 1
    print(f"{len(kept)} pages written; levels {dict(sorted(by_level.items()))}")


if __name__ == "__main__":
    main()
