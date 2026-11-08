import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/engine/render/fill_patterns.dart';
import 'package:cobi_paint_mobile/engine/render/page_layers.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 40 x 40 page that is one region.
LabelMap _map() => LabelMap(
      width: 40,
      height: 40,
      labels: Uint16List(1600)..fillRange(0, 1600, 1),
      regions: const [RegionInfo(left: 0, top: 0, right: 39, bottom: 39, area: 1600)],
    );

/// The same 40 x 40 page split into a left and a right region at x = 20.
LabelMap _twoRegions() {
  final labels = Uint16List(1600);
  for (var y = 0; y < 40; y++) {
    for (var x = 0; x < 40; x++) {
      labels[y * 40 + x] = x < 20 ? 1 : 2;
    }
  }
  return LabelMap(
    width: 40,
    height: 40,
    labels: labels,
    regions: const [
      RegionInfo(left: 0, top: 0, right: 19, bottom: 39, area: 800),
      RegionInfo(left: 20, top: 0, right: 39, bottom: 39, area: 800),
    ],
  );
}

/// The ARGB colour of page pixel (x, y) in the baked fill image.
Future<List<int>> _fillArgb(PageLayers layers) async {
  final bytes = (await layers.fillImage!.toByteData())!.buffer.asUint8List();
  return [
    for (var i = 0; i < bytes.length; i += 4) (bytes[i + 3] << 24) | (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2],
  ];
}

Stroke _stroke(BrushKind kind, double x) => Stroke(
      kind: kind,
      argb: 0xFFE53935,
      size: 6,
      clipLabel: 1,
      points: Float32List.fromList([x, 5, 0.5, x + 2, 30, 0.5]),
    );

