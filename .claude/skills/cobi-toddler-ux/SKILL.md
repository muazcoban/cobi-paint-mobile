---
name: cobi-toddler-ux
description: Use for ANY user-facing change in Cobi Paint (screens, buttons, palette, gestures, sounds, animations, dialogs, coloring pages, store screenshots). The primary user is a 3-year-old who cannot read; every change must pass the toddler checklist, Apple's Human Interface Guidelines and App Review rules for the Kids Category before it is done. Triggers: "ekran", "buton", "tasarım", "UI", "UX", "arayüz", "palet", "jest", "boyama sayfası", "kids", "toddler", "3 yaş", "HIG".
---

# Cobi Paint toddler UX

The first question for every change: **can a 3-year-old use it?** The second: does it follow
Apple's Human Interface Guidelines (read the current pages; HIG changes every WWDC) and App Review
1.3 / 5.1.4 for the Kids Category? Report each check as COMPLIANT, JUSTIFIED DEVIATION or GAP
(with file:line and a fix). A GAP blocks "done".

## Toddler checklist (Ç1-Ç10)

| # | Rule | Measure |
|---|---|---|
| Ç1 | No reading needed | Every control is an icon plus sound; the flow works with all text hidden |
| Ç2 | Huge targets | Phone: primary controls 80-84 pt, palette dots 68-72 pt; tablet 112-120 pt. On a 375 pt phone the dots shrink to about 61 pt, but each dot takes taps across its whole grid pitch (about 73 pt). A hit area is never under 64 pt in Minik mode (HIG minimum 44 pt applies everywhere) |
| Ç3 | No pinch, two-finger or double-tap requirement | Zoom only in Büyük mode |
| Ç4 | Forgiving taps | A finger that slides still taps if it lifts within 12 lp of the control (`ForgivingTap`); the palette picks the dot under the lifted finger |
| Ç5 | Palms and extra fingers do nothing | The first finger owns the canvas (`CanvasGestureMachine`) |
| Ç6 | Nothing is lost | Autosave 400 ms after a change, on leaving and on going to the background; no Save button |
| Ç7 | Undo always visible; no clear-all button | If a clear-all is ever added, it goes behind the parental gate |
| Ç8 | Instant feedback | Fill on finger down, reveal 220 ms, sound and light haptic |
| Ç9 | No way out of the app for the child | Sharing, saving to the gallery, printing, settings, deleting, links and purchases only behind `showParentalGate`; Android immersive; home ignores system back |
| Ç10 | No error text for the child | Sad face and the home button; text only in grown-up areas |

## HIG and App Review points that keep coming up

- Contrast: text at least 4.5:1 (3:1 for 18 pt+ or bold), icons too. Never tint an icon with the
  selected paint colour; use `KidButton(badgeColor:)`. Light palette dots keep a dark rim.
- Reduce Motion: use `reduceMotion(context)` from `lib/widgets/motion.dart` (iOS reports it only
  through `PlatformDispatcher.accessibilityFeatures.reduceMotion`). Skip confetti, reveals, shakes.
- Sound: effects use the ambient audio session (they follow the Silent switch and mix with music).
- Text: scaling is clamped at 200% app-wide; layouts must survive it.
- Layout adapts to the space it gets, not to the device type: check 320, 375, 393 and 430 pt
  wide, landscape phone and iPad split view. `KidPalette` sizes cells from its constraints;
  drawing and hit-testing use the same grid.
- The canvas card is exactly the page's aspect ratio: every white spot the child sees takes paint.
- VoiceOver: every custom control has a label, the button trait and `onTap`; colours have names
  (`colorNames` in the ARB files).
- Kids Category: no ads, no analytics, no external links or purchases without the gate; the
  privacy policy is inside the app (Parents area).
- Money (council decision, 3 Nov 2026): one non-consumable "Full Version" unlock, nothing else.
  The only price on screen is on `FullVersionScreen` behind the gate, read from the store. The
  child's screens are identical before and after the purchase: no lock, badge, "more" tile,
  countdown or changed card order. The free subset is fixed in `tool/pages/catalog.json`
  (`free: true`); a page that was free stays free. All of it is off unless the app is built with
  `--dart-define=COBI_IAP=true`.
- iPad: pass `sharePositionOrigin` to every share, or the popover crashes.
- System undo (3 Nov 2026): only Büyük hands the picture's undo stack to the system
  (`UndoManagerClient` in the coloring screen, `UndoManager.setUndoState` on every document
  change), so the iPadOS three-finger gestures, a hardware keyboard's Cmd-Z and the Undo/Redo
  bubble work there. Minik never does: a palm with three fingers changes nothing (Ç5), and Minik
  has no keyboard bindings either. Büyük binds Cmd-Z / Shift-Cmd-Z on Apple platforms and
  Ctrl-Z / Ctrl-Shift-Z / Ctrl-Y elsewhere (`_keyboardUndo`). Shake-to-undo stays off for
  everyone (`applicationSupportsShakeToEdit = false` in AppDelegate): a child shakes the device.
- Exports (3 Nov 2026): Android's share sheet has no Print or Save, so behind the gate My Artworks
  offers Save to gallery, Print and Print blank page through `ExportService`
  (`lib/services/export_service.dart`, channel `cobi.paint/export` in `MainActivity.kt`: MediaStore
  from Android 10 without any permission, `PrintHelper` for the system print dialog). iOS keeps the
  share sheet, which has both. The capabilities come from the platform, so iOS and the tests see the
  plain sheet; the privacy text (ARB and `docs/privacy_policy.html`) names both actions.
