import 'dart:typed_data';

import 'package:cobi_paint_mobile/engine/document/auto_complete.dart';
import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/engine/region/region_builder.dart';
import 'package:cobi_paint_mobile/models/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';

const blue = 0xFF1E88E5;
const red = 0xFFE53935;

/// 200 x 200 white page with a black square outline (20..179, 3 px wide):
/// the inside of the square and the background around it.
LabelMap squarePage() {
  const w = 200, h = 200;
  final rgba = Uint8List(w * h * 4)..fillRange(0, w * h * 4, 255);
  void black(int x, int y) {
    final p = (y * w + x) * 4;
    rgba.fillRange(p, p + 3, 0);
  }

  for (var i = 20; i < 180; i++) {
    for (var t = 0; t < 3; t++) {
      black(i, 20 + t);
      black(i, 177 + t);
      black(20 + t, i);
      black(177 + t, i);
    }
  }
  return RegionBuilder.build(rgba, w, h, options: const RegionBuilderOptions(gapPx: 0, minRegionPixels: 1, minRegionFraction: 0));
}

/// Back-and-forth rows across the square between [fromX] and [toX].
Stroke rows(
  int label, {
  int argb = blue,
  BrushKind kind = BrushKind.marker,
  double fromX = 28,
  double toX = 172,
  double gap = 14,
  double size = 22,
  double pressure = defaultPressure,
}) {
  final points = <double>[];
  var leftToRight = true;
  for (var y = 28.0; y <= 172; y += gap) {
    points.addAll([leftToRight ? fromX : toX, y, pressure, leftToRight ? toX : fromX, y, pressure]);
    leftToRight = !leftToRight;
  }
  return Stroke(kind: kind, argb: argb, size: size, clipLabel: label, points: Float32List.fromList(points));
}

void main() {
  final map = squarePage();
  final inside = map.labelAt(100, 100);
  final background = map.labelAt(2, 2);

  group('AutoComplete.evaluate', () {
    test('one marker colour over nearly all of the region completes it with that colour', () {
      final result = AutoComplete.evaluate(map, [rows(inside)], inside);
      expect(result, isNotNull);
      expect(result!.argb, blue);
      expect(map.labelAt(result.x, result.y), inside, reason: 'the saved point is inside the region');
    });

    test('a few lines are not nearly all of it', () {
      expect(AutoComplete.evaluate(map, [rows(inside, gap: 50, size: 10)], inside), isNull);
    });

    test('a region in two colours is left alone', () {
      final half = rows(inside, toX: 100);
      final otherHalf = rows(inside, argb: red, fromX: 100);
      expect(AutoComplete.evaluate(map, [half, otherHalf], inside), isNull);
    });

    test('a white gap the size of a fingertip stays white', () {
      // Rows on both sides leave a 30 px wide band down the middle.
      final leftRows = rows(inside, toX: 78);
      final rightRows = rows(inside, fromX: 122);
      expect(AutoComplete.evaluate(map, [leftRows, rightRows], inside), isNull);
    });

    test('other brushes do not count, and their paint stops the completion', () {
      expect(AutoComplete.evaluate(map, [rows(inside, kind: BrushKind.crayon)], inside), isNull);
      expect(AutoComplete.evaluate(map, [rows(inside), rows(inside, kind: BrushKind.spray, gap: 60, size: 8)], inside), isNull);
    });

    test('the eraser takes marker paint away again', () {
      final erase = Stroke(
        kind: BrushKind.eraser,
        argb: 0,
        size: 40,
        points: Float32List.fromList([40, 100, 0.5, 160, 100, 0.5]),
      );
      expect(AutoComplete.evaluate(map, [rows(inside), erase], inside), isNull);
    });

    test('strokes of another region add nothing', () {
      expect(AutoComplete.evaluate(map, [rows(background)], inside), isNull);
    });

    test('an Apple Pencil stroke counts with the width it was drawn with', () {
      expect(AutoComplete.evaluate(map, [rows(inside, pressure: 0.0)], inside), isNull,
          reason: 'the lightest touch leaves white bands between the rows');
      expect(AutoComplete.evaluate(map, [rows(inside, gap: 22, size: 14)], inside), isNull,
          reason: 'a line this thin at the finger pressure leaves bands');
      expect(AutoComplete.evaluate(map, [rows(inside, gap: 22, size: 14, pressure: 1.0)], inside), isNotNull,
          reason: 'a hard press covers them');
    });
  });

  group('the document', () {
    test('the stroke and its completion are one undo step', () {
      final doc = ColoringDocument(map);
      final stroke = rows(inside);
      final completion = doc.completionFor(stroke);
      expect(completion, isNotNull);
      doc.addStroke(stroke, completion: completion);
      expect(doc.fillOf(inside), blue);
      expect(doc.strokes, hasLength(1));

      doc.undo();
      expect(doc.fillOf(inside), 0);
      expect(doc.strokes, isEmpty);
      doc.redo();
      expect(doc.fillOf(inside), blue);
      expect(doc.strokes, hasLength(1));
    });

    test('a completion that was undone does not come back while the page is open', () {
      final doc = ColoringDocument(map);
      final stroke = rows(inside);
      doc.addStroke(stroke, completion: doc.completionFor(stroke));
      doc.undo();
      expect(doc.completionFor(rows(inside)), isNull);
    });

    test('a filled region, the background and non-marker strokes never ask', () {
      final doc = ColoringDocument(map);
      doc.fillAt(100, 100, red);
      expect(doc.completionFor(rows(inside)), isNull, reason: 'the region has a fill');
      final fresh = ColoringDocument(map);
      expect(fresh.completionFor(rows(background)), isNull, reason: 'the background');
      expect(fresh.completionFor(rows(inside, kind: BrushKind.rainbow)), isNull, reason: 'not the marker');
    });

    test('a completed region saves as an ordinary fill', () {
      final doc = ColoringDocument(map);
      final stroke = rows(inside);
      doc.addStroke(stroke, completion: doc.completionFor(stroke));
      final again = ColoringDocument(map)..restore(doc.toJson());
      expect(again.fillOf(inside), blue);
      expect(again.strokes, hasLength(1));
    });
  });

  test('the setting is on by default and for settings saved before it existed', () {
    expect(UserSettings().autoComplete, isTrue);
    expect(UserSettings.fromJson({'ageMode': 'little'}).autoComplete, isTrue);
    expect(UserSettings.fromJson(UserSettings(autoComplete: false).toJson()).autoComplete, isFalse);
  });
}
