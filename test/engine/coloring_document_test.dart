import 'dart:typed_data';

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/sticker.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/engine/region/region_builder.dart';
import 'package:flutter_test/flutter_test.dart';

const red = 0xFFE53935;
const blue = 0xFF1E88E5;

/// 20x10 page split by a vertical line at x = 10: left and right regions.
LabelMap twoRegions() {
  final rgba = Uint8List(20 * 10 * 4)..fillRange(0, 20 * 10 * 4, 255);
  for (var y = 0; y < 10; y++) {
    final p = (y * 20 + 10) * 4;
    rgba.fillRange(p, p + 3, 0);
  }
  return RegionBuilder.build(rgba, 20, 10, options: const RegionBuilderOptions(gapPx: 0, minRegionPixels: 1, minRegionFraction: 0));
}

Stroke marker() => Stroke(kind: BrushKind.marker, argb: blue, size: 4, points: Float32List.fromList([1, 1, 0.5, 5, 5, 0.5]));

void main() {
  late ColoringDocument doc;
  late int left;
  late int right;

  setUp(() {
    doc = ColoringDocument(twoRegions());
    left = doc.map.labelAt(2, 5);
    right = doc.map.labelAt(17, 5);
  });

  test('a tap fills exactly one region and reports it', () {
    expect(doc.fillAt(2, 5, red), left);
    expect(doc.fillOf(left), red);
    expect(doc.fillOf(right), 0);
    expect(doc.takeDirtyLabels(), {left});
    expect(doc.takeDirtyLabels(), isEmpty);
  });

  test('filling with the same colour again is not a new step', () {
    doc.fillAt(2, 5, red);
    expect(doc.fillAt(3, 3, red), 0);
    doc.undo();
    expect(doc.canUndo, isFalse);
  });

  test('undo and redo walk through fills and strokes', () {
    doc.fillAt(2, 5, red);
    doc.fillAt(2, 5, blue);
    doc.addStroke(marker());

    doc.undo();
    expect(doc.strokes, isEmpty);
    doc.undo();
    expect(doc.fillOf(left), red);
    doc.redo();
    expect(doc.fillOf(left), blue);
    expect(doc.canRedo, isTrue);

    doc.fillAt(17, 5, red);
    expect(doc.canRedo, isFalse, reason: 'a new step drops the redo history');
  });

  test('clear can be undone in one step', () {
    doc.fillAt(2, 5, red);
    doc.addStroke(marker());
    doc.clear();
    expect(doc.isEmpty, isTrue);
    expect(doc.takeDirtyLabels(), isNull, reason: 'clear redraws every region');

    doc.undo();
    expect(doc.fillOf(left), red);
    expect(doc.strokes, hasLength(1));
  });

  test('the eraser empties the regions it touched and undo brings them back', () {
    doc.fillAt(2, 5, red);
    doc.fillAt(17, 5, blue);
    final eraser = Stroke(kind: BrushKind.eraser, argb: 0, size: 6, points: Float32List.fromList([2, 5, 0.5]));

    doc.erase(eraser, {left});
    expect(doc.fillOf(left), 0);
    expect(doc.fillOf(right), blue);

    doc.undo();
    expect(doc.fillOf(left), red);
    expect(doc.strokes, isEmpty);
  });

  test('history keeps the last ${ColoringDocument.maxHistory} steps', () {
    for (var i = 0; i < ColoringDocument.maxHistory + 20; i++) {
      doc.fillAt(2, 5, i.isEven ? red : blue);
    }
    var steps = 0;
    while (doc.canUndo) {
      doc.undo();
      steps++;
    }
    expect(steps, ColoringDocument.maxHistory);
  });

  test('a saved document restores fills and strokes', () {
    doc.fillAt(2, 5, red);
    doc.addStroke(marker());

    final copy = ColoringDocument(doc.map)..restore(doc.toJson());
    expect(copy.fillOf(left), red);
    expect(copy.fillOf(right), 0);
    expect(copy.strokes.single.argb, blue);
    expect(copy.strokes.single.points, doc.strokes.single.points);
    expect(copy.canUndo, isFalse);
  });

  test('fills find their region by point when region numbers changed', () {
    final json = {
      'schema': 2,
      'labelAlgorithm': -1, // pretend an older algorithm numbered regions differently
      'fills': [
        {'l': 999, 'c': red, 'x': 17, 'y': 5},
      ],
    };
    doc.restore(json);
    expect(doc.fillOf(right), red);
    expect(doc.fillOf(left), 0);
  });

  test('version 1 pixel colours become region fills when they cover half a region', () {
    final pixels = <String, int>{};
    for (var y = 0; y < 10; y++) {
      for (var x = 0; x < 9; x++) {
        pixels['${y * 20 + x}'] = red; // most of the left region
      }
    }
    pixels['${5 * 20 + 15}'] = blue; // a single pencil dot on the right
    doc.restoreLegacyPixels(pixels);

    expect(doc.fillOf(left), red);
    expect(doc.fillOf(right), 0);
  });

  test('strokes survive JSON with one decimal of precision', () {
    final stroke = Stroke(
      kind: BrushKind.marker,
      argb: red,
      size: 9.5,
      clipLabel: 3,
      points: Float32List.fromList([1.24, 2.26, 0.5]),
    );
    final copy = Stroke.fromJson(stroke.toJson())!;
    expect(copy.kind, BrushKind.marker);
    expect(copy.clipLabel, 3);
    expect(copy.points[0], closeTo(1.2, 1e-6));
    expect(copy.points[1], closeTo(2.3, 1e-6));
    expect(Stroke.fromJson({'k': 'laser', 'p': []}), isNull);
  });

  test('the eraser counts when only rainbow or crayon paint is on the page', () {
    final path = Float32List.fromList([1, 1, 0.5, 5, 5, 0.5]);
    doc.addStroke(Stroke(kind: BrushKind.rainbow, argb: 0, size: 4, points: path));
    doc.erase(Stroke(kind: BrushKind.eraser, argb: 0, size: 6, points: path), const {});
    expect(doc.strokes, hasLength(2), reason: 'the eraser stroke is recorded');
    doc.undo();
    expect(doc.strokes, hasLength(1));
  });

  test('a mirrored stroke is one stroke and one undo step', () {
    final path = Float32List.fromList([1, 1, 0.5, 5, 5, 0.5]);
    doc.addStroke(Stroke(kind: BrushKind.marker, argb: blue, size: 4, symmetry: 6, points: path));
    expect(doc.strokes, hasLength(1));
    expect(doc.strokes.single.symmetry, 6);
    doc.undo();
    expect(doc.strokes, isEmpty);
    expect(doc.canUndo, isFalse);
  });

  group('stickers', () {
    Sticker star(double x, double y) => Sticker(code: 'star', x: x, y: y, size: 4);
    Stroke rub(List<double> xy, {int symmetry = 1}) => Stroke(
          kind: BrushKind.eraser,
          argb: 0,
          size: 2,
          symmetry: symmetry,
          points: Float32List.fromList([for (var i = 0; i < xy.length; i += 2) ...[xy[i], xy[i + 1], 0.5]]),
        );

    test('one finger of stickers is one step; undo takes the whole trail off', () {
      doc.stamp([star(3, 3), star(8, 3), star(13, 3)]);
      expect(doc.stickers, hasLength(3));
      expect(doc.isEmpty, isFalse);
      doc.undo();
      expect(doc.stickers, isEmpty);
      expect(doc.isEmpty, isTrue);
      doc.redo();
      expect(doc.stickers, hasLength(3));
      doc.undo();
      doc.stamp(const []);
      expect(doc.canRedo, isTrue, reason: 'an empty stamp is not a step, so the redo stays');
    });

    test('the eraser peels off the stickers it runs over; undo puts them back in place', () {
      doc.stamp([star(3, 3), star(16, 3)]);
      doc.stamp([star(3, 8)]);
      doc.erase(rub([1, 3, 6, 3]), const {}); // across the top-left sticker only
      expect(doc.stickers.map((s) => s.center), [const Offset(16, 3), const Offset(3, 8)]);
      expect(doc.strokes, hasLength(1), reason: 'the rub counts even without paint under it');
      doc.undo();
      expect(doc.stickers.map((s) => s.center), [const Offset(3, 3), const Offset(16, 3), const Offset(3, 8)]);
      doc.redo();
      expect(doc.stickers, hasLength(2));
    });

    test('a mirrored eraser peels the sticker under its copy too', () {
      doc.stamp([star(3, 3), star(17, 3)]); // the page is 20 wide: 17 mirrors 3
      doc.erase(rub([2, 3, 4, 3], symmetry: 2), const {});
      expect(doc.stickers, isEmpty);
    });

    test('an eraser that touches nothing is not a step', () {
      doc.stamp([star(3, 3)]);
      doc.erase(rub([15, 8, 18, 8]), const {});
      expect(doc.strokes, isEmpty);
      expect(doc.stickers, hasLength(1));
    });

    test('clear takes the stickers too and undo brings them back', () {
      doc.stamp([star(3, 3)]);
      doc.clear();
      expect(doc.stickers, isEmpty);
      expect(doc.isEmpty, isTrue);
      doc.undo();
      expect(doc.stickers, hasLength(1));
    });

    test('stickers survive JSON and a page without any stores no list', () {
      doc.stamp([const Sticker(code: 'red_heart', x: 3.25, y: 4, size: 5, angle: 0.1234)]);
      final copy = ColoringDocument(twoRegions())..restore(doc.toJson());
      final s = copy.stickers.single;
      expect(s.code, 'red_heart');
      expect(s.x, closeTo(3.3, 1e-9));
      expect(s.size, 5);
      expect(s.angle, closeTo(0.123, 1e-9));
      expect(copy.canUndo, isFalse, reason: 'history starts empty');
      expect(ColoringDocument(twoRegions()).toJson().containsKey('stickers'), isFalse);
    });
  });
}
