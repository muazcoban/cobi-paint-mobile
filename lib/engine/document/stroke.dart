import 'dart:math' as math;
import 'dart:typed_data';

/// Marker and eraser came first; rainbow cycles the hue along the stroke,
/// crayon has grainy edges, spray is a cloud of dots, glitter a pale band
/// with sparkles, neon a bright core in a halo. Names are stored in saved
/// artworks, so they never change.
enum BrushKind { marker, eraser, rainbow, crayon, spray, glitter, neon }

/// Mirror symmetries a stroke can carry: the number of copies the page shows
/// for one finger stroke. 1 none, 2 a left-right mirror, 4 mirrors down and
/// across the middle, 6 three mirror lines like a snowflake. Every value
/// keeps the left-right mirror, so the butterfly a child learnt stays.
const symmetryWays = [1, 2, 4, 6];

/// [ways] when it is a value this version knows, 1 otherwise.
int validSymmetry(int ways) => symmetryWays.contains(ways) ? ways : 1;

/// The pressure every point gets from a finger, a mouse, Minik mode and
/// the brushes without pressure: the brush's own width.
const double defaultPressure = 0.5;

/// Brushes whose width follows the Apple Pencil in Büyük mode (council,
/// 5 November 2026): the marker, the pastel and the neon tube.
const pressureBrushes = {BrushKind.marker, BrushKind.crayon, BrushKind.neon};

/// The stored pressure for an Apple Pencil force. iOS reports 1.0 for an
/// average touch, which lands on [defaultPressure], so a pencil held
/// normally draws as wide as a finger. Rounded to the tenth the saved file
/// keeps, so a reopened picture looks exactly like the one drawn.
double storedPressure(double force) => ((force / 2).clamp(0.0, 1.0) * 10).round() / 10;

/// Width factor of every point of [stroke]: 0.35 for the lightest touch
/// (still a visible line), 1 at [defaultPressure], 1.65 for the hardest
/// press. Smoothed along the stroke over about one brush width, so the
/// tenth steps of the stored pressure become gentle ramps. Only + and /,
/// so the same points give the same widths on every device.
Float64List pressureFactors(Stroke stroke) {
  final pts = stroke.points;
  final n = stroke.pointCount;
  final factors = Float64List(n);
  if (n == 0) return factors;
  for (var i = 0; i < n; i++) {
    factors[i] = 0.35 + 1.3 * pts[i * 3 + 2];
  }
  if (n == 1) return factors;
  final reach = stroke.size < 4 ? 4.0 : stroke.size;
  final weights = Float64List(n);
  for (var i = 1; i < n; i++) {
    final dx = pts[i * 3] - pts[i * 3 - 3];
    final dy = pts[i * 3 + 1] - pts[i * 3 - 2];
    final d = math.sqrt(dx * dx + dy * dy);
    weights[i] = d / (d + reach);
  }
  // Forwards and back again, so the ramp is centred on the change.
  for (var i = 1; i < n; i++) {
    factors[i] = factors[i - 1] + weights[i] * (factors[i] - factors[i - 1]);
  }
  for (var i = n - 2; i >= 0; i--) {
    factors[i] = factors[i + 1] + weights[i + 1] * (factors[i] - factors[i + 1]);
  }
  return factors;
}

/// One finger-down-to-finger-up brush stroke, in page pixel coordinates.
class Stroke {
  Stroke({
    required this.kind,
    required this.argb,
    required this.size,
    required this.points,
    this.clipLabel = 0,
    this.symmetry = 1,
  })  : assert(points.length % 3 == 0),
        assert(symmetryWays.contains(symmetry));

  final BrushKind kind;
  final int argb;

  /// Brush diameter in page pixels.
  final double size;

  /// x, y, pressure triplets. The pressure is [defaultPressure] except for
  /// Apple Pencil strokes of the [pressureBrushes] in Büyük mode.
  final Float32List points;

  /// Whether any point carries a pen pressure other than [defaultPressure];
  /// only then does the width follow it ([pressureFactors]).
  late final bool hasPressure = () {
    for (var i = 2; i < points.length; i += 3) {
      if (points[i] != defaultPressure) return true;
    }
    return false;
  }();

  /// Region the stroke stays inside; 0 means it may cross lines.
  final int clipLabel;

  /// Mirror copies drawn for this stroke (see [symmetryWays]). The copies
  /// are not stored: one stroke, one undo step.
  final int symmetry;

  int get pointCount => points.length ~/ 3;

  Map<String, Object?> toJson() => {
        'k': kind.name,
        'c': argb,
        's': size,
        if (clipLabel != 0) 'l': clipLabel,
        if (symmetry != 1) 'm': symmetry,
        // One decimal is plenty for page pixels and keeps the file small.
        'p': [for (final v in points) (v * 10).round()],
      };

  static Stroke? fromJson(Object? json) {
    if (json is! Map) return null;
    final kind = BrushKind.values.where((k) => k.name == json['k']).firstOrNull;
    final raw = json['p'];
    if (kind == null || raw is! List || raw.length % 3 != 0) return null;
    return Stroke(
      kind: kind,
      argb: (json['c'] as num?)?.toInt() ?? 0xFF000000,
      size: (json['s'] as num?)?.toDouble() ?? 12,
      clipLabel: (json['l'] as num?)?.toInt() ?? 0,
      symmetry: validSymmetry((json['m'] as num?)?.toInt() ?? 1),
      points: Float32List.fromList([for (final v in raw) (v as num) / 10]),
    );
  }
}
