import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/engine/render/page_layers.dart';
import 'package:cobi_paint_mobile/engine/render/symmetry.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher near(Offset expected) => predicate<Offset>((o) => (o - expected).distance < 1e-6, 'near $expected');

List<Offset> imagesOf(int ways, Offset centre, Offset point) =>
    symmetryTransforms(ways, centre.dx, centre.dy).map((m) => transformPoint(m, point)).toList();

/// A 40 x 40 page that is one region.
LabelMap _map() => LabelMap(
      width: 40,
      height: 40,
      labels: Uint16List(1600)..fillRange(0, 1600, 1),
      regions: const [RegionInfo(left: 0, top: 0, right: 39, bottom: 39, area: 1600)],
    );

/// A short vertical stroke near the top-left corner.
Stroke _stroke(BrushKind kind, {required int symmetry, double size = 4}) => Stroke(
      kind: kind,
      argb: 0xFFE53935,
      size: size,
      symmetry: symmetry,
      points: Float32List.fromList([8, 6, 0.5, 9, 14, 0.5]),
    );

/// Painted pixels per quadrant: top-left, top-right, bottom-left, bottom-right.
Future<List<int>> _quadrants(PageLayers layers) async {
  await layers.syncBrush();
  final image = layers.brushImage;
  if (image == null) return const [0, 0, 0, 0];
  final bytes = (await image.toByteData())!.buffer.asUint8List();
  final counts = [0, 0, 0, 0];
  for (var y = 0; y < 40; y++) {
    for (var x = 0; x < 40; x++) {
      if (bytes[(y * 40 + x) * 4 + 3] > 0) counts[(y >= 20 ? 2 : 0) + (x >= 20 ? 1 : 0)]++;
    }
  }
  return counts;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('symmetry transforms', () {
    test('make as many copies as the symmetry says, the original first', () {
      for (final ways in symmetryWays) {
        final transforms = symmetryTransforms(ways, 50, 50);
        expect(transforms, hasLength(ways), reason: '$ways ways');
        expect(transformPoint(transforms.first, const Offset(10, 20)), near(const Offset(10, 20)));
      }
    });

    test('two-way mirrors left to right about the centre', () {
      expect(imagesOf(2, const Offset(50, 40), const Offset(10, 20))[1], near(const Offset(90, 20)));
    });

    test('four-way mirrors across both middle lines', () {
      expect(
        imagesOf(4, const Offset(50, 40), const Offset(10, 20)),
        unorderedMatches([
          near(const Offset(10, 20)),
          near(const Offset(90, 20)),
          near(const Offset(10, 60)),
          near(const Offset(90, 60)),
        ]),
      );
    });

    test('six-way turns a point on the vertical line by 120 degrees, each copy with its mirror', () {
      final images = imagesOf(6, Offset.zero, const Offset(0, -10));
      final third = 2 * math.pi / 3;
      for (final expected in [
        const Offset(0, -10),
        Offset(10 * math.sin(third), -10 * math.cos(third)),
        Offset(-10 * math.sin(third), -10 * math.cos(third)),
      ]) {
        expect(images.where((p) => (p - expected).distance < 1e-6), hasLength(2), reason: 'two copies at $expected');
      }
    });

    test('the mirror lines start with the vertical one and are spread evenly', () {
      expect(symmetryAxes(1), isEmpty);
      expect(symmetryAxes(2), [closeTo(math.pi / 2, 1e-9)]);
      expect(symmetryAxes(4), [closeTo(math.pi / 2, 1e-9), closeTo(math.pi, 1e-9)]);
      expect(symmetryAxes(6), [closeTo(math.pi / 2, 1e-9), closeTo(math.pi / 2 + math.pi / 3, 1e-9), closeTo(math.pi / 2 + 2 * math.pi / 3, 1e-9)]);
    });

    test('a symmetry this version does not know draws the stroke once', () {
      expect(validSymmetry(3), 1);
      expect(validSymmetry(8), 1);
      expect(validSymmetry(0), 1);
      expect(symmetryTransforms(5, 1, 1), hasLength(1));
    });
  });

  group('mirrored strokes on the page', () {
    test('without a mirror the paint stays where the finger was', () async {
      final document = ColoringDocument(_map());
      final layers = PageLayers(document: document);
      addTearDown(layers.dispose);
      document.addStroke(_stroke(BrushKind.marker, symmetry: 1));
      final q = await _quadrants(layers);
      expect(q[0], greaterThan(20));
      expect(q.sublist(1), [0, 0, 0]);
    });

    test('a two-way stroke on the left paints the right as well', () async {
      final document = ColoringDocument(_map());
      final layers = PageLayers(document: document);
      addTearDown(layers.dispose);
      document.addStroke(_stroke(BrushKind.marker, symmetry: 2));
      final q = await _quadrants(layers);
      expect(q[0], greaterThan(20));
      expect(q[1], q[0], reason: 'the mirror copy is the same size');
      expect(q[2] + q[3], 0, reason: 'nothing below the middle');
    });

    test('every brush kind lands in all four quadrants with a four-way mirror', () async {
      for (final kind in BrushKind.values.where((k) => k != BrushKind.eraser)) {
        final document = ColoringDocument(_map());
        final layers = PageLayers(document: document);
        document.addStroke(_stroke(kind, symmetry: 4));
        final q = await _quadrants(layers);
        expect(q, everyElement(greaterThan(10)), reason: '$kind in every quadrant: $q');
        layers.dispose();
      }
    });

    test('the eraser takes the mirror copies away too, in one undo step', () async {
      final document = ColoringDocument(_map());
      final layers = PageLayers(document: document);
      addTearDown(layers.dispose);
      document.addStroke(_stroke(BrushKind.marker, symmetry: 6));
      expect((await _quadrants(layers)).reduce((a, b) => a + b), greaterThan(60));

      document.erase(_stroke(BrushKind.eraser, symmetry: 6, size: 10), const {});
      expect(document.strokes, hasLength(2), reason: 'copies are drawn, never stored');
      expect((await _quadrants(layers)).reduce((a, b) => a + b), 0, reason: 'every copy is gone');

      document.undo();
      expect((await _quadrants(layers)).reduce((a, b) => a + b), greaterThan(60), reason: 'one undo brings all six back');
    });
  });
}
