#!/usr/bin/env python3
"""Turns the raw voice recordings into the app's voice clips.

Input:   tool/voice/raw/<lang>/<key>.<ext>   wav, m4a, aiff, aif, mp3, caf, flac
                                             (iPhone Voice Memos gives m4a)
Output:  assets/voice/<lang>/<key>.mp3       mono, 44.1 kHz, 96 kbps, -16 LUFS,
                                             50 ms of silence at both ends

For every clip:
  1. leading and trailing silence under -40 dBFS is cut (silenceremove on the
     clip and again on its reverse, so a pause inside a clip is never cut);
  2. the loudness is normalised in two loudnorm passes (I=-16, TP=-1.5,
     LRA=11): the first pass measures, the second applies the measured values
     as a linear gain. The first pass measures the clip looped six times,
     because a single word is shorter than the 3 s window loudnorm wants;
  3. the result is downmixed to mono (before the measurement, so the loudness
     is the mono clip's), padded with 50 ms of silence at the start (adelay)
     and at the end (apad), resampled to 44.1 kHz and encoded with libmp3lame
     at 96 kbps.
The output is then read back: ffprobe for the format and duration, ffmpeg's
ebur128 meter for the loudness. A duration outside 0.5-1.5 s (3.0 s upper
limit for `gate` and `scene`) or a loudness more than 1 LU off -16 is a
WARNING, never an error.

Only keys listed in tool/voice/README.md are processed; the two tables there
(main list and scene words) are the list of record. A raw file whose name is
not in them is skipped with a warning.

Usage, from the repo root:
  python3 tool/voice/process_clips.py                 process every raw clip
  python3 tool/voice/process_clips.py --only fill,draw --lang tr
  python3 tool/voice/process_clips.py --check         compare assets/voice with the README
  python3 tool/voice/process_clips.py --pubspec       add the assets/voice lines to pubspec.yaml
Options: --raw DIR (default tool/voice/raw), --out DIR (default assets/voice),
--silence-db N (trim threshold in dBFS, default -40).

Exit code: 0 when everything went through; 1 when a clip failed, or, with
--check, when a clip is missing or has the wrong format; 2 for a usage or
setup error (no ffmpeg, a broken README table, --pubspec with another --out).

Needs ffmpeg and ffprobe (brew install ffmpeg); looks in PATH, then in
/opt/homebrew/bin. Standard library only, no network access.
"""
import argparse
import json
import math
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
README = os.path.join(HERE, "README.md")
PUBSPEC = os.path.join(ROOT, "pubspec.yaml")
RAW_DEFAULT = os.path.join(HERE, "raw")
OUT_DEFAULT = os.path.join(ROOT, "assets", "voice")
HOMEBREW_BIN = "/opt/homebrew/bin"

LANGS_DEFAULT = ["tr", "en"]
INPUT_EXTENSIONS = (".wav", ".m4a", ".aiff", ".aif", ".mp3", ".caf", ".flac")

TARGET_I = -16.0
TARGET_TP = -1.5
TARGET_LRA = 11.0
SAMPLE_RATE = 44100
BITRATE = "96k"
PAD_MS = 50
MIN_SECONDS = 0.5
MAX_SECONDS = 1.5
# How far a finished clip may read from TARGET_I before --check warns.
LOUDNESS_TOLERANCE = 1.0
# Keys whose clip may run longer: the gate sentence and the scene call.
LONG_KEYS = {"gate": 3.0, "scene": 3.0}

# The README's table rows: | key | Turkish | English |
ROW = re.compile(r"^\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|\s*$")

MONO = "aformat=channel_layouts=mono"
# 50 ms of silence before (adelay) and after (apad) the clip.
PADS = "adelay=%d:all=1,apad=pad_dur=%g" % (PAD_MS, PAD_MS / 1000.0)


class ClipError(Exception):
    """A clip that could not be processed; the message says why."""


def die(message, code=2):
    print("error: " + message, file=sys.stderr)
    sys.exit(code)


# Tools ----------------------------------------------------------------------


