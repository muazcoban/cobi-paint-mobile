#!/usr/bin/env python3
"""Copies the README's clip tables into the recording guide.

tool/voice/README.md is the list of record. tool/voice/kayit-rehberi.md
repeats its two tables, numbered in recording order, between these markers:

  <!-- BEGIN README TABLE main -->  ...  <!-- END README TABLE main -->
  <!-- BEGIN README TABLE scene --> ...  <!-- END README TABLE scene -->

The rows are copied by this script, never typed, so the guide can never
disagree with the README. A key in NOT_RECORDED gets a (*) after its name;
the guide's prose says what the mark means. Everything outside the markers
is written by hand.

Usage, from the repo root:
  python3 tool/voice/build_guide.py           rewrite the tables in the guide
  python3 tool/voice/build_guide.py --check   exit 1 when the guide is stale
Standard library only.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from process_clips import readme_entries  # noqa: E402

GUIDE = os.path.join(HERE, "kayit-rehberi.md")
# Listed in the README, not spoken by the code today: no recording yet.
NOT_RECORDED = {"undo"}
# The guide's Turkish header row ("Turkce" with its diacritics), escaped so
# the source stays ASCII.
HEADER = "| # | Anahtar | T\u00fcrk\u00e7e | English |"
RULE = "|---|---|---|---|"


def tables(entries):
    """{'main': [...lines...], 'scene': [...]}, numbered through both tables."""
    main = [e for e in entries if not e[3].startswith("Manzara")]
    scene = [e for e in entries if e[3].startswith("Manzara")]
    if not main or not scene:
        sys.exit("error: the README's two tables were not both found (%d main, %d scene rows)" % (len(main), len(scene)))
    result = {}
    number = 1
    for name, rows in (("main", main), ("scene", scene)):
        lines = [HEADER, RULE]
        for key, turkish, english, _ in rows:
            mark = " (*)" if key in NOT_RECORDED else ""
            lines.append("| %d | `%s`%s | %s | %s |" % (number, key, mark, turkish, english))
            number += 1
        result[name] = lines
    return result


def splice(text, name, lines):
    pattern = re.compile(r"(<!-- BEGIN README TABLE %s -->)\n.*?(<!-- END README TABLE %s -->)" % (name, name), re.S)
    if not pattern.search(text):
        sys.exit("error: %s has no markers for the %s table" % (os.path.relpath(GUIDE), name))
    return pattern.sub(lambda m: m.group(1) + "\n" + "\n".join(lines) + "\n" + m.group(2), text, count=1)


def main(argv):
    check = "--check" in argv
    with open(GUIDE, encoding="utf-8") as handle:
        before = handle.read()
    after = before
    for name, lines in tables(readme_entries()).items():
        after = splice(after, name, lines)
    if after == before:
        print("%s: tables already match the README" % os.path.relpath(GUIDE))
        return 0
    if check:
        print("%s: tables are stale; run python3 tool/voice/build_guide.py" % os.path.relpath(GUIDE))
        return 1
    with open(GUIDE, "w", encoding="utf-8") as handle:
        handle.write(after)
    print("%s: tables rewritten from the README" % os.path.relpath(GUIDE))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
