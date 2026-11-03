import 'dart:math' as math;
import 'dart:ui';

/// A sticker stuck on the page: which picture, where its centre is, how
/// wide it is and how much it is tilted. Stickers sit on top of the line
/// art, like real ones, and never count towards finishing a page.
class Sticker {
  const Sticker({required this.code, required this.x, required this.y, required this.size, this.angle = 0});

  /// Name of the picture under assets/stickers (see `stickers` in
  /// lib/data/stickers.dart).
  final String code;

  /// Centre, in page pixels.
  final double x;
  final double y;

  /// Width and height in page pixels.
  final double size;

  /// Tilt in radians.
  final double angle;

  Offset get center => Offset(x, y);

  /// The square the picture is drawn into, before the tilt.
  Rect get bounds => Rect.fromCenter(center: center, width: size, height: size);

  /// Whether [point] is on the sticker, with [slop] extra around it.
  bool contains(Offset point, {double slop = 0}) {
    // Undo the tilt, then test the square.
    final d = point - center;
    final c = math.cos(-angle), s = math.sin(-angle);
    final local = Offset(d.dx * c - d.dy * s, d.dx * s + d.dy * c);
    final half = size / 2 + slop;
    return local.dx.abs() <= half && local.dy.abs() <= half;
  }

  /// A small tilt for the [index]th stamp, so a trail of stickers looks
  /// placed by hand; the same index always tilts the same way.
  static double tiltFor(int index) => ((index * 37) % 21 - 10) * math.pi / 180;

  Map<String, Object?> toJson() => {
        'i': code,
        'x': (x * 10).round() / 10,
        'y': (y * 10).round() / 10,
        's': (size * 10).round() / 10,
        if (angle != 0) 'a': (angle * 1000).round() / 1000,
      };

  static Sticker? fromJson(Object? json) {
    if (json is! Map) return null;
    final code = json['i'];
    final x = json['x'], y = json['y'], size = json['s'];
    if (code is! String || code.isEmpty || x is! num || y is! num || size is! num || size <= 0) return null;
    return Sticker(
      code: code,
      x: x.toDouble(),
      y: y.toDouble(),
      size: size.toDouble(),
      angle: ((json['a'] as num?) ?? 0).toDouble(),
    );
  }
}
