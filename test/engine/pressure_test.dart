import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/engine/render/page_layers.dart';
import 'package:cobi_paint_mobile/engine/render/pressure_outline.dart';
import 'package:flutter_test/flutter_test.dart';

/// Apple Pencil pressure in Büyük mode (council, 5 November 2026): the
/// marker, the pastel and the neon get wider as the pencil presses harder;
/// everything else keeps its width, and a picture looks the same after a
/// reload, in its mirror copies and on every device.

/// A 120 x 120 page that is one region.
LabelMap _page() => LabelMap(
      width: 120,
      height: 120,
      labels: Uint16List(120 * 120)..fillRange(0, 120 * 120, 1),
      regions: const [RegionInfo(left: 0, top: 0, right: 119, bottom: 119, area: 120 * 120)],
    );

Stroke _pencil(BrushKind kind, List<double> xyp, {double size = 12, int symmetry = 1}) => Stroke(
      kind: kind,
      argb: 0xFF1E88E5,
      size: size,
      symmetry: symmetry,
      points: Float32List.fromList(xyp),
    );

/// A straight line across the page at one pressure.
List<double> _line(double pressure, {double y = 60}) => [
      for (var x = 10.0; x <= 110; x += 4) ...[x, y, pressure],
    ];

/// Back-and-forth rows 6 px apart, so the 12 px line overlaps itself at
/// every turn, with the pressure rising and falling along the way.
List<double> _scribble() {
  final out = <double>[];
  var leftToRight = true;
  var k = 0;
  for (var y = 14.0; y <= 106; y += 6) {
    for (var i = 0; i <= 10; i++) {
      final x = leftToRight ? 12.0 + i * 9.6 : 108.0 - i * 9.6;
      out.addAll([x, y, ((k++ % 11) / 10)]);
    }
    leftToRight = !leftToRight;
  }
  return out;
}

/// A loop that crosses itself, drawn with a light touch.
List<double> _loop() => [
      for (var i = 0; i <= 80; i++)
        ...[60 + 35 * math.cos(i / 80 * 2.4 * math.pi), 60 + 35 * math.sin(i / 80 * 2.4 * math.pi), 0.2],
    ];

Future<Uint8List> _bake(List<Stroke> strokes) async {
  final document = ColoringDocument(_page());
  final layers = PageLayers(document: document);
  for (final s in strokes) {
    document.addStroke(s);
  }
  await layers.syncBrush();
  final bytes = (await layers.brushImage!.toByteData())!.buffer.asUint8List();
  layers.dispose();
  return Uint8List.fromList(bytes);
}

int _painted(Uint8List rgba) {
  var n = 0;
  for (var i = 3; i < rgba.length; i += 4) {
    if (rgba[i] > 0) n++;
  }
  return n;
}

/// Counts the draw calls a brush makes.
class _CountingCanvas implements Canvas {
  int paths = 0;
  int circles = 0;

  @override
  void drawPath(Path path, Paint paint) => paths++;

  @override
  void drawCircle(Offset c, double radius, Paint paint) => circles++;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the stored pressure', () {
    test('an average pencil touch is the finger pressure; light and hard presses go to the ends', () {
      expect(storedPressure(1.0), defaultPressure);
      expect(storedPressure(0), 0);
      expect(storedPressure(0.4), 0.2);
      expect(storedPressure(2.0), 1.0);
      expect(storedPressure(4.17), 1.0, reason: 'the hardest press stops at 1');
      expect(storedPressure(0.73), 0.4, reason: 'rounded to the tenth the file keeps');
    });

    test('the file keeps the pressure exactly, so a reopened picture is the one drawn', () {
      final drawn = _pencil(BrushKind.marker, [10, 10, storedPressure(0.4), 20.5, 30, storedPressure(1.7), 40, 50.1, 1]);
      final back = Stroke.fromJson(drawn.toJson())!;
      expect(back.points, drawn.points);
      expect(back.hasPressure, isTrue);
    });

    test('a stroke drawn with a finger has no pressure', () {
      expect(_pencil(BrushKind.marker, _line(defaultPressure)).hasPressure, isFalse);
      expect(_pencil(BrushKind.marker, _line(0.6)).hasPressure, isTrue);
    });

