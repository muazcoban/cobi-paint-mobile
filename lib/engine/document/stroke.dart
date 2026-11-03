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

  /// x, y, pressure triplets.
  final Float32List points;

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
