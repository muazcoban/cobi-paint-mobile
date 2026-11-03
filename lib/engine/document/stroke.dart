import 'dart:typed_data';

/// Marker and eraser came first; rainbow cycles the hue along the stroke,
/// crayon has grainy edges. Names are stored in saved artworks.
enum BrushKind { marker, eraser, rainbow, crayon }

/// One finger-down-to-finger-up brush stroke, in page pixel coordinates.
class Stroke {
  Stroke({
    required this.kind,
    required this.argb,
    required this.size,
    required this.points,
    this.clipLabel = 0,
  }) : assert(points.length % 3 == 0);

  final BrushKind kind;
  final int argb;

  /// Brush diameter in page pixels.
  final double size;

  /// x, y, pressure triplets.
  final Float32List points;

  /// Region the stroke stays inside; 0 means it may cross lines.
  final int clipLabel;

  int get pointCount => points.length ~/ 3;

  Map<String, Object?> toJson() => {
        'k': kind.name,
        'c': argb,
        's': size,
        if (clipLabel != 0) 'l': clipLabel,
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
      points: Float32List.fromList([for (final v in raw) (v as num) / 10]),
    );
  }
}