    test('the width factor is 1 at the finger pressure and ramps instead of jumping', () {
      final even = pressureFactors(_pencil(BrushKind.marker, _line(defaultPressure)));
      expect(even.every((f) => f == 1), isTrue);

      // Light for the first half, hard for the second.
      final pts = <double>[];
      for (var x = 10.0; x <= 110; x += 2) {
        pts.addAll([x, 60, x < 60 ? 0.2 : 0.9]);
      }
      final f = pressureFactors(_pencil(BrushKind.marker, pts));
      expect(f.first, closeTo(0.35 + 1.3 * 0.2, 0.04));
      expect(f.last, closeTo(0.35 + 1.3 * 0.9, 0.04));
      for (var i = 1; i < f.length; i++) {
        expect(f[i], greaterThanOrEqualTo(f[i - 1] - 1e-9), reason: 'never steps back');
        expect(f[i] - f[i - 1], lessThan(0.2), reason: 'no jump between two points');
      }
    });
  });

  group('the outline', () {
    test('covers every point of the centre line, also where a scribble turns and crosses itself', () {
      for (final (name, points) in [('line', _line(0.3)), ('scribble', _scribble()), ('loop', _loop())]) {
        for (final scale in [0.36, 1.0, 3.0]) {
          final spine = PressureSpine.of(_pencil(BrushKind.marker, points));
          final outline = spine.outline(scale);
          for (var i = 0; i < spine.sampleCount; i++) {
            expect(outline.contains(spine.sampleAt(i)), isTrue, reason: '$name at scale $scale, sample $i');
          }
        }
      }
    });

    test('a wide glow takes fewer samples and still covers the line', () {
      final spine = PressureSpine.of(_pencil(BrushKind.neon, _scribble(), size: 50));
      final glow = spine.outline(3.0);
      for (var i = 0; i < spine.sampleCount; i++) {
        expect(glow.contains(spine.sampleAt(i)), isTrue, reason: 'sample $i');
      }
    });

    test('a line drawn back over itself stays a proper shape', () {
      final there = [for (var x = 10.0; x <= 110; x += 2) ...[x, 60.0, 0.7]];
      final back = [for (var x = 108.0; x >= 10; x -= 2) ...[x, 60.0, 0.7]];
      final spine = PressureSpine.of(_pencil(BrushKind.neon, [...there, ...back], size: 50));
      for (final scale in [0.36, 1.0, 3.0]) {
        final outline = spine.outline(scale);
        expect(outline.getBounds().isFinite, isTrue, reason: 'no point without a direction at scale $scale');
        for (var i = 0; i < spine.sampleCount; i++) {
          expect(outline.contains(spine.sampleAt(i)), isTrue, reason: 'scale $scale, sample $i');
        }
      }
    });

    test('is as wide as the pressure says', () {
      for (final pressure in [0.0, 0.5, 1.0]) {
        final stroke = _pencil(BrushKind.marker, _line(pressure));
        final half = stroke.size / 2 * (0.35 + 1.3 * pressure);
        final outline = PressureSpine.of(stroke).outline(1);
        expect(outline.contains(Offset(60, 60 + half * 0.9)), isTrue, reason: 'inside at $pressure');
        expect(outline.contains(Offset(60, 60 + half * 1.1)), isFalse, reason: 'outside at $pressure');
      }
    });

    test('a single touch is a dot', () {
      final dot = PressureSpine.of(_pencil(BrushKind.marker, [60, 60, 0.0])).outline(1);
      expect(dot.contains(const Offset(60, 61)), isTrue);
      expect(dot.contains(const Offset(60, 66)), isFalse);
    });
  });

  group('drawing', () {
    test('a harder press paints a wider line, and the lightest touch still shows', () async {
      for (final kind in pressureBrushes) {
        final light = _painted(await _bake([_pencil(kind, _line(0.0))]));
        final normal = _painted(await _bake([_pencil(kind, _line(0.6))]));
        final hard = _painted(await _bake([_pencil(kind, _line(1.0))]));
        expect(light, greaterThan(100), reason: '$kind: a light touch leaves a mark');
        expect(normal, greaterThan(light), reason: '$kind');
        expect(hard, greaterThan(normal), reason: '$kind');
      }
    });

    test('the pencil at the finger pressure is as wide as a finger', () async {
      final finger = _painted(await _bake([_pencil(BrushKind.marker, _line(defaultPressure))]));
      // 0.5 everywhere is a finger stroke; 0.5 with one point at 0.6 takes
      // the pressure drawing.
      final pencil = _painted(await _bake([
        _pencil(BrushKind.marker, [..._line(defaultPressure), 112, 60, 0.6]),
      ]));
      expect(pencil, closeTo(finger, finger * 0.08));
    });

    test('other brushes ignore the pressure', () async {
      for (final kind in [BrushKind.rainbow, BrushKind.spray, BrushKind.glitter]) {
        final finger = await _bake([_pencil(kind, _line(defaultPressure))]);
        final pressed = await _bake([_pencil(kind, _line(1.0))]);
        expect(pressed, finger, reason: '$kind draws the same whatever the pressure');
      }
    });

    test('a pressure stroke bakes to the same pixels every time and after a reload', () async {
      for (final kind in pressureBrushes) {
        final stroke = _pencil(kind, _scribble());
        final first = await _bake([stroke]);
        expect(await _bake([stroke]), first, reason: '$kind is deterministic');
        expect(await _bake([Stroke.fromJson(stroke.toJson())!]), first, reason: '$kind after a reload');
      }
    });

    test('the mirror copy has the same widths', () async {
      final points = [
        for (var y = 20.0; y <= 100; y += 4) ...[30.0, y, (y - 20) / 80],
      ];
      final rgba = await _bake([_pencil(BrushKind.marker, points, symmetry: 2)]);
      var leftHalf = 0, rightHalf = 0;
      for (var y = 0; y < 120; y++) {
        for (var x = 0; x < 120; x++) {
          if (rgba[(y * 120 + x) * 4 + 3] == 0) continue;
          if (x < 60) {
            leftHalf++;
          } else {
            rightHalf++;
          }
        }
      }
      expect(leftHalf, greaterThan(500));
      expect(rightHalf, closeTo(leftHalf, leftHalf * 0.02));
    });

    test('the neon keeps its 14 draw calls, the marker and the pastel one outline each', () {
      final neon = _CountingCanvas();
      drawStroke(neon, _pencil(BrushKind.neon, _scribble()));
      expect(neon.paths, 14);
      final marker = _CountingCanvas();
      drawStroke(marker, _pencil(BrushKind.marker, _scribble()));
      expect(marker.paths, 1);
      final pastel = _CountingCanvas();
      drawStroke(pastel, _pencil(BrushKind.crayon, _scribble()));
      expect(pastel.paths, 1);
      expect(pastel.circles, greaterThan(0), reason: 'the grain is still there');
    });
  });
}