def find_tool(name):
    """The executable from PATH, else from Homebrew; exits when neither exists."""
    path = shutil.which(name) or os.path.join(HOMEBREW_BIN, name)
    if os.path.isfile(path) and os.access(path, os.X_OK):
        return path
    die("%s not found in PATH or in %s. Install it with: brew install ffmpeg" % (name, HOMEBREW_BIN))


def run(cmd):
    """Runs a command and returns (returncode, stdout, stderr); nothing is streamed."""
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return proc.returncode, proc.stdout, proc.stderr


def last_lines(text, count=2):
    """The last non-empty lines of ffmpeg's output, for a short error message."""
    lines = [line.strip() for line in text.strip().splitlines() if line.strip()]
    return " | ".join(lines[-count:]) if lines else "(no output)"


def relative(path):
    """The path relative to the repo when it is inside it, else as given."""
    rel = os.path.relpath(path, ROOT)
    return path if rel.startswith("..") else rel


# README ---------------------------------------------------------------------


def readme_entries(path=README):
    """Every table row of the README as (key, turkish, english, section), in order."""
    entries = []
    section = ""
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            line = line.rstrip("\n")
            if line.startswith("## "):
                section = line[3:].strip()
                continue
            match = ROW.match(line)
            if not match:
                continue
            key, turkish, english = match.groups()
            # The header row and the |---|---|---| separator under it.
            if key == "Anahtar" or not key or set(key) <= set("-: "):
                continue
            entries.append((key, turkish, english, section))
    keys = [entry[0] for entry in entries]
    doubled = sorted({key for key in keys if keys.count(key) > 1})
    if doubled:
        die("%s lists a key twice: %s" % (relative(path), ", ".join(doubled)))
    if not entries:
        die("no table rows found in %s" % relative(path))
    return entries


# Raw files ------------------------------------------------------------------


def raw_clips(raw_dir, lang):
    """key -> raw file for lang, and the problems found (a key recorded twice)."""
    folder = os.path.join(raw_dir, lang)
    clips = {}
    problems = []
    if not os.path.isdir(folder):
        return clips, problems
    for name in sorted(os.listdir(folder)):
        stem, ext = os.path.splitext(name)
        if name.startswith(".") or ext.lower() not in INPUT_EXTENSIONS:
            continue
        if stem in clips:
            problems.append("%s/%s: two raw files for one key (%s and %s); keep one"
                            % (lang, stem, os.path.basename(clips[stem]), name))
            clips[stem] = None
            continue
        clips[stem] = os.path.join(folder, name)
    return {key: path for key, path in clips.items() if path}, problems


# ffmpeg passes --------------------------------------------------------------


def trim_filter(silence_db):
    """Cuts leading silence; reversed, cuts what was trailing silence; reverses back."""
    cut = "silenceremove=start_periods=1:start_threshold=%sdB" % silence_db
    return "%s,areverse,%s,areverse" % (cut, cut)


def measure(ffmpeg, src, silence_db):
    """First loudnorm pass: the measurements of the trimmed mono clip."""
    chain = ",".join([
        MONO,
        trim_filter(silence_db),
        # Measured as it will ship, pads included, and six copies in a row:
        # loudnorm cannot measure anything under 400 ms and wants about 3 s.
        PADS,
        "aloop=loop=5:size=2147483647",
        "loudnorm=I=%s:TP=%s:LRA=%s:print_format=json" % (TARGET_I, TARGET_TP, TARGET_LRA),
    ])
    code, _, err = run([ffmpeg, "-hide_banner", "-nostats", "-i", src, "-af", chain, "-f", "null", "-"])
    if code != 0:
        raise ClipError("measurement failed: " + last_lines(err))
    start, end = err.rfind("{"), err.rfind("}")
    if start < 0 or end < start:
        raise ClipError("loudnorm printed no measurement: " + last_lines(err))
    stats = json.loads(err[start:end + 1])
    try:
        measured = {name: float(stats[name])
                    for name in ("input_i", "input_tp", "input_lra", "input_thresh", "target_offset")}
    except (KeyError, ValueError):
        raise ClipError("loudnorm's measurement is incomplete: %s" % stats)
    if not all(math.isfinite(value) for value in measured.values()) or measured["input_i"] < -60:
        raise ClipError("nothing left after trimming (%s LUFS): the clip is silent or entirely under the "
                        "%g dBFS trim threshold; record closer to the microphone or pass --silence-db -50"
                        % (stats["input_i"], silence_db))
    return measured


