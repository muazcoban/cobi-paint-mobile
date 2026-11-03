import 'dart:typed_data';

import 'label_map.dart';

/// How well a colouring page suits a small child, measured on its label map.
///
/// Used by `tool/page_report.dart` and the built-in page tests, so a new page
/// that leaks, has nothing to fill or is all tiny areas is caught before it
/// ships.
class PageCheck {
  PageCheck._({
    required this.regions,
    required this.backgroundShare,
    required this.fingerRegions,
    required this.lineShare,
  });

  /// [lineMask] is [RegionBuilder.lineMask] for the same page.
  factory PageCheck.of(LabelMap map, Uint8List lineMask) {
    final total = map.width * map.height;
    var lines = 0;
    for (final v in lineMask) {
      lines += v;
    }
    if (map.regionCount == 0) {
      return PageCheck._(regions: 0, backgroundShare: 1, fingerRegions: 0, lineShare: lines / total);
    }
    final background = _backgroundLabel(map);
    // A toddler's fingertip covers about a tenth of the page width on a phone.
    final finger = (map.width * 0.1) * (map.height * 0.1);
    var fingerRegions = 0;
    for (var label = 1; label <= map.regionCount; label++) {
      if (label != background && map.region(label).area >= finger) fingerRegions++;
    }
    return PageCheck._(
      regions: map.regionCount,
      backgroundShare: map.region(background).area / total,
      fingerRegions: fingerRegions,
      lineShare: lines / total,
    );
  }

  /// All regions, the background included.
  final int regions;

  /// Share of the page in the region around the picture.
  final double backgroundShare;

  /// Areas other than the background that a toddler's finger can hit.
  final int fingerRegions;

  /// Share of the page covered by lines.
  final double lineShare;

  /// Difficulty: 1 = a few big areas, 2 = more areas, 3 = fine detail.
  /// Same rule as level_for in tool/pages/build_pages.py.
  int get level {
    if (fingerRegions <= 4 && regions <= 10) return 1;
    if (fingerRegions >= 8 || regions >= 16) return 3;
    return 2;
  }

  /// Reasons the page does not work for a toddler; empty when it does.
  List<String> get problems => [
        if (fingerRegions == 0) 'no area big enough for a finger',
        if (backgroundShare >= 0.97) 'the picture leaks into the background (${(backgroundShare * 100).round()}%)',
        if (lineShare < 0.005) 'lines too faint or thin (${(lineShare * 100).toStringAsFixed(1)}%)',
        if (lineShare > 0.3) 'too much ink (${(lineShare * 100).round()}%)',
      ];

  /// Weak but usable: worth redrawing when there is time.
  List<String> get warnings => [
        if (fingerRegions == 1) 'only one area big enough for a finger',
        if (backgroundShare > 0.9 && backgroundShare < 0.97)
          'the picture is small on the page (background ${(backgroundShare * 100).round()}%)',
      ];

  /// The biggest region touching a corner.
  static int _backgroundLabel(LabelMap map) {
    final corners = {
      map.labelAt(0, 0),
      map.labelAt(map.width - 1, 0),
      map.labelAt(0, map.height - 1),
      map.labelAt(map.width - 1, map.height - 1),
    };
    return corners.reduce((a, b) => map.region(a).area >= map.region(b).area ? a : b);
  }
}