/// Pixels with any paint in the baked brush image.
Future<int> _painted(PageLayers layers) async {
  final bytes = (await layers.brushImage!.toByteData())!.buffer.asUint8List();
  var painted = 0;
  for (var i = 3; i < bytes.length; i += 4) {
    if (bytes[i] > 0) painted++;
  }
  return painted;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new strokes are drawn over the baked image and stay visible until baked', () async {
    final document = ColoringDocument(_map());
    final layers = PageLayers(document: document);
    addTearDown(layers.dispose);

    expect(layers.brushImage, isNull);
    final first = _stroke(BrushKind.marker, 5);
    document.addStroke(first);
    expect(layers.pendingStrokes(), [first], reason: 'committed but not baked');
    await layers.syncBrush();
    expect(layers.brushImage, isNotNull);
    expect(layers.pendingStrokes(), isEmpty);

    final second = _stroke(BrushKind.rainbow, 15);
    document.addStroke(second);
    expect(layers.pendingStrokes(), [second], reason: 'only the new stroke waits');
    await layers.syncBrush();
    expect(layers.pendingStrokes(), isEmpty);
    expect(layers.brushImage!.width, 40);
  });

  test('every brush kind leaves paint on the page', () async {
    final out = Platform.environment['COBI_TEST_OUT'];
    for (final kind in BrushKind.values.where((k) => k != BrushKind.eraser)) {
      final document = ColoringDocument(_map());
      final layers = PageLayers(document: document);
      document.addStroke(Stroke(
        kind: kind,
        argb: 0xFF1E88E5,
        size: 8,
        clipLabel: 1,
        points: Float32List.fromList([6, 8, 0.5, 20, 30, 0.5, 34, 10, 0.5]),
      ));
      await layers.syncBrush();
      expect(await _painted(layers), greaterThan(100), reason: '$kind paints pixels');
      if (out != null) {
        final png = await layers.brushImage!.toByteData(format: ImageByteFormat.png);
        File('$out/brush_${kind.name}.png').writeAsBytesSync(png!.buffer.asUint8List());
      }
      layers.dispose();
    }
  });

  test('a tap with every brush leaves a mark', () async {
    for (final kind in BrushKind.values.where((k) => k != BrushKind.eraser)) {
      final document = ColoringDocument(_map());
      final layers = PageLayers(document: document);
      document.addStroke(Stroke(kind: kind, argb: 0xFF1E88E5, size: 8, points: Float32List.fromList([20, 20, 0.5])));
      await layers.syncBrush();
      expect(await _painted(layers), greaterThan(10), reason: 'a $kind tap is a dot, not nothing');
      layers.dispose();
    }
  });

  test('a scattered brush bakes to the same pixels every time', () async {
    for (final kind in [BrushKind.crayon, BrushKind.spray, BrushKind.glitter]) {
      Future<List<int>> bake() async {
        final document = ColoringDocument(_map());
        final layers = PageLayers(document: document);
        document.addStroke(Stroke(
          kind: kind,
          argb: 0xFF43A047,
          size: 8,
          points: Float32List.fromList([6, 8, 0.5, 20, 30, 0.5, 34, 10, 0.5]),
        ));
        await layers.syncBrush();
        final bytes = List<int>.of((await layers.brushImage!.toByteData())!.buffer.asUint8List());
        layers.dispose();
        return bytes;
      }

      expect(await bake(), await bake(), reason: '$kind takes its randomness from the stroke itself');
    }
  });

  test('an undo and a clear bake the whole list again', () async {
    final document = ColoringDocument(_map());
    final layers = PageLayers(document: document);
    addTearDown(layers.dispose);

    document.addStroke(_stroke(BrushKind.crayon, 5));
    document.addStroke(_stroke(BrushKind.marker, 20));
    await layers.syncBrush();

    document.undo();
    expect(layers.pendingStrokes(), isEmpty, reason: 'nothing to draw on top after an undo');
    await layers.syncBrush();
    expect(layers.brushImage, isNotNull);

    document.clear();
    await layers.syncBrush();
    expect(layers.brushImage, isNull, reason: 'no strokes, no image');

    document.addStroke(_stroke(BrushKind.eraser, 8));
    await layers.syncBrush();
    expect(layers.brushImage, isNotNull);
  });

  group('fill patterns (council P9, 8 Nov 2026)', () {
    const red = 0xFFE53935;

    Future<List<int>> bake(FillPattern pattern, {LabelMap? map, int argb = red, bool both = false}) async {
      final document = ColoringDocument(map ?? _map());
      document.fillAt(5, 5, argb, pattern: pattern);
      if (both) document.fillAt(30, 5, argb, pattern: pattern);
      final layers = PageLayers(document: document);
      await layers.syncFills();
      final pixels = await _fillArgb(layers);
      layers.dispose();
      return pixels;
    }

    test('dots, stripes and the rainbow bake to the same pixels every time', () async {
      for (final pattern in [FillPattern.dots, FillPattern.stripes, FillPattern.rainbow]) {
        expect(await bake(pattern), await bake(pattern), reason: pattern.name);
      }
    });

    test('the pixel words keep the RGBA byte order', () async {
      final document = ColoringDocument(_map());
      document.fillAt(5, 5, red);
      final layers = PageLayers(document: document);
      addTearDown(layers.dispose);
      await layers.syncFills();
      final bytes = (await layers.fillImage!.toByteData())!.buffer.asUint8List();
      expect(bytes.sublist(0, 4), [0xE5, 0x39, 0x35, 0xFF]);
    });

    test('a dotted region keeps the child\'s colour as its ground and shows the mark tone', () async {
      final pixels = await bake(FillPattern.dots);
      final ground = pixels.where((p) => p == red).length;
      final mark = pixels.where((p) => p == markTone(red)).length;
      expect(ground / pixels.length, greaterThan(0.6), reason: 'red dominates');
      expect(mark / pixels.length, greaterThan(0.1), reason: 'the dots are there');
      expect(pixels.toSet().length, 3, reason: 'ground, mark and the blend ring, nothing else');
    });

    test('stripes are mark tone and colour only, the colour at least half', () async {
      // On this 40 px page the period is the 8 px floor, where two fifths
      // rounds to a half; the exact share is tested at 128 px in
      // fill_patterns_test.dart.
      final pixels = await bake(FillPattern.stripes);
      final mark = pixels.where((p) => p == markTone(red)).length;
      expect(mark / pixels.length, inInclusiveRange(0.3, 0.5));
      expect(pixels.toSet(), {red, markTone(red)});
    });

    test('a pattern is anchored to the page: a region split in two lines up with the whole', () async {
      for (final pattern in [FillPattern.dots, FillPattern.stripes]) {
        expect(await bake(pattern, map: _twoRegions(), both: true), await bake(pattern), reason: pattern.name);
      }
    });

    test('the rainbow runs red to purple down the region and ignores the colour', () async {
      final pixels = await bake(FillPattern.rainbow, argb: 0xFF212121);
      expect(pixels[0], 0xFFE53935, reason: 'top row');
      expect(pixels[39 * 40], 0xFF8E24AA, reason: 'bottom row');
      expect(pixels[20 * 40 + 3], pixels[20 * 40 + 36], reason: 'one colour per row');
      expect(pixels.contains(0xFF212121), isFalse);
    });

    test('a changed pattern repaints only its region', () async {
      final document = ColoringDocument(_twoRegions());
      document.fillAt(5, 5, red);
      document.fillAt(30, 5, 0xFF1E88E5);
      final layers = PageLayers(document: document);
      addTearDown(layers.dispose);
      await layers.syncFills();
      document.fillAt(5, 5, red, pattern: FillPattern.stripes);
      await layers.syncFills();
      final pixels = await _fillArgb(layers);
      expect(pixels[5 * 40 + 30], 0xFF1E88E5, reason: 'the right region is untouched');
      expect(pixels.sublist(0, 20).toSet(), {red, markTone(red)}, reason: 'the left region is striped now');
    });
  });

}
