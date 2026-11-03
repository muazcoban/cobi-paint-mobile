import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/engine/render/page_layers.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 40 x 40 page that is one region.
LabelMap _map() => LabelMap(
      width: 40,
      height: 40,
      labels: Uint16List(1600)..fillRange(0, 1600, 1),
      regions: const [RegionInfo(left: 0, top: 0, right: 39, bottom: 39, area: 1600)],
    );

Stroke _stroke(BrushKind kind, double x) => Stroke(
      kind: kind,
      argb: 0xFFE53935,
      size: 6,
      clipLabel: 1,
      points: Float32List.fromList([x, 5, 0.5, x + 2, 30, 0.5]),
    );

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
    for (final kind in [BrushKind.marker, BrushKind.rainbow, BrushKind.crayon]) {
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
      final bytes = (await layers.brushImage!.toByteData())!.buffer.asUint8List();
      var painted = 0;
      for (var i = 3; i < bytes.length; i += 4) {
        if (bytes[i] > 0) painted++;
      }
      expect(painted, greaterThan(100), reason: '$kind paints pixels');
      if (out != null) {
        final png = await layers.brushImage!.toByteData(format: ImageByteFormat.png);
        File('$out/brush_${kind.name}.png').writeAsBytesSync(png!.buffer.asUint8List());
      }
      layers.dispose();
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
}
