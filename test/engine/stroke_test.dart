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
        points: Float32List.fromList([1.0, 2.0, 0.5, 10.25, 20.75, 0.5]),
      );
      final back = Stroke.fromJson(stroke.toJson())!;
      expect(back.kind, kind);
      expect(back.argb, 0xFF123456);
      expect(back.size, 24.5);
      expect(back.clipLabel, 3);
      // Points keep one decimal (10.25 rounds half away from zero).
      final expected = [1.0, 2.0, 0.5, 10.3, 20.8, 0.5];
      for (var i = 0; i < expected.length; i++) {
        expect(back.points[i], closeTo(expected[i], 1e-5), reason: 'point value $i');
      }
    }
  });

  test('a stroke of a kind this version does not know is dropped, not crashed on', () {
    expect(Stroke.fromJson({'k': 'glitter', 'c': 0, 's': 10, 'p': [1, 1, 5]}), isNull);
    expect(Stroke.fromJson('nonsense'), isNull);
  });
}
