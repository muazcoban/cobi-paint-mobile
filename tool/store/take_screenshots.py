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

--test runs another walk with the same handshake, --define passes a
--dart-define to the app; the scene prototype, for example:

    python3 tool/store/take_screenshots.py <udid> build/scene_shots/se \
        --test integration_test/scene_walk_test.dart --define COBI_SCENE=observation

--android takes an adb serial instead of a simulator udid (Google Play sets).
Frames come from `adb exec-out screencap`, the burst video from
`adb shell screenrecord`, and the flags go into the folder the walk prints
on its TMPDIR line, with `adb shell run-as`. The status bar goes into demo
mode (9:41, full battery). An emulator's system language does not change
from adb, so the walk takes the language from --define COBI_LOCALE. Set the
screen first; Play wants the long side at most twice the short side, so a
phone runs at 1080x1920 (7" tablet 1200x1920 at 240 dpi, 10" 1600x2560 at
320), for example:

    adb -s emulator-5580 shell wm size 1080x1920
    adb -s emulator-5580 shell wm density 420
    python3 tool/store/take_screenshots.py emulator-5580 build/store_screenshots/play_phone_tr \
        --android --define COBI_LOCALE=tr_TR
"""
import argparse
import glob
import os
import signal
import subprocess
import sys
import tempfile
import time

from PIL import Image, ImageChops

FLUTTER = os.path.expanduser("~/flutter/sdk/flutter/bin/flutter")
ADB = os.path.expanduser("~/Library/Android/sdk/platform-tools/adb")
BUNDLE = "com.cobi.paint.cobiPaintMobile"
PACKAGE = "com.cobi.paint.cobi_paint_mobile"
ANDROID = False
_container = {}
_tmpdir = {}


def adb(udid, *args, **kwargs):
    return subprocess.run([ADB, "-s", udid, *args], **kwargs)


def answer(udid, flag):
    """Drops [flag] into the app's temporary folder; the test waits for it."""
    if ANDROID:
        adb(udid, "shell", "run-as", PACKAGE, "touch", f"{_tmpdir[udid]}/{flag}", check=True)
        return
    if udid not in _container:
        _container[udid] = subprocess.run(
            ["xcrun", "simctl", "get_app_container", udid, BUNDLE, "data"],
            check=True, capture_output=True, text=True,
        ).stdout.strip()
    open(os.path.join(_container[udid], "tmp", flag), "w").close()


def shoot(udid, path):
    if ANDROID:
        with open(path, "wb") as out:
            adb(udid, "exec-out", "screencap", "-p", stdout=out, check=True)
        return
    subprocess.run(["xcrun", "simctl", "io", udid, "screenshot", path], check=True, capture_output=True)


def start_recording(udid, video):
    if ANDROID:
        return subprocess.Popen(
            [ADB, "-s", udid, "shell", "screenrecord", "--bit-rate", "12000000", "/sdcard/cobi_burst.mp4"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
    return subprocess.Popen(
        ["xcrun", "simctl", "io", udid, "recordVideo", "--codec=h264", "--force", video],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )


def stop_recording(udid, recorder, video):
    if ANDROID:
        adb(udid, "shell", "pkill", "-INT", "screenrecord", capture_output=True)
        recorder.wait(timeout=20)
        time.sleep(1.0)  # the device finishes writing the file
        adb(udid, "pull", "/sdcard/cobi_burst.mp4", video, capture_output=True)
        adb(udid, "shell", "rm", "-f", "/sdcard/cobi_burst.mp4", capture_output=True)
        return
    recorder.send_signal(signal.SIGINT)
    recorder.wait(timeout=20)


def demo_status_bar(udid):
    """Android's demo mode: 9:41, full battery and bars, no notifications."""
    adb(udid, "shell", "settings", "put", "global", "sysui_demo_allowed", "1", check=True)
    for extras in (
        ["-e", "command", "enter"],
        ["-e", "command", "clock", "-e", "hhmm", "0941"],
        ["-e", "command", "battery", "-e", "level", "100", "-e", "plugged", "false"],
        ["-e", "command", "network", "-e", "wifi", "show", "-e", "level", "4"],
        ["-e", "command", "network", "-e", "mobile", "show", "-e", "datatype", "none", "-e", "level", "4"],
        ["-e", "command", "notifications", "-e", "visible", "false"],
    ):
        adb(udid, "shell", "am", "broadcast", "-a", "com.android.systemui.demo", *extras, capture_output=True)


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
    recorder = start_recording(udid, video)
    time.sleep(1.0)  # let the recorder start before the last tap
    answer(udid, f"cobi_shot_{name}.go")
    shots = []
    end = time.time() + 3.5
    while time.time() < end:
        path = os.path.join(work, f"shot_{len(shots):02d}.png")
        shoot(udid, path)
        shots.append(path)
    time.sleep(max(0.0, end + 0.5 - time.time()))
    stop_recording(udid, recorder, video)
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
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("udid")
    parser.add_argument("out")
    parser.add_argument("--test", default="integration_test/store_shots_test.dart")
    parser.add_argument("--define", action="append", default=[], help="NAME=VALUE for --dart-define")
    parser.add_argument("--android", action="store_true", help="udid is an adb serial (Google Play sets)")
    args = parser.parse_args()
    global ANDROID
    ANDROID = args.android
    udid, out = args.udid, args.out
    os.makedirs(out, exist_ok=True)
    if ANDROID:
        demo_status_bar(udid)
    else:
        subprocess.run(
            ["xcrun", "simctl", "status_bar", udid, "override", "--time", "9:41", "--batteryState", "charged",
             "--batteryLevel", "100", "--cellularBars", "4", "--wifiBars", "3", "--dataNetwork", "wifi"],
            check=True,
        )
    test = subprocess.Popen(
        [FLUTTER, "test", args.test, "-d", udid, "--no-pub"] + [f"--dart-define={d}" for d in args.define],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1,
    )
    for line in test.stdout:
        sys.stdout.write(line)
        sys.stdout.flush()
        if "TMPDIR:" in line:
            _tmpdir[udid] = line.split("TMPDIR:", 1)[1].split()[0]
        elif "SHOT:" in line:
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
