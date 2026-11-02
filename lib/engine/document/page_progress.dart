import '../region/label_map.dart';
import 'coloring_document.dart';

/// How much of a page a child has coloured, counting only the areas that
/// matter to a toddler: everything but the background and the crumbs too
/// small for a fingertip. The background is the biggest region touching a
/// corner, the same rule as PageCheck.
class PageProgress {
  PageProgress._(this.filled, this.total);

  factory PageProgress.of(ColoringDocument document) {
    final map = document.map;
    if (map.regionCount == 0) return PageProgress._(0, 0);
    final background = backgroundLabel(map);
    final finger = (map.width * 0.1) * (map.height * 0.1);
    var filled = 0;
    var total = 0;
    for (var label = 1; label <= map.regionCount; label++) {
      if (label == background || map.region(label).area < finger) continue;
      total++;
      if (document.fillOf(label) != 0) filled++;
    }
    return PageProgress._(filled, total);
  }

  final int filled;
  final int total;

  /// Every finger-sized area has paint. Never true for a page with none.
  bool get isComplete => total > 0 && filled == total;

  /// The biggest region touching a corner.
  static int backgroundLabel(LabelMap map) {
    final corners = {
      map.labelAt(0, 0),
      map.labelAt(map.width - 1, 0),
      map.labelAt(0, map.height - 1),
      map.labelAt(map.width - 1, map.height - 1),
    }..remove(0);
    if (corners.isEmpty) return 0;
    return corners.reduce((a, b) => map.region(a).area >= map.region(b).area ? a : b);
  }
}
