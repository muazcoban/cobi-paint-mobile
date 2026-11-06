import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Control sizes from the toddler research: about 2 cm on a phone where it
/// fits, larger on tablets; Büyük mode trades size for more controls. The
/// coloring screen and the scene screen share them, so a button never
/// changes size between the two.
class KidMetrics {
  KidMetrics(Size size, bool big) {
    final tablet = size.shortestSide >= 600;
    gap = tablet ? 16 : 12;
    cell = big ? (tablet ? 88 : 52) : (tablet ? 112 : 70);
    final double wanted = big ? (tablet ? 96 : 64) : (tablet ? 116 : 82);
    // The controls share one row (tall layout) or one column (wide layout)
    // between 12 pt paddings. In a narrow Split View pane they shrink
    // together instead of overflowing, never below the 44 pt minimum.
    final wide = size.width > size.height * 1.1;
    final along = (wide ? size.height : size.width) - 24;
    final count = big ? 5 : 4;
    final fit = (along - (count - 1) * gap) / count;
    primary = math.max(44.0, math.min(wanted, fit));
  }

  late final double primary;
  late final double cell;
  late final double gap;
}
