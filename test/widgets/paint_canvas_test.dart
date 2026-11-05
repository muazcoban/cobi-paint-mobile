import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/engine/region/region_builder.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/gestures.dart';
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

  Future<void> pumpCanvas(
    WidgetTester tester, {
    CanvasTool tool = CanvasTool.fill,
    BrushKind brush = BrushKind.marker,
    bool allowZoom = false,
    int symmetry = 1,
    List<String> stickers = const [],
    double stickerSize = 0,
    void Function(int count)? onStamped,
    bool autoComplete = false,
    bool penPressure = false,
    void Function(int label)? onFilled,
  }) async {
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
            brush: brush,
            color: red,
            brushSize: 8,
            allowZoom: allowZoom,
            symmetry: symmetry,
            stickers: stickers,
            stickerSize: stickerSize,
            onStamped: onStamped,
            autoComplete: autoComplete,
            penPressure: penPressure,
            onFilled: onFilled,
          ),
        ),
      ),
    ));
  }

  int left() => document.map.labelAt(50, 50);
  int right() => document.map.labelAt(150, 50);

  Offset at(WidgetTester tester, double pageX, double pageY) =>
      tester.getTopLeft(find.byType(PaintCanvas)) + Offset(pageX * 2, pageY * 2);

  // Back-and-forth marker rows over the right half, 6 page px apart with an
  // 8 px brush: nearly all of it, short of the corners by the lines.
  Future<void> colourRightHalf(WidgetTester tester) async {
    final gesture = await tester.startGesture(at(tester, 106, 6));
    var leftToRight = true;
    for (var y = 6.0; y <= 94; y += 6) {
      for (var i = 0; i <= 6; i++) {
        final x = leftToRight ? 106.0 + i * 15 : 196.0 - i * 15;
        await gesture.moveTo(at(tester, x, y));
      }
      leftToRight = !leftToRight;
    }
    await gesture.up();
    await tester.pump();
  }

  // A pencil (or another [kind]) drawn through page points, each with the
  // force iOS reports; it lifts a little further on with no force, as an
  // Apple Pencil does.
  Future<void> drawWith(
    WidgetTester tester,
    List<(double, double, double)> path, {
    PointerDeviceKind kind = PointerDeviceKind.stylus,
  }) async {
    const pointer = 9;
    var time = Duration.zero;
    final (x0, y0, f0) = path.first;
    await tester.sendEventToBinding(PointerDownEvent(
        pointer: pointer, kind: kind, position: at(tester, x0, y0), pressure: f0, pressureMax: 4.17, timeStamp: time));
    for (final (x, y, f) in path.skip(1)) {
      time += const Duration(milliseconds: 16);
      await tester.sendEventToBinding(PointerMoveEvent(
          pointer: pointer, kind: kind, position: at(tester, x, y), pressure: f, pressureMax: 4.17, timeStamp: time));
    }
    final (xl, yl, _) = path.last;
    time += const Duration(milliseconds: 16);
    await tester.sendEventToBinding(PointerUpEvent(
        pointer: pointer, kind: kind, position: at(tester, xl + 4, yl), pressure: 0, pressureMax: 4.17, timeStamp: time));
    await tester.pump();
  }

  List<double> pressures(Stroke stroke) => [for (var i = 2; i < stroke.points.length; i += 3) stroke.points[i]];

  const pencilPath = [(20.0, 50.0, 0.4), (40.0, 50.0, 1.0), (60.0, 50.0, 2.0), (80.0, 50.0, 3.0)];

  testWidgets('in Büyük mode an Apple Pencil marker keeps the pressure of every point', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.marker, penPressure: true);
    await drawWith(tester, pencilPath);
    final stroke = document.strokes.single;
    final p = pressures(stroke);
    expect(p.first, closeTo(0.2, 1e-6), reason: 'a light first touch');
    expect(p, anyElement(closeTo(defaultPressure, 1e-6)), reason: 'an average touch is the finger width');
    expect(p.last, closeTo(1.0, 1e-6), reason: 'the lift-off reports no force; the line ends at the last pressure');
    expect(stroke.hasPressure, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('a finger, Minik mode and the brushes without pressure keep the brush width', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.marker, penPressure: true);
    await drawWith(tester, pencilPath, kind: PointerDeviceKind.touch);
    expect(document.strokes.single.hasPressure, isFalse, reason: 'a finger');

    await pumpCanvas(tester, tool: CanvasTool.marker);
    await drawWith(tester, pencilPath);
    expect(document.strokes.single.hasPressure, isFalse, reason: 'a pencil in Minik mode');

    await pumpCanvas(tester, tool: CanvasTool.marker, brush: BrushKind.rainbow, penPressure: true);
    await drawWith(tester, pencilPath);
    expect(document.strokes.single.hasPressure, isFalse, reason: 'the rainbow brush');
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('a pen wins over a palm that landed first', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.marker, allowZoom: true);
    await tester.sendEventToBinding(PointerDownEvent(pointer: 3, position: at(tester, 150, 50)));
    await tester.sendEventToBinding(PointerMoveEvent(pointer: 3, position: at(tester, 160, 55), timeStamp: const Duration(milliseconds: 100)));
    await drawWith(tester, pencilPath);
    await tester.sendEventToBinding(PointerCancelEvent(pointer: 3));
    await tester.pump();
    final stroke = document.strokes.single;
    expect(stroke.clipLabel, left(), reason: 'the pen\'s line, not the palm\'s');
  });

  testWidgets('a stylus on Android keeps the brush width', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.marker, penPressure: true);
    await drawWith(tester, pencilPath);
    expect(document.strokes.single.hasPressure, isFalse);
  });

  testWidgets('a drawn stroke reopens exactly as drawn, scattered grain included', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.marker, brush: BrushKind.spray);
    // Off the tenth grid the saved file keeps: the page shows at 2x here.
    final gesture = await tester.startGesture(at(tester, 20.37, 30.21));
    await gesture.moveTo(at(tester, 60.53, 40.77));
    await gesture.moveTo(at(tester, 80.11, 60.49));
    await gesture.up();
    await tester.pump();
    final drawn = document.strokes.single;
    final reopened = Stroke.fromJson(drawn.toJson())!;
    // The scatter of spray, glitter and pastel grain is seeded by the first
    // point, so the points must come back exactly.
    expect(reopened.points, drawn.points);
  });

  testWidgets('a marker that covers nearly all of a region completes it like a tap fill', (tester) async {
    final filled = <int>[];
    await pumpCanvas(tester, tool: CanvasTool.marker, autoComplete: true, onFilled: filled.add);
    await colourRightHalf(tester);

    expect(document.strokes, hasLength(1));
    expect(document.fillOf(right()), red.toARGB32(), reason: 'the corners filled with the marker colour');
    expect(filled, [right()], reason: 'it goes the tap-fill way: sound, haptic, celebration check');
    document.undo();
    expect(document.strokes, isEmpty);
    expect(document.fillOf(right()), 0, reason: 'one finger, one undo step');
  });

  testWidgets('with the setting off the marker never fills', (tester) async {
    final filled = <int>[];
    await pumpCanvas(tester, tool: CanvasTool.marker, onFilled: filled.add);
    await colourRightHalf(tester);

    expect(document.strokes, hasLength(1));
    expect(document.fillOf(right()), 0);
    expect(filled, isEmpty);
  });

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

  testWidgets('spray, glitter and neon drags commit a stroke of their kind', (tester) async {
    for (final kind in [BrushKind.spray, BrushKind.glitter, BrushKind.neon]) {
      await pumpCanvas(tester, tool: CanvasTool.marker, brush: kind);
      final gesture = await tester.startGesture(at(tester, 20, 20));
      await gesture.moveTo(at(tester, 60, 30));
      await gesture.up();
      expect(document.strokes.single.kind, kind, reason: 'the canvas commits the brush it was given');
    }
  });

  testWidgets('with the mirror on, a drag commits one stroke that carries the symmetry', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.marker, symmetry: 2);
    final gesture = await tester.startGesture(at(tester, 20, 20));
    await gesture.moveTo(at(tester, 60, 30));
    await gesture.up();

    expect(document.strokes, hasLength(1));
    expect(document.strokes.single.symmetry, 2);
  });

  testWidgets('the sticker tool sticks the next sticker where the finger went down', (tester) async {
    var stamped = 0;
    await pumpCanvas(
      tester,
      tool: CanvasTool.sticker,
      stickers: const ['star', 'red_heart'],
      stickerSize: 20,
      onStamped: (count) => stamped += count,
    );
    await tester.tapAt(at(tester, 50, 50));
    await tester.pump();

    final sticker = document.stickers.single;
    expect(sticker.code, 'star');
    expect((sticker.center - const Offset(50, 50)).distance, lessThan(1));
    expect(sticker.size, 20);
    expect(stamped, 1);
    expect(document.strokes, isEmpty, reason: 'a stamp is not a stroke');
  });

  testWidgets('a drag leaves a trail of changing stickers that one undo removes', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.sticker, stickers: const ['star', 'red_heart'], stickerSize: 20);
    final gesture = await tester.startGesture(at(tester, 20, 50));
    for (var i = 1; i <= 8; i++) {
      await gesture.moveTo(at(tester, 20.0 + i * 20, 50));
    }
    await gesture.up();
    await tester.pump();

    expect(document.stickers.length, inInclusiveRange(3, 8));
    expect(document.stickers.map((s) => s.code).toSet(), {'star', 'red_heart'});
    for (var i = 1; i < document.stickers.length; i++) {
      final gap = (document.stickers[i].center - document.stickers[i - 1].center).distance;
      expect(gap, greaterThanOrEqualTo(20 * 1.15 - 1), reason: 'stickers do not pile up');
    }
    document.undo();
    expect(document.stickers, isEmpty);
  });

  testWidgets('with the mirror on, a sticker gets its copy on the other side', (tester) async {
    await pumpCanvas(tester, tool: CanvasTool.sticker, symmetry: 2, stickers: const ['star'], stickerSize: 20);
    await tester.tapAt(at(tester, 50, 50));
    await tester.pump();

    expect(document.stickers, hasLength(2));
    expect((document.stickers[1].center - const Offset(150, 50)).distance, lessThan(1));
    document.undo();
    expect(document.stickers, isEmpty, reason: 'both come off together');
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