def encode(ffmpeg, src, dst, silence_db, measured):
    """Second loudnorm pass, pad, resample and encode. Returns loudnorm's mode, linear or dynamic."""
    # loudnorm reads a measured LRA of exactly 0 as "not measured" and then
    # normalises by its own guess, which goes wrong under 400 ms. Only a pure
    # tone has an LRA of 0, never speech, but the guard costs nothing.
    lra = max(measured["input_lra"], 0.01)
    loudnorm = ("loudnorm=I=%s:TP=%s:LRA=%s:measured_I=%.2f:measured_TP=%.2f:measured_LRA=%.2f"
                ":measured_thresh=%.2f:offset=%.2f:linear=true:print_format=summary"
                % (TARGET_I, TARGET_TP, TARGET_LRA, measured["input_i"], measured["input_tp"],
                   lra, measured["input_thresh"], measured["target_offset"]))
    # The resample comes last on purpose: ffmpeg 8's libmp3lame rejects the
    # last frame when adelay+apad feed it directly ("inadequate AVFrame plane
    # padding"); a frame from aresample is always accepted.
    chain = ",".join([
        MONO,
        trim_filter(silence_db),
        loudnorm,
        PADS,
        "aresample=%d" % SAMPLE_RATE,
    ])
    cmd = [ffmpeg, "-hide_banner", "-nostats", "-y", "-i", src, "-af", chain,
           "-map_metadata", "-1", "-bitexact",
           "-ac", "1", "-ar", str(SAMPLE_RATE), "-c:a", "libmp3lame", "-b:a", BITRATE, dst]
    code, _, err = run(cmd)
    if code != 0:
        raise ClipError("encoding failed: " + last_lines(err))
    mode = re.search(r"Normalization Type:\s*(\w+)", err)
    return mode.group(1).lower() if mode else "?"


def loudness(ffmpeg, path):
    """Integrated loudness of a finished clip as ffmpeg's ebur128 meter reads it, or None."""
    code, _, err = run([ffmpeg, "-hide_banner", "-nostats", "-i", path, "-af", "ebur128=framelog=quiet", "-f", "null", "-"])
    match = re.search(r"\bI:\s*(-?[\d.]+)\s*LUFS", err) if code == 0 else None
    return float(match.group(1)) if match else None


def probe(ffprobe, path):
    """codec, channels, sample rate and duration of the first audio stream."""
    code, out, err = run([ffprobe, "-v", "error", "-print_format", "json", "-show_streams", "-show_format", path])
    if code != 0:
        raise ClipError("ffprobe failed: " + last_lines(err))
    data = json.loads(out)
    streams = [s for s in data.get("streams", []) if s.get("codec_type") == "audio"]
    if not streams:
        raise ClipError("no audio stream")
    stream = streams[0]
    duration = data.get("format", {}).get("duration") or stream.get("duration") or "0"
    return {
        "codec": stream.get("codec_name"),
        "channels": int(stream.get("channels", 0)),
        "rate": int(stream.get("sample_rate", 0)),
        "duration": float(duration),
    }


def format_problems(info):
    problems = []
    if info["codec"] != "mp3":
        problems.append("codec %s (expected mp3)" % info["codec"])
    if info["channels"] != 1:
        problems.append("%d channels (expected mono)" % info["channels"])
    if info["rate"] != SAMPLE_RATE:
        problems.append("%d Hz (expected %d)" % (info["rate"], SAMPLE_RATE))
    return problems


def duration_warning(key, seconds):
    # An MP3 frame is 26 ms, so a clip measured 10 ms past a limit is on it.
    slack = 0.01
    limit = LONG_KEYS.get(key, MAX_SECONDS)
    if seconds < MIN_SECONDS - slack:
        return "%.2f s is under the %.1f s minimum" % (seconds, MIN_SECONDS)
    if seconds > limit + slack:
        return "%.2f s is over the %.1f s limit for this key" % (seconds, limit)
    return None


