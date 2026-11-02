import 'dart:typed_data';

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/page_progress.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 100 x 100 page: background (1), two big squares (2, 3) and a crumb (4).
LabelMap _map() {
  const w = 100, h = 100;
  final labels = Uint16List(w * h);
  void box(int label, int left, int top, int right, int bottom) {
    for (var y = top; y <= bottom; y++) {
      for (var x = left; x <= right; x++) {
        labels[y * w + x] = label;
      }
    }
  }

  box(1, 0, 0, 99, 99);
  box(2, 10, 10, 40, 40); // 31 x 31 = 961 px, bigger than a 10 x 10 fingertip
  box(3, 50, 50, 80, 80);
  box(4, 90, 90, 92, 92); // 3 x 3: too small to matter
  final areas = {1: 0, 2: 0, 3: 0, 4: 0};
  for (final l in labels) {
    areas[l] = areas[l]! + 1;
  }
  return LabelMap(
    width: w,
    height: h,
    labels: labels,
    regions: [
      for (final l in [1, 2, 3, 4]) RegionInfo(left: 0, top: 0, right: 0, bottom: 0, area: areas[l]!),
    ],
  );
}

void main() {
  test('the picture is complete once every finger-sized area has paint', () {
    final doc = ColoringDocument(_map());
    expect(PageProgress.of(doc).total, 2);
    expect(PageProgress.of(doc).isComplete, isFalse);

    doc.fillAt(20, 20, 0xFFFF0000);
    expect(PageProgress.of(doc).filled, 1);
    expect(PageProgress.of(doc).isComplete, isFalse);

    doc.fillAt(60, 60, 0xFF00FF00);
    expect(PageProgress.of(doc).isComplete, isTrue, reason: 'the crumb and the background do not count');
  });

  test('painting the background or the crumb changes nothing', () {
    final doc = ColoringDocument(_map());
    doc.fillAt(5, 5, 0xFF0000FF);
    doc.fillAt(91, 91, 0xFF0000FF);
    expect(PageProgress.of(doc).filled, 0);
  });

  test('a page with nothing to fill is never complete', () {
    final labels = Uint16List(16)..fillRange(0, 16, 1);
    final map = LabelMap(width: 4, height: 4, labels: labels, regions: const [RegionInfo(left: 0, top: 0, right: 3, bottom: 3, area: 16)]);
    expect(PageProgress.of(ColoringDocument(map)).isComplete, isFalse);
  });
}
