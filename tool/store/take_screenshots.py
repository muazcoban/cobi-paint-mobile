#!/usr/bin/env python3
"""Takes the store screenshots of the real app on a simulator.

Runs integration_test/store_shots_test.dart with `flutter test -d <udid>`
and answers each SHOT:<name> line with `xcrun simctl io <udid> screenshot`,
so the picture has the status bar and the exact device size. A
BURST:<name> line keeps shooting for a few seconds and keeps the frame
with the most colour on screen: the finish confetti lasts about a second.

The app speaks the simulator's language; set it before running:

    xcrun simctl spawn <udid> defaults write -g AppleLanguages -array tr-TR
    xcrun simctl spawn <udid> defaults write -g AppleLocale tr_TR
    python3 tool/store/take_screenshots.py <udid> build/store_screenshots/iphone63_tr_220

Then caption the frames with tool/store/caption_screenshots.py. Needs
Pillow. The status bar is set to 9:41, full battery and full bars.
"""
import glob
import os
import signal
import subprocess
import sys
import tempfile
import time

from PIL import Image, ImageChops

FLUTTER = os.path.expanduser("~/flutter/sdk/flutter/bin/flutter")
BUNDLE = "com.cobi.paint.cobiPaintMobile"
_container = {}


def answer(udid, flag):
    """Drops [flag] into the app's temporary folder; the test waits for it."""
    if udid not in _container:
        _container[udid] = subprocess.run(
            ["xcrun", "simctl", "get_app_container", udid, BUNDLE, "data"],
            check=True, capture_output=True, text=True,
        ).stdout.strip()
    open(os.path.join(_container[udid], "tmp", flag), "w").close()


def shoot(udid, path):
    subprocess.run(["xcrun", "simctl", "io", udid, "screenshot", path], check=True, capture_output=True)


def colourful(path):
    """Saturated, bright pixels: the confetti adds many."""
    image = Image.open(path).convert("HSV").resize((300, 650))
    return sum(1 for h, s, v in image.getdata() if s > 150 and v > 120)


def confetti(path, reference):
    """Saturated pixels that differ from [reference], between 10% and 75% of
    the height: the confetti over the page."""
    size = (300, 650)
    frame = Image.open(path).convert("RGB").resize(size)
    ref = Image.open(reference).convert("RGB").resize(size)
    changed = ImageChops.difference(frame, ref).convert("L").point(lambda v: 255 if v > 40 else 0)
    saturated = frame.convert("HSV").split()[1].point(lambda v: 255 if v > 120 else 0)
    both = ImageChops.multiply(changed, saturated).crop((0, int(size[1] * 0.10), size[0], int(size[1] * 0.75)))
    return both.histogram()[255]


def burst(udid, out, name):
    """Screenshots for a few seconds while a video records the same moment;
    on a busy machine one screenshot can take longer than the confetti. The
    frame with the most colour wins; a lossless screenshot wins a near tie."""
    work = tempfile.mkdtemp(prefix="cobi_burst_")
    video = os.path.join(work, "burst.mp4")
    recorder = subprocess.Popen(
        ["xcrun", "simctl", "io", udid, "recordVideo", "--codec=h264", "--force", video],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    time.sleep(1.0)  # let the recorder start before the last tap
    answer(udid, f"cobi_shot_{name}.go")
    shots = []
    end = time.time() + 3.5
    while time.time() < end:
        path = os.path.join(work, f"shot_{len(shots):02d}.png")
        shoot(udid, path)
        shots.append(path)
    time.sleep(max(0.0, end + 0.5 - time.time()))
    recorder.send_signal(signal.SIGINT)
    recorder.wait(timeout=20)
    frames = []
    if os.path.exists(video):
        subprocess.run(["ffmpeg", "-loglevel", "error", "-i", video, "-vf", "fps=12", os.path.join(work, "video_%03d.png")])
        frames = sorted(glob.glob(os.path.join(work, "video_*.png")))
    # The last frame, after the confetti, is the reference: confetti is a
    # saturated pixel that differs from it, counted over the page (the
    # palette below is colourful anyway).
    reference = frames[-1] if frames else shots[-1]
    scores = {path: confetti(path, reference) for path in shots + frames}
    best_video = max((scores[f] for f in frames), default=0)
    best_shot = max(shots, key=lambda path: scores[path])
    best = best_shot if scores[best_shot] >= 0.85 * best_video else max(frames, key=lambda path: scores[path])
    size = Image.open(shots[0]).size
    if Image.open(best).size != size:
        # The video may be scaled down; the store wants the device's exact size.
        Image.open(best).convert("RGB").resize(size, Image.LANCZOS).save(best)
    os.replace(best, os.path.join(out, f"{name}.png"))
    answer(udid, f"cobi_shot_{name}.done")
    print(f"[burst] {name}: {len(shots)} screenshots, {len(frames)} video frames, kept {os.path.basename(best)}")


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    udid, out = sys.argv[1], sys.argv[2]
    os.makedirs(out, exist_ok=True)
    subprocess.run(
        ["xcrun", "simctl", "status_bar", udid, "override", "--time", "9:41", "--batteryState", "charged",
         "--batteryLevel", "100", "--cellularBars", "4", "--wifiBars", "3", "--dataNetwork", "wifi"],
        check=True,
    )
    test = subprocess.Popen(
        [FLUTTER, "test", "integration_test/store_shots_test.dart", "-d", udid, "--no-pub"],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1,
    )
    for line in test.stdout:
        sys.stdout.write(line)
        sys.stdout.flush()
        if "SHOT:" in line:
            name = line.split("SHOT:", 1)[1].split()[0]
            shoot(udid, os.path.join(out, f"{name}.png"))
            answer(udid, f"cobi_shot_{name}.done")
            print(f"[shot] {name}")
        elif "BURST:" in line:
            name = line.split("BURST:", 1)[1].split()[0]
            burst(udid, out, name)
    return test.wait()


if __name__ == "__main__":
    sys.exit(main())