def loudness_warning(lufs):
    if lufs is None:
        return "loudness could not be measured"
    if abs(lufs - TARGET_I) > LOUDNESS_TOLERANCE:
        return "%.1f LUFS is more than %g LU away from the %g LUFS target" % (lufs, LOUDNESS_TOLERANCE, TARGET_I)
    return None


def lufs_text(lufs):
    return "n/a" if lufs is None else "%.1f" % lufs


def readme_order(entries):
    return {entry[0]: index for index, entry in enumerate(entries)}


# Modes ----------------------------------------------------------------------


def process(args, ffmpeg, ffprobe):
    entries = readme_entries()
    order = readme_order(entries)
    only = set(args.only.split(",")) if args.only else None
    done = warnings = errors = 0

    def warn(message):
        nonlocal warnings
        warnings += 1
        print("WARNING " + message)

    def fail(message):
        nonlocal errors
        errors += 1
        print("error: " + message, file=sys.stderr)

    if only:
        for key in sorted(only - set(order)):
            warn("%s: not in %s; nothing will match it" % (key, relative(README)))

    for lang in args.langs:
        clips, problems = raw_clips(args.raw, lang)
        for problem in problems:
            fail(problem)
        if not clips:
            print("%s: no raw clips in %s" % (lang, relative(os.path.join(args.raw, lang))))
            continue
        if only:
            for key in sorted(only - set(clips)):
                if key in order:
                    warn("%s/%s: no raw file" % (lang, key))
        for key in sorted(clips, key=lambda k: (order.get(k, len(order)), k)):
            if only and key not in only:
                continue
            if key not in order:
                warn("%s/%s: not in %s; skipped (fix the file name or add the row first)"
                     % (lang, key, relative(README)))
                continue
            dst_dir = os.path.join(args.out, lang)
            os.makedirs(dst_dir, exist_ok=True)
            dst = os.path.join(dst_dir, key + ".mp3")
            try:
                measured = measure(ffmpeg, clips[key], args.silence_db)
                mode = encode(ffmpeg, clips[key], dst, args.silence_db, measured)
                info = probe(ffprobe, dst)
                problems = format_problems(info)
                if problems:
                    raise ClipError("output has the wrong format: " + "; ".join(problems))
            except ClipError as error:
                if os.path.exists(dst):
                    os.remove(dst)
                fail("%s/%s (%s): %s" % (lang, key, os.path.basename(clips[key]), error))
                continue
            done += 1
            lufs = loudness(ffmpeg, dst)
            print("%s/%s: %.2f s, %s LUFS (%s gain) -> %s"
                  % (lang, key, info["duration"], lufs_text(lufs), mode, relative(dst)))
            for warning in (duration_warning(key, info["duration"]), loudness_warning(lufs)):
                if warning:
                    warn("%s/%s: %s" % (lang, key, warning))

    print("%d clip(s) written, %d warning(s), %d error(s)" % (done, warnings, errors))
    return 1 if errors else 0


def check(args, ffmpeg, ffprobe):
    entries = readme_entries()
    keys = [entry[0] for entry in entries]
    order = readme_order(entries)
    failed = False
    for lang in args.langs:
        folder = os.path.join(args.out, lang)
        present = set()
        if os.path.isdir(folder):
            present = {os.path.splitext(name)[0] for name in os.listdir(folder) if name.lower().endswith(".mp3")}
        missing = [key for key in keys if key not in present]
        extra = sorted(present - set(keys))
        print("%s: %d of %d clips present, %d missing, %d extra (%s)"
              % (lang, len(present) - len(extra), len(keys), len(missing), len(extra), relative(folder)))
        if missing:
            failed = True
            print("  missing: " + ", ".join(missing))
        if extra:
            print("  extra, not in %s: %s" % (relative(README), ", ".join(extra)))
        for key in sorted(present, key=lambda k: (order.get(k, len(order)), k)):
            path = os.path.join(folder, key + ".mp3")
            try:
                info = probe(ffprobe, path)
            except ClipError as error:
                failed = True
                print("  %s/%s: %s" % (lang, key, error))
                continue
            problems = format_problems(info)
            if problems:
                failed = True
                print("  %s/%s: %s" % (lang, key, "; ".join(problems)))
            for warning in (duration_warning(key, info["duration"]), loudness_warning(loudness(ffmpeg, path))):
                if warning:
                    print("WARNING %s/%s: %s" % (lang, key, warning))
    print("check %s" % ("FAILED" if failed else "passed"))
    return 1 if failed else 0


