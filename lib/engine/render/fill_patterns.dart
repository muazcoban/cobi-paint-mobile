// The arithmetic behind the bucket's patterns (council P9, 8 November
// 2026). Everything here is integer maths on page coordinates, so a
// patterned region looks the same on every device, in the saved picture,
// in the thumbnail and on paper.
//
// The ground of every pattern is the colour the child chose; the dots and
// the stripes are drawn in a second tone of that same colour (markTone),
// so a red region still reads as red. The rainbow ignores the colour.

import 'dart:math' as math;
import 'dart:typed_data';

import '../document/coloring_document.dart' show FillPattern;

/// Luminance of an ARGB colour on 0..255: (299 R + 587 G + 114 B) / 1000.
int luma(int argb) =>
    (299 * ((argb >> 16) & 0xFF) + 587 * ((argb >> 8) & 0xFF) + 114 * (argb & 0xFF)) ~/ 1000;

/// Colours darker than this get a light mark tone, lighter ones a dark one,
/// so the two tones always differ in brightness, not only in hue (every
/// palette colour differs by at least 50 on the luma scale, tested).
const int lightColourLuma = 160;

/// The tone the dots and stripes are drawn in on top of [argb]: light,
/// (2c + 765) / 5 per channel, for dark and middle colours; dark, 2c / 3,
/// for light ones. Never pure white, never black.
int markTone(int argb) {
  final light = luma(argb) < lightColourLuma;
  int tone(int c) => light ? (2 * c + 765) ~/ 5 : (2 * c) ~/ 3;
  return 0xFF000000 |
      (tone((argb >> 16) & 0xFF) << 16) |
      (tone((argb >> 8) & 0xFF) << 8) |
      tone(argb & 0xFF);
}

/// The 50/50 mix of two colours, per channel; the one-pixel ring around a
/// dot, so its edge is not a staircase.
int blendTone(int a, int b) =>
    0xFF000000 |
    (((((a >> 16) & 0xFF) + ((b >> 16) & 0xFF)) >> 1) << 16) |
    (((((a >> 8) & 0xFF) + ((b >> 8) & 0xFF)) >> 1) << 8) |
    (((a & 0xFF) + (b & 0xFF)) >> 1);

/// The dot spacing: the page's shorter side over 21 (48 px on a 1024 px
/// page), so a fingertip-sized region holds at least two dots.
int dotStep(int shortSide) => math.max(6, shortSide ~/ 21);

/// The dot radius: 28% of the step, which keeps the marks under a quarter
/// of the area and the child's colour dominant.
int dotRadius(int step) => (28 * step) ~/ 100;

/// The stripe period: the shorter side over 8 (128 px on a 1024 px page),
/// at most eight light-dark pairs across a page, never thinner than a dot
/// step.
int stripePeriod(int shortSide) => math.max(8, shortSide ~/ 8);

/// What a pattern paints at one pixel: the child's colour, the mark tone, or
/// the blend of the two on a dot's edge.
enum PatternCell { ground, mark, blend }

/// The dot pattern as a tile of [step] by 2 × [step] cells, anchored to the
/// page: rows of dots, every other row shifted by half a step. One lookup
/// per pixel: `tile[(y % (2 step)) * step + x % step]`.
Uint8List dotsTile(int step) {
  final tile = Uint8List(step * 2 * step);
  final r = dotRadius(step);
  final inner = r * r;
  final outer = (r + 1) * (r + 1);
  final half = step ~/ 2;
  for (var y = 0; y < 2 * step; y++) {
    final shift = (y ~/ step).isOdd ? half : 0;
    final ry = (y % step) - half;
    for (var x = 0; x < step; x++) {
      final rx = ((x + shift) % step) - half;
      final d2 = rx * rx + ry * ry;
      tile[y * step + x] = d2 <= inner
          ? PatternCell.mark.index
          : (d2 <= outer ? PatternCell.blend.index : PatternCell.ground.index);
    }
  }
  return tile;
}

/// Whether the diagonal stripes paint the mark tone at page pixel (x, y):
/// 45° stripes running up to the right, the mark two fifths of the period.
bool stripeMarkAt(int x, int y, int period) => ((x + y) % period) * 5 < period * 2;

/// The six colours of the rainbow fill, top to bottom: the first six Minik
/// colours, the same ones as the brush button's rainbow badge.
const List<int> rainbowStops = [0xFFE53935, 0xFFFB8C00, 0xFFFDD835, 0xFF43A047, 0xFF1E88E5, 0xFF8E24AA];

/// One colour per row of a region [height] rows tall: a smooth run through
/// [rainbowStops] from the top row to the bottom one, interpolated per
/// channel with integers only. No hard edges, one full rainbow per region.
Uint32List rainbowRows(int height) {
  final rows = Uint32List(math.max(1, height));
  final span = math.max(1, rows.length - 1);
  for (var k = 0; k < rows.length; k++) {
    final q = k * 1275 ~/ span;
    final s = math.min(q ~/ 255, 4);
    final f = q - 255 * s;
    final a = rainbowStops[s];
    final b = rainbowStops[s + 1];
    int ch(int shift) => ((((a >> shift) & 0xFF) * (255 - f)) + (((b >> shift) & 0xFF) * f)) ~/ 255;
    rows[k] = 0xFF000000 | (ch(16) << 16) | (ch(8) << 8) | ch(0);
  }
  return rows;
}

/// Whether [pattern] paints anything but the flat colour.
bool isPatterned(FillPattern pattern) => pattern != FillPattern.solid;
