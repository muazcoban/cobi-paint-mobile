import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/engine/region/region_builder.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const red = Color(0xFFE53935);

/// 200x100 page with a vertical line at x = 100: left and right regions.
Uint8List twoRegionPage() {
  final rgba = Uint8List(200 * 100 * 4)..fillRange(0, 200 * 100 * 4, 255);
  for (var y = 0; y < 100; y++) {
    for (var x = 99; x <= 101; x++) {
      final p = (y * 200 + x) * 4;
      rgba.fillRange(p, p + 3, 0);
    }
  }
  return rgba;
}

Future<ui.Image> imageFrom(Uint8List rgba, int w, int h) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(rgba);
  final descriptor = ui.ImageDescriptor.raw(buffer, width: w, height: h, pixelFormat: ui.PixelFormat.rgba8888);
  final codec = await descriptor.instantiateCodec();
  return (await codec.getNextFrame()).image;
}

void main() {
  late ColoringDocument document;
  late ui.Image page;

  Future<void> pumpCanvas(WidgetTester tester, {CanvasTool tool = CanvasTool.fill, bool allowZoom = false}) async {
    final rgba = twoRegionPage();
    document = ColoringDocument(RegionBuilder.build(rgba, 200, 100, options: const RegionBuilderOptions(gapPx: 0)));
    page = (await tester.runAsync(() => imageFrom(rgba, 200, 100)))!;
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: 400,
          height: 200, // page shown at 2x, filling the box
          child: PaintCanvas(
            document: document,
            page: page,
            tool: tool,
            color: red,
            brushSize: 8,
            allowZoom: allowZoom,
          ),
        ),
      ),
    ));
  }

  int left() => document.map.labelAt(50, 50);
  int right() => document.map.labelAt(150, 50);

  Offset at(WidgetTester tester, double pageX, double pageY) =>
      tester.getTopLeft(find.byType(PaintCanvas)) + Offset(pageX * 2, pageY * 2);

  testWidgets('a tap fills the region under the finger', (tester) async {
    await pumpCanvas(tester);
    await tester.tapAt(at(tester, 50, 50));

    expect(document.fillOf(left()), red.toARGB32());
    expect(document.fillOf(right()), 0);
  });

  testWidgets('a toddler slide still counts as a tap in zoom mode', (tester) async {
    await pumpCanvas(tester, allowZoom: true);
    final gesture = await tester.startGesture(at(tester, 150, 50));
    await gesture.moveBy(const Offset(14, 9)); // under the 20 lp slop
    await gesture.up();

    expect(document.fillOf(right()), red.toARGB32());
  });

  testWidgets('a palm on the other half does not fill it', (tester) async {
    await pumpCanvas(tester);
    final finger = await tester.startGesture(at(tester, 50, 50), pointer: 1);
    final palm = await tester.startGesture(at(tester, 150, 50), pointer: 2);
    await palm.up();
    await finger.up();

    expect(document.fillOf(left()), red.toARGB32());
    expect(document.fillOf(right()), 0);
  });

  testWidgets('a marker drag becomes one stroke that stays in its region', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.marker);
    final gesture = await tester.startGesture(at(tester, 20, 20));
    for (var i = 1; i <= 10; i++) {
      await gesture.moveTo(at(tester, 20.0 + i * 15, 20));
    }
    await gesture.up();

    expect(document.strokes, hasLength(1));
    final stroke = document.strokes.single;
    expect(stroke.kind, BrushKind.marker);
    expect(stroke.clipLabel, left());
    expect(stroke.pointCount, greaterThan(5));
  });

  testWidgets('a cancelled stroke leaves nothing behind', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.marker);
    final gesture = await tester.startGesture(at(tester, 20, 20));
    await gesture.moveTo(at(tester, 60, 20));
    await gesture.cancel();

    expect(document.strokes, isEmpty);
  });

  testWidgets('the eraser empties the regions it rubs', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.eraser);
    document.fillAt(50, 50, red.toARGB32());
    document.fillAt(150, 50, red.toARGB32());

    final gesture = await tester.startGesture(at(tester, 30, 50));
    await gesture.moveTo(at(tester, 70, 50));
    await gesture.up();

    expect(document.fillOf(left()), 0);
    expect(document.fillOf(right()), red.toARGB32());
  });

  testWidgets('two fingers pinch in zoom mode without painting', (tester) async {
    await pumpCanvas(tester, allowZoom: true);
    final a = await tester.startGesture(at(tester, 80, 50), pointer: 1);
    final b = await tester.startGesture(at(tester, 120, 50), pointer: 2);
    await b.moveBy(const Offset(80, 0));
    await a.moveBy(const Offset(-80, 0));
    await b.up();
    await a.up();
    await tester.pump();

    expect(document.isEmpty, isTrue);
  });
}
