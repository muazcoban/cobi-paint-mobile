import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../document/stroke.dart';

/// The centre line of a stroke whose width follows the Apple Pencil,
/// sampled along the same smooth curve as `strokePath` (quadratic curves
/// through the midpoints of the points), with the half width at every
/// sample.
///
/// [outline] turns it into one filled path: a band along every stretch
/// that turns gently and a disc at both ends and at every sharp turn. All
/// pieces are convex or fold-free and wound the same way, so the non-zero
/// fill covers places where a scribble crosses itself once, never leaves a
/// hole there, and a see-through brush does not get darker where pieces
/// overlap. One path per width, so the neon stays at its 14 draw calls.
class PressureSpine {
  PressureSpine._(this._xs, this._ys, this._half, this._len, this._base, this._step);

  factory PressureSpine.of(Stroke stroke) {
    final pts = stroke.points;
    final n = stroke.pointCount;
    final factors = pressureFactors(stroke);
    final base = stroke.size / 2;
    // Samples close enough that the straight edges between them follow the
    // curve, and few enough to stay cheap under the finger.
    final step = (base * 0.5).clamp(1.0, 6.0);
    final xs = <double>[];
    final ys = <double>[];
    final half = <double>[];

    void add(double x, double y, double h) {
      if (xs.isNotEmpty) {
        final dx = x - xs.last;
        final dy = y - ys.last;
        if (dx * dx + dy * dy < 0.0625) {
          // A quarter pixel from the last sample: keep the wider of the two.
          if (h > half.last) half[half.length - 1] = h;
          return;
        }
      }
      xs.add(x);
      ys.add(y);
      half.add(h);
    }

    double dist(double ax, double ay, double bx, double by) =>
        math.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay));

    if (n > 0) {
      var sx = pts[0].toDouble(), sy = pts[1].toDouble(), sf = factors[0];
      add(sx, sy, base * sf);
      for (var i = 1; i < n - 1; i++) {
        final cx = pts[i * 3].toDouble(), cy = pts[i * 3 + 1].toDouble(), cf = factors[i];
        final ex = (cx + pts[i * 3 + 3]) / 2, ey = (cy + pts[i * 3 + 4]) / 2, ef = (cf + factors[i + 1]) / 2;
        final k = math.max(1, ((dist(sx, sy, cx, cy) + dist(cx, cy, ex, ey)) / step).ceil());
        for (var j = 1; j <= k; j++) {
          final t = j / k, u = 1 - t;
          final a = u * u, b = 2 * t * u, c = t * t;
          add(a * sx + b * cx + c * ex, a * sy + b * cy + c * ey, base * (a * sf + b * cf + c * ef));
        }
        sx = ex;
        sy = ey;
        sf = ef;
      }
      if (n > 1) {
        final lx = pts[(n - 1) * 3].toDouble(), ly = pts[(n - 1) * 3 + 1].toDouble(), lf = factors[n - 1];
        final k = math.max(1, (dist(sx, sy, lx, ly) / step).ceil());
        for (var j = 1; j <= k; j++) {
          final t = j / k;
          add(sx + (lx - sx) * t, sy + (ly - sy) * t, base * (sf + (lf - sf) * t));
        }
      }
    }

    final m = xs.length;
    final len = Float64List(math.max(0, m - 1));
    for (var i = 0; i < m - 1; i++) {
      len[i] = dist(xs[i], ys[i], xs[i + 1], ys[i + 1]);
    }
    return PressureSpine._(
      Float64List.fromList(xs),
      Float64List.fromList(ys),
      Float64List.fromList(half),
      len,
      base,
      step,
    );
  }

  final Float64List _xs;
  final Float64List _ys;

  /// Half the line width at each sample, for a [outline] scale of 1.
  final Float64List _half;

  // Length of the segment after each sample.
  final Float64List _len;

  // Half the brush size, and the distance between samples.
  final double _base;
  final double _step;

  int get sampleCount => _xs.length;

  Offset sampleAt(int i) => Offset(_xs[i], _ys[i]);

  double halfWidthAt(int i) => _half[i];

  /// The filled shape of the line drawn at [scale] times its width.
  Path outline(double scale) {
    final path = Path();
    final m = _xs.length;
    if (m == 0) return path;
    _disc(path, _xs[0], _ys[0], _half[0] * scale);
    if (m == 1) return path;

    // A wide layer (the neon glow) takes every few samples: its edge is far
    // from the line and faint, and every sample on a tight curve costs it a
    // disc.
    final stride = math.max(1, (0.3 * _base * scale / _step).floor());
    final at = <int>[0];
    for (var i = stride; i < m - 1 + stride; i += stride) {
      final next = math.min(i, m - 1);
      // A line that comes back over itself can put two picked samples on
      // one spot; a zero-length segment has no direction, so skip it.
      final dx = _xs[next] - _xs[at.last], dy = _ys[next] - _ys[at.last];
      if (dx * dx + dy * dy >= 0.0625) at.add(next);
    }
    final k = at.length;
    if (k == 1) return path;
    final dx = Float64List(k - 1), dy = Float64List(k - 1), len = Float64List(k - 1);
    for (var j = 0; j < k - 1; j++) {
      final ax = _xs[at[j + 1]] - _xs[at[j]], ay = _ys[at[j + 1]] - _ys[at[j]];
      final l = math.sqrt(ax * ax + ay * ay);
      len[j] = l;
      dx[j] = ax / l;
      dy[j] = ay / l;
    }

    // A sample is a cut when the line turns there too sharply for one band:
    // more than about 20 degrees, or so tightly for its width that the inner
    // edge would fold back over itself. The chord between the two unit
    // directions stands in for the angle.
    bool cut(int j) {
      final cx = dx[j - 1] - dx[j], cy = dy[j - 1] - dy[j];
      final chord = math.sqrt(cx * cx + cy * cy);
      if (chord > 0.35) return true;
      return _half[at[j]] * scale * chord > 0.75 * math.min(len[j - 1], len[j]);
    }

    // One band from sample [from] to [to]: the right edge out and the left
    // edge back, wound like the discs. The two end samples take the normal
    // of their own segment, so a band ends square where a disc covers the
    // joint; the samples between take the mean of their two segments.
    void band(int from, int to) {
      final right = <Offset>[];
      final left = <Offset>[];
      for (var j = from; j <= to; j++) {
        double nx, ny;
        if (j == from) {
          nx = -dy[j];
          ny = dx[j];
        } else if (j == to) {
          nx = -dy[j - 1];
          ny = dx[j - 1];
        } else {
          nx = -(dy[j - 1] + dy[j]);
          ny = dx[j - 1] + dx[j];
          final l = math.sqrt(nx * nx + ny * ny);
          nx /= l;
          ny /= l;
        }
        final i = at[j];
        final r = _half[i] * scale;
        right.add(Offset(_xs[i] - nx * r, _ys[i] - ny * r));
        left.add(Offset(_xs[i] + nx * r, _ys[i] + ny * r));
      }
      path.addPolygon([...right, ...left.reversed], true);
    }

    var from = 0;
    for (var j = 1; j < k; j++) {
      if (j == k - 1 || cut(j)) {
        band(from, j);
        final i = at[j];
        _disc(path, _xs[i], _ys[i], _half[i] * scale);
        from = j;
      }
    }
    return path;
  }

  /// Positions every [step] page pixels along the spine, with the half
  /// width there; a single sample gives its one position.
  Iterable<(Offset, double)> every(double step) sync* {
    final m = _xs.length;
    if (m == 0) return;
    yield (Offset(_xs[0], _ys[0]), _half[0]);
    var next = step;
    var walked = 0.0;
    for (var i = 0; i < m - 1; i++) {
      final l = _len[i];
      while (next <= walked + l) {
        final t = (next - walked) / l;
        yield (
          Offset(_xs[i] + (_xs[i + 1] - _xs[i]) * t, _ys[i] + (_ys[i + 1] - _ys[i]) * t),
          _half[i] + (_half[i + 1] - _half[i]) * t,
        );
        next += step;
      }
      walked += l;
    }
  }
}

/// Unit circles by vertex count, built once.
final Map<int, Float64List> _circles = {};

/// A disc as a polygon wound like the bands (angles growing, which turns
/// clockwise on a page whose y axis points down), with sides of about three
/// pixels; a big disc's 48 sides still stay within a third of a pixel of
/// the circle.
void _disc(Path path, double x, double y, double r) {
  if (r <= 0) return;
  final count = (2 * math.pi * r / 3).ceil().clamp(12, 48);
  final unit = _circles.putIfAbsent(count, () {
    final xy = Float64List(count * 2);
    for (var i = 0; i < count; i++) {
      final a = 2 * math.pi * i / count;
      xy[i * 2] = math.cos(a);
      xy[i * 2 + 1] = math.sin(a);
    }
    return xy;
  });
  path.addPolygon([for (var i = 0; i < count; i++) Offset(x + unit[i * 2] * r, y + unit[i * 2 + 1] * r)], true);
}
