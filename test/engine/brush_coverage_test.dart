import 'dart:typed_data';

import 'package:cobi_paint_mobile/engine/document/brush_coverage.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 100 x 100 page: label 1 is the background ring, label 2 the 60 x 60
/// square in the middle (20..79).
LabelMap _page() {
  final labels = Uint16List(100 * 100);
  var inner = 0;
  for (var y = 0; y < 100; y++) {
    for (var x = 0; x < 100; x++) {
      final inside = x >= 20 && x < 80 && y >= 20 && y < 80;
      labels[y * 100 + x] = inside ? 2 : 1;
      if (inside) inner++;
    }
  }
  return LabelMap(
    width: 100,
    height: 100,
    labels: labels,
    regions: [
      RegionInfo(left: 0, top: 0, right: 99, bottom: 99, area: 10000 - inner),
      RegionInfo(left: 20, top: 20, right: 79, bottom: 79, area: inner),
    ],
  );
}

/// Horizontal zig-zag rows across the square, [rows] of them, [size] wide.
Stroke _rows(int rows, double size, {int argb = 0xFF1E88E5, int clip = 2, BrushKind kind = BrushKind.marker}) {
  final points = <double>[];
  for (var i = 0; i < rows; i++) {
    final y = 22.0 + i * (56.0 / (rows - 1));
    final fromLeft = i.isEven;
    points.addAll([fromLeft ? 22 : 78, y, 0.5, fromLeft ? 78 : 22, y, 0.5]);
  }
  return Stroke(kind: kind, argb: argb, size: size, clipLabel: clip, points: Float32List.fromList(points));
}

void main() {
  final map = _page();

  test('an unpainted region has no coverage', () {
    final c = BrushCoverage.measure(map, const [], 2);
    expect(c.ratio, 0);
    expect(c.argb, 0);
  });

  test('dense rows cover nearly all of the square and report their colour', () {
    final c = BrushCoverage.measure(map, [_rows(8, 12)], 2);
    expect(c.ratio, greaterThan(0.9));
    expect(c.argb, 0xFF1E88E5);
  });

  test('a single line covers only a strip', () {
    final c = BrushCoverage.measure(map, [_rows(2, 8)], 2);
    expect(c.ratio, lessThan(0.4));
  });

  test('strokes that belong to another region add nothing', () {
    final c = BrushCoverage.measure(map, [_rows(8, 12, clip: 1)], 2);
    expect(c.ratio, 0);
  });

  test('the eraser takes paint away again', () {
    final paint = _rows(8, 12);
    final erase = Stroke(
      kind: BrushKind.eraser,
      argb: 0,
      size: 40,
      points: Float32List.fromList([30, 50, 0.5, 70, 50, 0.5]),
    );
    final before = BrushCoverage.measure(map, [paint], 2).ratio;
    final after = BrushCoverage.measure(map, [paint, erase], 2).ratio;
    expect(after, lessThan(before - 0.2));
  });

  test('the colour that covers most wins', () {
    final red = _rows(6, 12, argb: 0xFFE53935);
    final blueStrip = Stroke(
      kind: BrushKind.marker,
      argb: 0xFF1E88E5,
      size: 10,
      clipLabel: 2,
      points: Float32List.fromList([22, 30, 0.5, 78, 30, 0.5]),
    );
    final c = BrushCoverage.measure(map, [red, blueStrip], 2);
    expect(c.argb, 0xFFE53935);
  });

  test('mirrored strokes are skipped', () {
    final mirrored = Stroke(
      kind: BrushKind.marker,
      argb: 0xFF1E88E5,
      size: 30,
      clipLabel: 2,
      symmetry: 4,
      points: Float32List.fromList([30, 30, 0.5, 70, 70, 0.5]),
    );
    expect(BrushCoverage.measure(map, [mirrored], 2).ratio, 0);
  });
}
