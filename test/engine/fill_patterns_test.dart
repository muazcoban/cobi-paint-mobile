import 'dart:math' as math;

import 'package:cobi_paint_mobile/engine/render/fill_patterns.dart';
import 'package:cobi_paint_mobile/screens/coloring_screen.dart' show bigPalette, littlePalette;
import 'package:flutter_test/flutter_test.dart';

/// WCAG relative luminance of an ARGB colour.
double _relativeLuminance(int argb) {
  double channel(int c) {
    final v = c / 255;
    return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel((argb >> 16) & 0xFF) + 0.7152 * channel((argb >> 8) & 0xFF) + 0.0722 * channel(argb & 0xFF);
}

double _contrast(int a, int b) {
  final la = _relativeLuminance(a), lb = _relativeLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('tones (council P9, 8 Nov 2026)', () {
    test('every palette colour and its mark tone differ by 50 in luma and 1.5:1 in contrast', () {
      // The rule is the luma difference; the contrast ratio is the floor the
      // App Review member asked for. 3:1 is not required: a tone derived from
      // the colour itself cannot reach it for red (2.3:1) and most others.
      for (final colour in bigPalette) {
        final argb = colour.toARGB32();
        final mark = markTone(argb);
        expect((luma(mark) - luma(argb)).abs(), greaterThanOrEqualTo(50), reason: colour.toString());
        expect(_contrast(argb, mark), greaterThanOrEqualTo(1.5), reason: colour.toString());
      }
    });

    test('light colours get a dark tone, the others a light one, never white or black', () {
      for (final colour in bigPalette) {
        final argb = colour.toARGB32();
        final mark = markTone(argb);
        if (luma(argb) >= lightColourLuma) {
          expect(luma(mark), lessThan(luma(argb)), reason: '$colour is light');
        } else {
          expect(luma(mark), greaterThan(luma(argb)), reason: '$colour is dark or middle');
        }
        expect(mark & 0xFFFFFF, isNot(0xFFFFFF));
        expect(mark & 0xFFFFFF, isNot(0));
        expect(mark >> 24, 0xFF, reason: 'opaque');
      }
    });

    test('the Minik colours with a dark tone are the light ones: yellow, light blue, light green, peach, light yellow, caramel', () {
      final dark = [for (final c in bigPalette) if (luma(c.toARGB32()) >= lightColourLuma) c.toARGB32()];
      expect(dark, [0xFFFDD835, 0xFF4FC3F7, 0xFFAED581, 0xFFFFAB91, 0xFFFFF59D, 0xFFD9A066]);
    });

    test('the blend is the middle of the two tones', () {
      expect(blendTone(0xFF000000, 0xFFFFFFFF), 0xFF7F7F7F);
      expect(blendTone(0xFFE53935, 0xFFE53935), 0xFFE53935);
    });
  });

  group('geometry', () {
    test('dot step and stripe period follow the page: 48 and 128 px on a 1024 px page', () {
      expect(dotStep(1024), 48);
      expect(dotRadius(48), 13);
      expect(stripePeriod(1024), 128);
      expect(dotStep(768), 36);
      expect(stripePeriod(768), 96);
    });

    test('the dot tile keeps the marks under a quarter of the area, in two staggered rows', () {
      for (final step in [36, 48, 60]) {
        final tile = dotsTile(step);
        expect(tile.length, step * 2 * step);
        // The dots themselves stay under a quarter; the one-pixel blend ring
        // around them is an edge, not a mark, and adds a few percent.
        final mark = tile.where((c) => c == PatternCell.mark.index).length / tile.length;
        final blend = tile.where((c) => c == PatternCell.blend.index).length / tile.length;
        expect(mark, lessThanOrEqualTo(0.25), reason: 'step $step');
        expect(mark, greaterThan(0.15), reason: 'step $step: the dots are visible');
        expect(blend, lessThan(0.08), reason: 'step $step: a thin ring');
        // The second row of dots sits between the first row's dots.
        final half = step ~/ 2;
        expect(tile[half * step + half], PatternCell.mark.index, reason: 'a dot centre in the first row');
        expect(tile[(step + half) * step + 0], PatternCell.mark.index, reason: 'the shifted row has a dot at the tile edge');
        expect(tile[(step + half) * step + half], PatternCell.ground.index, reason: 'ground between the shifted dots');
      }
    });

    test('stripes paint two fifths of the pixels and run diagonally', () {
      const period = 128;
      var mark = 0;
      for (var y = 0; y < period; y++) {
        for (var x = 0; x < period; x++) {
          if (stripeMarkAt(x, y, period)) mark++;
        }
      }
      expect(mark / (period * period), closeTo(0.4, 0.01));
      expect(stripeMarkAt(0, 0, period), isTrue);
      expect(stripeMarkAt(10, 20, period), stripeMarkAt(20, 10, period), reason: 'x + y decides');
      expect(stripeMarkAt(60, 0, period), isFalse, reason: 'past two fifths of the period');
    });

    test('the rainbow stops are the first six Minik colours, red to purple', () {
      expect(rainbowStops, [for (final c in littlePalette.take(6)) c.toARGB32()]);
    });

    test('rainbow rows start red, end purple and change gently', () {
      final rows = rainbowRows(200);
      expect(rows.first, 0xFFE53935);
      expect(rows.last, 0xFF8E24AA);
      for (var i = 1; i < rows.length; i++) {
        for (final shift in [16, 8, 0]) {
          final d = (((rows[i] >> shift) & 0xFF) - ((rows[i - 1] >> shift) & 0xFF)).abs();
          expect(d, lessThanOrEqualTo(8), reason: 'row $i');
        }
      }
      expect(rainbowRows(1), [0xFFE53935], reason: 'a one-row region is red, not a crash');
    });
  });
}
