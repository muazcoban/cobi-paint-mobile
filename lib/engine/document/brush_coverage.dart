import 'dart:math' as math;
import 'dart:typed_data';

import '../region/label_map.dart';
import 'stroke.dart';

/// How much of one region the brush has painted: the share of the region's
/// pixels within reach of a stroke that stays inside it, and the colour that
/// covers most of them.
///
/// Used to finish a region a child has almost coloured with the brush (the
/// last corners are hard for a small hand). Measured on a grid of [step]
/// page pixels, which is exact enough for a share and cheap enough to run
/// when a stroke ends.
class BrushCoverage {
  const BrushCoverage(this.ratio, this.argb);

  /// Covered share of the region, 0..1.
  final double ratio;

  /// The colour covering the most of the region; 0 when nothing does.
  final int argb;

  static const BrushCoverage none = BrushCoverage(0, 0);

  /// Measures [label] for [strokes] in page order. Only strokes that stay
  /// inside [label] add paint; eraser strokes take it away wherever they run.
  /// Mirrored strokes are skipped: coloring pages have no mirror.
  static BrushCoverage measure(LabelMap map, Iterable<Stroke> strokes, int label, {int step = 2}) {
    if (label <= 0 || label > map.regionCount) return none;
    final region = map.region(label);
    final gw = (region.right - region.left) ~/ step + 1;
    final gh = (region.bottom - region.top) ~/ step + 1;
    // Colour index per grid cell, -1 for unpainted.
    final owner = Int32List(gw * gh)..fillRange(0, gw * gh, -1);
    final colours = <int>[];

    for (final stroke in strokes) {
      if (stroke.symmetry > 1 || stroke.pointCount == 0) continue;
      final eraser = stroke.kind == BrushKind.eraser;
      if (!eraser && stroke.clipLabel != label) continue;
      var colour = -1;
      if (!eraser) {
        colour = colours.indexOf(stroke.argb);
        if (colour < 0) {
          colours.add(stroke.argb);
          colour = colours.length - 1;
        }
      }
      _paint(stroke, region, step, gw, gh, owner, colour);
    }

    var total = 0;
    final counts = List<int>.filled(colours.length, 0);
    for (var gy = 0; gy < gh; gy++) {
      final y = region.top + gy * step;
      for (var gx = 0; gx < gw; gx++) {
        if (map.labelAt(region.left + gx * step, y) != label) continue;
        total++;
        final o = owner[gy * gw + gx];
        if (o >= 0) counts[o]++;
      }
    }
    if (total == 0) return none;
    var best = -1;
    var covered = 0;
    for (var i = 0; i < counts.length; i++) {
      covered += counts[i];
      if (best < 0 || counts[i] > counts[best]) best = i;
    }
    return BrushCoverage(covered / total, best < 0 || counts[best] == 0 ? 0 : colours[best]);
  }

  /// Marks every grid cell within the brush radius of the stroke's path.
  static void _paint(Stroke stroke, RegionInfo region, int step, int gw, int gh, Int32List owner, int colour) {
    final radius = stroke.size / 2;
    final r2 = radius * radius;
    final spacing = math.max(1.0, radius / 2);
    final pts = stroke.points;

    void disc(double cx, double cy) {
      final minX = math.max(0, ((cx - radius - region.left) / step).floor());
      final maxX = math.min(gw - 1, ((cx + radius - region.left) / step).ceil());
      final minY = math.max(0, ((cy - radius - region.top) / step).floor());
      final maxY = math.min(gh - 1, ((cy + radius - region.top) / step).ceil());
      for (var gy = minY; gy <= maxY; gy++) {
        final dy = region.top + gy * step - cy;
        for (var gx = minX; gx <= maxX; gx++) {
          final dx = region.left + gx * step - cx;
          if (dx * dx + dy * dy <= r2) owner[gy * gw + gx] = colour;
        }
      }
    }

    disc(pts[0], pts[1]);
    for (var i = 3; i < pts.length; i += 3) {
      final ax = pts[i - 3], ay = pts[i - 2], bx = pts[i], by = pts[i + 1];
      final length = math.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay));
      final n = math.max(1, (length / spacing).ceil());
      for (var k = 1; k <= n; k++) {
        final t = k / n;
        disc(ax + (bx - ax) * t, ay + (by - ay) * t);
      }
    }
  }
}
