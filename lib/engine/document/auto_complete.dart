import 'dart:math' as math;
import 'dart:typed_data';

import '../region/label_map.dart';
import 'stroke.dart';

/// Finishing a region a child has almost coloured with the marker (council,
/// 5 November 2026): the last corners near the lines are hard for a small
/// hand, so once one marker colour covers nearly all of a region, the rest
/// of it fills with that colour.
///
/// The rules, in the council's words:
/// - only the marker counts and triggers; any other brush paint still
///   visible in the region means no completion (a flat fill under a
///   see-through or many-coloured texture would change how it looks);
/// - one colour must cover at least [threshold] of the measurable area, the
///   part of the region further than [lineMargin] page pixels from any other
///   region (a region's area includes the line pixels it grew under);
/// - a region painted in more than one colour is left alone;
/// - every white gap that is left must be smaller than a fingertip (1% of
///   the page, the size PageProgress uses), so a big white area a child left
///   on purpose stays white.
///
/// Pure Dart on a [step] pixel grid: the same strokes give the same answer
/// on every device.
class AutoComplete {
  AutoComplete._();

  static const double threshold = 0.85;
  static const int step = 4;
  static const int lineMargin = 8;

  /// The fill that completes [label] after [strokes] (in page order, the
  /// newest last), or null when the region should stay as it is. The
  /// returned point lies inside the region, for the saved fill.
  static ({int argb, int x, int y})? evaluate(LabelMap map, List<Stroke> strokes, int label) {
    if (label <= 0 || label > map.regionCount) return null;
    final region = map.region(label);
    final gw = (region.right - region.left) ~/ step + 1;
    final gh = (region.bottom - region.top) ~/ step + 1;
    final cells = gw * gh;

    // Measurable cells: inside the region and clear of every line by the
    // margin, sampled at eight points around the cell.
    final measurable = Uint8List(cells);
    const d = lineMargin;
    const e = lineMargin * 3 ~/ 4;
    var total = 0;
    var seedX = -1, seedY = -1;
    for (var gy = 0; gy < gh; gy++) {
      final y = region.top + gy * step;
      for (var gx = 0; gx < gw; gx++) {
        final x = region.left + gx * step;
        if (map.labelAt(x, y) != label) continue;
        if (map.labelAt(x + d, y) != label ||
            map.labelAt(x - d, y) != label ||
            map.labelAt(x, y + d) != label ||
            map.labelAt(x, y - d) != label ||
            map.labelAt(x + e, y + e) != label ||
            map.labelAt(x + e, y - e) != label ||
            map.labelAt(x - e, y + e) != label ||
            map.labelAt(x - e, y - e) != label) {
          continue;
        }
        measurable[gy * gw + gx] = 1;
        total++;
        if (seedX < 0) {
          seedX = x;
          seedY = y;
        }
      }
    }
    if (total == 0) return null;

    // Who painted each cell last: -1 nobody (or erased), -2 a brush other
    // than the marker, 0.. a marker colour.
    const nobody = -1, foreign = -2;
    final owner = Int32List(cells)..fillRange(0, cells, nobody);
    final colours = <int>[];
    for (final stroke in strokes) {
      if (stroke.symmetry > 1 || stroke.pointCount == 0) continue;
      final int value;
      if (stroke.kind == BrushKind.eraser) {
        value = nobody;
      } else if (stroke.clipLabel != label) {
        continue;
      } else if (stroke.kind == BrushKind.marker) {
        var index = colours.indexOf(stroke.argb);
        if (index < 0) {
          colours.add(stroke.argb);
          index = colours.length - 1;
        }
        value = index;
      } else {
        value = foreign;
      }
      _stamp(stroke, region, gw, gh, owner, value);
    }

    var winner = -1;
    var winnerCount = 0;
    final counts = List<int>.filled(colours.length, 0);
    for (var i = 0; i < cells; i++) {
      if (measurable[i] == 0) continue;
      final o = owner[i];
      if (o == foreign) return null;
      if (o >= 0) counts[o]++;
    }
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] == 0) continue;
      if (winner >= 0) return null; // more than one colour
      winner = i;
      winnerCount = counts[i];
    }
    if (winner < 0 || winnerCount < threshold * total) return null;

    // No white gap the size of a fingertip or more.
    final finger = (map.width * 0.1) * (map.height * 0.1);
    final maxGapCells = finger / (step * step);
    final seen = Uint8List(cells);
    final stack = <int>[];
    for (var start = 0; start < cells; start++) {
      if (measurable[start] == 0 || owner[start] != nobody || seen[start] == 1) continue;
      var size = 0;
      seen[start] = 1;
      stack.add(start);
      while (stack.isNotEmpty) {
        final c = stack.removeLast();
        size++;
        if (size >= maxGapCells) return null;
        final cx = c % gw, cy = c ~/ gw;
        void visit(int nx, int ny) {
          if (nx < 0 || ny < 0 || nx >= gw || ny >= gh) return;
          final n = ny * gw + nx;
          if (measurable[n] == 0 || owner[n] != nobody || seen[n] == 1) return;
          seen[n] = 1;
          stack.add(n);
        }

        visit(cx + 1, cy);
        visit(cx - 1, cy);
        visit(cx, cy + 1);
        visit(cx, cy - 1);
      }
    }
    return (argb: colours[winner], x: seedX, y: seedY);
  }

  /// Sets every grid cell within the brush radius of the stroke's path.
  static void _stamp(Stroke stroke, RegionInfo region, int gw, int gh, Int32List owner, int value) {
    final radius = stroke.size / 2;
    final r2 = radius * radius;
    final spacing = math.max(step.toDouble(), radius / 2);
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
          if (dx * dx + dy * dy <= r2) owner[gy * gw + gx] = value;
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
