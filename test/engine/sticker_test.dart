import 'dart:math' as math;

import 'package:cobi_paint_mobile/engine/document/sticker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a tilted sticker is hit where it really is', () {
    const flat = Sticker(code: 'star', x: 10, y: 10, size: 4);
    const tilted = Sticker(code: 'star', x: 10, y: 10, size: 4, angle: math.pi / 4);
    expect(flat.contains(const Offset(12.6, 10)), isFalse, reason: 'past the flat edge');
    expect(tilted.contains(const Offset(12.6, 10)), isTrue, reason: 'inside the turned corner');
    expect(flat.contains(const Offset(11.9, 11.9)), isTrue, reason: 'the flat corner');
    expect(tilted.contains(const Offset(11.9, 11.9)), isFalse, reason: 'the corner turned away');
    expect(flat.contains(const Offset(13, 10), slop: 1), isTrue, reason: 'slop widens the hit');
  });

  test('tilts stay within ten degrees and repeat for the same stamp', () {
    final seen = <double>{};
    for (var i = 0; i < 200; i++) {
      final tilt = Sticker.tiltFor(i);
      expect(tilt.abs(), lessThanOrEqualTo(10 * math.pi / 180 + 1e-9));
      expect(Sticker.tiltFor(i), tilt);
      seen.add(tilt);
    }
    expect(seen.length, greaterThan(5), reason: 'a trail does not lean all one way');
  });

  test('JSON keeps one decimal, drops a zero tilt and rejects a broken sticker', () {
    const s = Sticker(code: 'red_heart', x: 3.26, y: 4, size: 5.04, angle: 0.12345);
    final back = Sticker.fromJson(s.toJson())!;
    expect(back.code, 'red_heart');
    expect(back.x, closeTo(3.3, 1e-9));
    expect(back.size, closeTo(5.0, 1e-9));
    expect(back.angle, closeTo(0.123, 1e-9));
    expect(const Sticker(code: 'star', x: 1, y: 1, size: 2).toJson().containsKey('a'), isFalse);
    expect(Sticker.fromJson({'x': 1, 'y': 1, 's': 2}), isNull, reason: 'no picture');
    expect(Sticker.fromJson({'i': 'star', 'x': 1, 'y': 1, 's': 0}), isNull, reason: 'no size');
    expect(Sticker.fromJson('nonsense'), isNull);
  });
}