- Mirror drawing (council decision, 3 Nov 2026): only on the free drawing page, where it takes the
  fill button's place (a fifth 82 pt button does not fit a 375 pt phone, and a bucket on a blank
  page only recolours the paper). Minik has one switch: four-way on or off. Büyük cycles off, 2,
  4, 6 on the same button, no menu. A stroke carries its symmetry (`Stroke.symmetry`, JSON key
  `m`); copies are drawn by `PageLayers.paintStroke`, never stored, so one stroke is one undo step
  and the eraser mirrors too. `MirrorGlyph` shows one petal and its copies; the faint mirror lines
  on the canvas are not part of the saved picture.
- Stickers (council decision, 3 Nov 2026): no sticker button and no picker. The brush button's
  cycle ends with the sticker mode (marker, rainbow, crayon in Büyük, sticker); every stamp is the
  next of the 16 stickers in `lib/data/stickers.dart` (generated by
  `tool/stickers/build_stickers.py` from Fluent UI Emoji), and the button shows which one comes
  next. A finger down stamps one, a drag leaves a trail, one finger is one undo step, the eraser
  peels the stickers it runs over and the mirror copies stamps too. Stickers live in
  `ColoringDocument.stickers` (optional JSON key `stickers`), draw above the line art and never
  count towards finishing a page.
- Brushes (council decision, 3 Nov 2026; the extra brushes waited for incremental baking): marker,
  rainbow, crayon, spray, glitter and neon, all drawn by `drawStroke` in
  `lib/engine/render/page_layers.dart`. Minik cycles marker, rainbow, spray, glitter, sticker;
  Büyük adds the crayon after the rainbow and the neon pen after the glitter (`_bigOnlyBrushes` in
  the coloring screen). No menu: the button's glyph changes with every state (`SprayGlyph`,
  `NeonGlyph`, the sparkles icon for glitter), the badge keeps the colour and VoiceOver reads the
  name. Every brush is deterministic: the scattered ones seed their randomness from the stroke's
  first point and size (`_seeded`), so a saved or mirrored stroke looks the same everywhere. No
  blur filters, no animation, and a tap with any brush leaves a mark. The picture under the finger
  is a Fluent UI Emoji tool in `assets/images/tools/` (paintbrush, crayon, extinguisher, wand,
  flashlight) with its tip at the finger.

## Coloring pages

A page works for a toddler when it has closed areas a fingertip can hit. The bundled pages are
generated, never hand-edited: `tool/pages/catalog.json` lists the subjects (Fluent UI Emoji,
MIT, pinned commit) with Turkish and English names, and `tool/pages/build_pages.py` downloads,
renders, outlines, measures and writes `assets/pages/<category>/<code>.png` plus
`lib/data/builtin_images.dart` with each page's level:

```bash
python3 tool/pages/build_pages.py --work /tmp/cobi-pages --dart ~/flutter/sdk/flutter/bin/dart
```

Levels come from the page check (same rule in `PageCheck.level` and `level_for`): 1 = up to
4 finger-sized areas and 10 regions, 3 = 8+ finger areas or 16+ regions, else 2. Pages are never
locked; a category lists the child's current level first (`lib/data/page_order.dart`).

Catalog rules (5 Nov 2026, nine categories, 307 pages): an entry that cannot ship keeps
`"skip": "<reason>"` and `test/builtin_images_test.dart` keeps the catalog and the bundle identical.
A page id is `<category>_<code>` and saved artworks store it with the asset path, so a shipped page
never changes category. A new category goes last on the home screen (children find cards by
place), gets exactly 8 free pages, mostly level 1, and a spoken-name row in `tool/voice/README.md`.
Passing the page check is not enough: look at the new pages and drop the ones a 3-year-old would not
recognise (abstract tiles, text inside the art, near-duplicates of a page already in the app).

For hand-drawn art, run the check before adding a page:

```bash
~/flutter/sdk/flutter/bin/dart run tool/page_report.dart <page.png>
```

Use the Flutter SDK's own `dart`; an older Homebrew `dart` on PATH cannot run the tools.
`PROBLEM` blocks the page; `weak` means redraw when there is time. The built-in page test keeps
the list of failing pages (`_pagesToRedraw` in `test/engine/region_builder_test.dart`) exact and
checks every catalog level against the page check.

## Building blocks in the code

- `KidButton`, `PressableCard`, `ForgivingTap`, `EraserGlyph`: `lib/widgets/kid_button.dart`
- `KidPalette`: `lib/widgets/kid_palette.dart`
- `showParentalGate`: `lib/widgets/parental_gate.dart` (four number words, growing lockout,
  20 s idle close unless assistive navigation is on)
- `showCelebration`: `lib/widgets/celebration.dart`
- Control sizes: `_Metrics` in `lib/screens/coloring_screen.dart`
- Page quality: `PageCheck` in `lib/engine/region/page_check.dart`

## Before calling a UI change done

1. `flutter analyze` and `flutter test`. The tests include the narrow-phone palette test and the
   tap target, label and contrast guideline checks (`meetsGuideline`, `test/accessibility_test.dart`
   covers home, category, coloring page, My Artworks, its sheet and dialog); add a guideline check
   for every new screen.
2. Run it: phone portrait and landscape, a 375 pt and a 393 pt wide phone, iPad, and a 320 pt
   Split View pane (the controls shrink to fit, never below 44 pt). Use only the
   separate `CobiPaint_Pixel` emulator (port 5580), never the Replay emulator (5554).
3. Check with Reduce Motion on, the Silent switch on, VoiceOver on and text size at maximum.
4. Write the HIG and App Review result per item (COMPLIANT / JUSTIFIED DEVIATION / GAP).

Sources: https://developer.apple.com/design/human-interface-guidelines ,
https://developer.apple.com/kids/ , https://developer.apple.com/app-store/review/guidelines/ ,
the reports under `plan/` in this repo.