def update_pubspec(args):
    """Adds `    - assets/voice/<lang>/` for every language folder that holds clips."""
    if os.path.abspath(args.out) != OUT_DEFAULT:
        die("--pubspec only applies to the default --out (%s)" % relative(OUT_DEFAULT))
    with open(PUBSPEC, encoding="utf-8") as handle:
        text = handle.read()
    lines = text.split("\n")
    try:
        start = lines.index("  assets:")
    except ValueError:
        die("%s has no '  assets:' list" % relative(PUBSPEC))
    end = start + 1
    while end < len(lines) and lines[end].startswith("    - "):
        end += 1

    added = []
    for lang in args.langs:
        folder = os.path.join(args.out, lang)
        has_clips = os.path.isdir(folder) and any(name.lower().endswith(".mp3") for name in os.listdir(folder))
        wanted = "    - assets/voice/%s/" % lang
        if not has_clips:
            print("%s: %s has no clips; pubspec line not added" % (lang, relative(folder)))
            continue
        if wanted in lines[start + 1:end]:
            print("%s: pubspec.yaml already lists %s" % (lang, wanted.strip()))
            continue
        anchor = None
        for index in range(start + 1, end):
            if lines[index] == "    - assets/sounds/" or lines[index].startswith("    - assets/voice/"):
                anchor = index
        insert_at = anchor + 1 if anchor is not None else end
        lines.insert(insert_at, wanted)
        end += 1
        added.append(wanted.strip())

    if added:
        with open(PUBSPEC, "w", encoding="utf-8") as handle:
            handle.write("\n".join(lines))
        print("pubspec.yaml: added " + ", ".join(added))
    else:
        print("pubspec.yaml: nothing to change")
    return 0


# Entry point ----------------------------------------------------------------


def parse_args(argv):
    parser = argparse.ArgumentParser(description="Processes the raw voice recordings into assets/voice clips.")
    parser.add_argument("--raw", default=RAW_DEFAULT, help="raw recordings folder (default tool/voice/raw)")
    parser.add_argument("--out", default=OUT_DEFAULT, help="output folder (default assets/voice)")
    parser.add_argument("--lang", default=",".join(LANGS_DEFAULT), help="languages, comma separated (default tr,en)")
    parser.add_argument("--only", default="", help="process only these keys, comma separated")
    parser.add_argument("--silence-db", type=float, default=-40.0, help="trim threshold in dBFS (default -40)")
    parser.add_argument("--check", action="store_true", help="compare the output folder with the README, no processing")
    parser.add_argument("--pubspec", action="store_true", help="add the assets/voice lines to pubspec.yaml, no processing")
    args = parser.parse_args(argv)
    if args.check and args.pubspec:
        parser.error("--check and --pubspec are separate steps; run them one after the other")
    args.langs = [lang.strip() for lang in args.lang.split(",") if lang.strip()]
    if not args.langs or any(not re.fullmatch(r"[a-z]{2}", lang) for lang in args.langs):
        parser.error("--lang takes two-letter codes, for example tr,en")
    args.raw = os.path.abspath(args.raw)
    args.out = os.path.abspath(args.out)
    return args


def main(argv=None):
    args = parse_args(sys.argv[1:] if argv is None else argv)
    if args.pubspec:
        return update_pubspec(args)
    ffmpeg = find_tool("ffmpeg")
    ffprobe = find_tool("ffprobe")
    if args.check:
        return check(args, ffmpeg, ffprobe)
    return process(args, ffmpeg, ffprobe)


if __name__ == "__main__":
    sys.exit(main())
