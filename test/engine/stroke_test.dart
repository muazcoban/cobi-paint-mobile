import 'dart:typed_data';

import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every brush kind survives the JSON round trip', () {
    for (final kind in BrushKind.values) {
      final stroke = Stroke(
        kind: kind,
        argb: 0xFF123456,
        size: 24.5,
        clipLabel: 3,
        symmetry: 4,
        points: Float32List.fromList([1.0, 2.0, 0.5, 10.25, 20.75, 0.5]),
      );
      final back = Stroke.fromJson(stroke.toJson())!;
      expect(back.kind, kind);
      expect(back.argb, 0xFF123456);
      expect(back.size, 24.5);
      expect(back.clipLabel, 3);
      expect(back.symmetry, 4);
      // Points keep one decimal (10.25 rounds half away from zero).
      final expected = [1.0, 2.0, 0.5, 10.3, 20.8, 0.5];
      for (var i = 0; i < expected.length; i++) {
        expect(back.points[i], closeTo(expected[i], 1e-5), reason: 'point value $i');
      }
    }
  });

  test('a plain stroke stores no symmetry, and a symmetry this version does not know draws once', () {
    final plain = Stroke(kind: BrushKind.marker, argb: 0, size: 10, points: Float32List.fromList([1, 1, 0.5]));
    expect(plain.toJson().containsKey('m'), isFalse);
    expect(Stroke.fromJson(plain.toJson())!.symmetry, 1);
    expect(Stroke.fromJson({'k': 'marker', 'c': 0, 's': 10, 'm': 3, 'p': [1, 1, 5]})!.symmetry, 1);
    expect(Stroke.fromJson({'k': 'eraser', 'c': 0, 's': 10, 'm': 6, 'p': [1, 1, 5]})!.symmetry, 6);
  });

  test('a stroke of a kind this version does not know is dropped, not crashed on', () {
    expect(Stroke.fromJson({'k': 'lava', 'c': 0, 's': 10, 'p': [1, 1, 5]}), isNull);
    expect(Stroke.fromJson('nonsense'), isNull);
  });
}
