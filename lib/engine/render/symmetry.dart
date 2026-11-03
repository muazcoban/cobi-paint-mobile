import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/rendering.dart' show Matrix4;

import '../document/stroke.dart';

/// The transforms that place the mirror copies of a stroke with symmetry
/// [ways] (see [symmetryWays]), the identity first, about the centre
/// ([cx], [cy]). The copies are the dihedral group of order [ways]:
/// `ways / 2` rotations about the centre, each with its left-right mirror.
List<Matrix4> symmetryTransforms(int ways, double cx, double cy) {
  final n = validSymmetry(ways);
  if (n == 1) return [Matrix4.identity()];
  final result = <Matrix4>[];
  final rotations = n ~/ 2;
  for (var k = 0; k < rotations; k++) {
    final angle = 2 * math.pi * k / rotations;
    for (final mirror in [false, true]) {
      result.add(
        Matrix4.identity()
          ..translateByDouble(cx, cy, 0, 1)
          ..rotateZ(angle)
          ..scaleByDouble(mirror ? -1 : 1, 1, 1, 1)
          ..translateByDouble(-cx, -cy, 0, 1),
      );
    }
  }
  return result;
}

/// Directions of the mirror lines, in radians from the x axis; empty for
/// [ways] 1. The first is always the vertical line down the middle.
List<double> symmetryAxes(int ways) {
  final n = validSymmetry(ways);
  if (n == 1) return const [];
  final rotations = n ~/ 2;
  // A mirror across the vertical line followed by a rotation of theta is a
  // mirror across the line at 90 degrees + theta / 2.
  return [for (var k = 0; k < rotations; k++) math.pi / 2 + math.pi * k / rotations];
}

/// Maps [point] through [transform] (2D).
Offset transformPoint(Matrix4 transform, Offset point) {
  final s = transform.storage;
  return Offset(s[0] * point.dx + s[4] * point.dy + s[12], s[1] * point.dx + s[5] * point.dy + s[13]);
}
