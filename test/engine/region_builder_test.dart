import 'dart:io';
import 'dart:typed_data';

import 'package:cobi_paint_mobile/data/builtin_images.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/engine/region/region_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// White page with helpers to draw black pixels.
class _Page {
  _Page(this.width, this.height) : rgba = Uint8List(width * height * 4) {
    for (var i = 0; i < rgba.length; i++) {
      rgba[i] = 255;
    }
  }

  final int width;
  final int height;
  final Uint8List rgba;

  void ink(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    final p = (y * width + x) * 4;
    rgba[p] = 0;
    rgba[p + 1] = 0;
    rgba[p + 2] = 0;
  }

  /// Square outline; `dash` pixels drawn then `gap` pixels skipped.
  void outline(int left, int top, int right, int bottom, {int dash = 0, int gap = 0}) {
    var step = 0;
    bool drawn() => dash == 0 || step++ % (dash + gap) < dash;
    for (var x = left; x <= right; x++) {
      if (drawn()) ink(x, top);
    }
    for (var y = top; y <= bottom; y++) {
      if (drawn()) ink(right, y);
    }
    for (var x = right; x >= left; x--) {
      if (drawn()) ink(x, bottom);
    }
    for (var y = bottom; y >= top; y--) {
      if (drawn()) ink(left, y);
    }
  }

  LabelMap build({int gapPx = 0, int minRegionPixels = 1}) => RegionBuilder.build(
        rgba,
        width,
        height,
        options: RegionBuilderOptions(gapPx: gapPx, minRegionPixels: minRegionPixels, minRegionFraction: 0),
      );
}

LabelMap _buildAsset(String path) {
  final decoded = img.decodePng(File(path).readAsBytesSync())!;
  final rgbaImage = decoded.convert(numChannels: 4);
  final rgba = rgbaImage.getBytes(order: img.ChannelOrder.rgba);
  return RegionBuilder.build(rgba, decoded.width, decoded.height);
}

void main() {
  test('a one-pixel diagonal line keeps both sides apart', () {
    final page = _Page(20, 20);
    for (var i = 0; i < 20; i++) {
      page.ink(i, i);
    }
    final map = page.build();

    expect(map.regionCount, 2);
    expect(map.labelAt(15, 3), isNot(map.labelAt(3, 15)));
  });

  test('gap closing stops paint leaking through a dashed outline', () {
    final page = _Page(60, 60)..outline(10, 10, 49, 49, dash: 5, gap: 2);

    final open = page.build(gapPx: 0);
    expect(open.labelAt(30, 30), open.labelAt(2, 2), reason: 'without gap closing the inside leaks');

    final closed = page.build(gapPx: 2);
    expect(closed.labelAt(30, 30), isNot(closed.labelAt(2, 2)));
  });

  test('small closed areas survive gap closing', () {
    final page = _Page(60, 60)
      ..outline(5, 5, 54, 54)
      ..outline(28, 28, 32, 32); // 3x3 "pupil" inside the big square
    final map = page.build(gapPx: 2, minRegionPixels: 4);

    final pupil = map.labelAt(30, 30);
    expect(pupil, isNot(map.labelAt(15, 15)));
    expect(pupil, isNot(map.labelAt(1, 1)));
  });

  test('every pixel gets a region so fills reach under the lines', () {
    final dashed = _Page(60, 60)..outline(10, 10, 49, 49, dash: 5, gap: 2);
    expect(dashed.build(gapPx: 2).labels.where((l) => l == 0), isEmpty);

    // A 3-pixel line is split down the middle: each half belongs to its side.
    final thick = _Page(60, 60)
      ..outline(10, 10, 49, 49)
      ..outline(11, 11, 48, 48)
      ..outline(12, 12, 47, 47);
    final map = thick.build(gapPx: 2);
    final outside = map.labelAt(30, 2);
    final inside = map.labelAt(30, 30);
    expect(map.labelAt(30, 10), outside);
    expect(map.labelAt(30, 12), inside);
  });

  test('specks too small to tap merge into a neighbour', () {
    final page = _Page(30, 30);
    for (var x = 10; x < 20; x++) {
      for (var y = 0; y < 30; y++) {
        page.ink(x, y);
      }
    }
    // Re-open a 2x2 white speck inside the black band.
    for (final p in [(14, 14), (15, 14), (14, 15), (15, 15)]) {
      final i = (p.$2 * 30 + p.$1) * 4;
      page.rgba.fillRange(i, i + 3, 255);
    }
    final map = page.build(minRegionPixels: 8);

    expect(map.regionCount, 2);
    expect([map.labelAt(5, 5), map.labelAt(25, 5)], contains(map.labelAt(14, 14)));
  });

  test('transparent pixels count as paper', () {
    final rgba = Uint8List(20 * 20 * 4); // fully transparent black
    for (var y = 0; y < 20; y++) {
      final p = (y * 20 + 10) * 4;
      rgba[p + 3] = 255; // opaque black line at x = 10
    }
    final map = RegionBuilder.build(rgba, 20, 20, options: const RegionBuilderOptions(gapPx: 0, minRegionPixels: 1));

    expect(map.regionCount, 2);
  });

  test('a label map survives the cache round trip', () {
    final page = _Page(40, 30)..outline(5, 5, 30, 20);
    final map = page.build();
    final restored = LabelMap.fromBytes(map.toBytes())!;

    expect(restored.width, 40);
    expect(restored.height, 30);
    expect(restored.labels, map.labels);
    expect(restored.regionCount, map.regionCount);
    expect(restored.region(1).area, map.region(1).area);
    expect(LabelMap.fromBytes(Uint8List(8)), isNull);
  });

  group('built-in pages', () {
    test('the cat face is its own region despite the dotted head outline', () {
      final map = _buildAsset('assets/images/categories/animals/cat.png');
      final face = map.labelAt(200, 240);
      expect(face, isNot(map.labelAt(2, 2)));
      expect(map.region(face).area, lessThan(map.width * map.height ~/ 2));
    });

    test('every page builds and has a tappable region', () {
      for (final page in builtInImages) {
        final map = _buildAsset(page.imagePath);
        expect(map.regionCount, greaterThan(0), reason: page.imagePath);
        expect(map.labels.where((l) => l == 0), isEmpty, reason: page.imagePath);
      }
    });
  });
}
