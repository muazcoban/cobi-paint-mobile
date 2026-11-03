import 'dart:math' as math;
import 'dart:typed_data';

import 'label_map.dart';

/// Tuning for [RegionBuilder.build].
class RegionBuilderOptions {
  const RegionBuilderOptions({
    this.lineThreshold = 153,
    this.gapPx = 2,
    this.minRegionFraction = 0.0002,
    this.minRegionPixels = 16,
  });

  /// Pixels darker than this (0-255, after compositing on white) are lines.
  final int lineThreshold;

  /// Line gaps up to about twice this size are closed so paint cannot leak
  /// through dotted or broken outlines. 0 disables gap closing.
  final int gapPx;

  /// Regions smaller than this share of the page, or than [minRegionPixels],
  /// are too small to tap; they are merged into their neighbours instead.
  final double minRegionFraction;
  final int minRegionPixels;
}

/// Splits a line-art page into fillable regions once, so a tap is a lookup
/// instead of a flood fill.
///
/// Steps: line mask, gap closing by dilating the mask, 4-connected component
/// labelling (diagonal steps in a line no longer leak), recovery of small
/// closed areas the dilation swallowed (pupils, buttons), then growing every
/// label under the line pixels so a fill reaches the lines and leaves no
/// white halo. Pure Dart, safe to run in an isolate.
class RegionBuilder {
  RegionBuilder._();

  /// Bump when the output for the same input changes; saved fills store it.
  static const int algorithmVersion = 1;

  /// [rgba] holds width * height pixels, 4 bytes each.
  static LabelMap build(
    Uint8List rgba,
    int width,
    int height, {
    RegionBuilderOptions options = const RegionBuilderOptions(),
  }) {
    final n = width * height;
    if (rgba.length != n * 4) {
      throw ArgumentError('Expected ${n * 4} RGBA bytes, got ${rgba.length}');
    }

    final lines = lineMask(rgba, width, height, threshold: options.lineThreshold);
    final closed = options.gapPx > 0 ? _dilate(lines, width, height, options.gapPx) : lines;
    final minArea = math.max(options.minRegionPixels, (n * options.minRegionFraction).round());

    final labels = Int32List(n);
    var next = 0;

    // Regions of the gap-closed page; specks are left for the grow step.
    final seeds = _components(closed, width, height);
    final seedToLabel = Int32List(seeds.count + 1);
    for (var s = 1; s <= seeds.count; s++) {
      if (seeds.areas[s] >= minArea) seedToLabel[s] = ++next;
    }
    for (var i = 0; i < n; i++) {
      final s = seeds.labels[i];
      if (s > 0) labels[i] = seedToLabel[s];
    }

    // Closed areas the dilation swallowed completely keep their own label.
    if (options.gapPx > 0) {
      final fine = _components(lines, width, height);
      final hasSeed = Uint8List(fine.count + 1);
      for (var i = 0; i < n; i++) {
        final f = fine.labels[i];
        if (f > 0 && labels[i] > 0) hasSeed[f] = 1;
      }
      final fineToLabel = Int32List(fine.count + 1);
      for (var f = 1; f <= fine.count; f++) {
        if (hasSeed[f] == 0 && fine.areas[f] >= minArea) fineToLabel[f] = ++next;
      }
      for (var i = 0; i < n; i++) {
        final f = fine.labels[i];
        if (f > 0 && fineToLabel[f] > 0) labels[i] = fineToLabel[f];
      }
    }

    if (next > 0xFFFF) {
      throw StateError('Too many regions ($next) for a 16-bit label map');
    }
    if (next > 0) _grow(labels, width, height);

    return LabelMap(
      width: width,
      height: height,
      labels: Uint16List.fromList(labels),
      regions: _stats(labels, width, height, next),
    );
  }

  /// 1 where a pixel is part of a line.
  static Uint8List lineMask(Uint8List rgba, int width, int height, {int threshold = 153}) {
    final n = width * height;
    final mask = Uint8List(n);
    for (var i = 0, p = 0; i < n; i++, p += 4) {
      final a = rgba[p + 3];
      final luma = (rgba[p] * 299 + rgba[p + 1] * 587 + rgba[p + 2] * 114) ~/ 1000;
      // Transparent pixels are paper: composite on white.
      final v = (luma * a + 255 * (255 - a)) ~/ 255;
      if (v < threshold) mask[i] = 1;
    }
    return mask;
  }

  /// Square dilation by [r] pixels, as two separable passes.
  static Uint8List _dilate(Uint8List mask, int width, int height, int r) {
    final rows = Uint8List(mask.length);
    final prefix = Int32List(math.max(width, height) + 1);
    for (var y = 0; y < height; y++) {
      final row = y * width;
      for (var x = 0; x < width; x++) {
        prefix[x + 1] = prefix[x] + mask[row + x];
      }
      for (var x = 0; x < width; x++) {
        final lo = math.max(0, x - r);
        final hi = math.min(width, x + r + 1);
        if (prefix[hi] - prefix[lo] > 0) rows[row + x] = 1;
      }
    }
    final out = Uint8List(mask.length);
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        prefix[y + 1] = prefix[y] + rows[y * width + x];
      }
      for (var y = 0; y < height; y++) {
        final lo = math.max(0, y - r);
        final hi = math.min(height, y + r + 1);
        if (prefix[hi] - prefix[lo] > 0) out[y * width + x] = 1;
      }
    }
    return out;
  }

  /// 4-connected components of the pixels where [blocked] is 0.
  static _Components _components(Uint8List blocked, int width, int height) {
    final n = width * height;
    final labels = Int32List(n);
    final stack = Int32List(n);
    final areas = <int>[0];
    var count = 0;
    for (var start = 0; start < n; start++) {
      if (blocked[start] != 0 || labels[start] != 0) continue;
      count++;
      var area = 0;
      var top = 0;
      stack[top++] = start;
      labels[start] = count;
      while (top > 0) {
        final i = stack[--top];
        area++;
        final x = i % width;
        if (x > 0 && blocked[i - 1] == 0 && labels[i - 1] == 0) {
          labels[i - 1] = count;
          stack[top++] = i - 1;
        }
        if (x < width - 1 && blocked[i + 1] == 0 && labels[i + 1] == 0) {
          labels[i + 1] = count;
          stack[top++] = i + 1;
        }
        if (i >= width && blocked[i - width] == 0 && labels[i - width] == 0) {
          labels[i - width] = count;
          stack[top++] = i - width;
        }
        if (i < n - width && blocked[i + width] == 0 && labels[i + width] == 0) {
          labels[i + width] = count;
          stack[top++] = i + width;
        }
      }
      areas.add(area);
    }
    return _Components(labels, count, areas);
  }

  /// Gives every unlabelled pixel the label of its nearest labelled pixel
  /// (multi-source breadth-first search, 4-connected).
  static void _grow(Int32List labels, int width, int height) {
    final n = width * height;
    final queue = Int32List(n);
    var tail = 0;
    for (var i = 0; i < n; i++) {
      if (labels[i] != 0) queue[tail++] = i;
    }
    var head = 0;
    while (head < tail) {
      final i = queue[head++];
      final l = labels[i];
      final x = i % width;
      if (x > 0 && labels[i - 1] == 0) {
        labels[i - 1] = l;
        queue[tail++] = i - 1;
      }
      if (x < width - 1 && labels[i + 1] == 0) {
        labels[i + 1] = l;
        queue[tail++] = i + 1;
      }
      if (i >= width && labels[i - width] == 0) {
        labels[i - width] = l;
        queue[tail++] = i - width;
      }
      if (i < n - width && labels[i + width] == 0) {
        labels[i + width] = l;
        queue[tail++] = i + width;
      }
    }
  }

  static List<RegionInfo> _stats(Int32List labels, int width, int height, int count) {
    final left = Int32List(count + 1)..fillRange(0, count + 1, width);
    final top = Int32List(count + 1)..fillRange(0, count + 1, height);
    final right = Int32List(count + 1)..fillRange(0, count + 1, -1);
    final bottom = Int32List(count + 1)..fillRange(0, count + 1, -1);
    final area = Int32List(count + 1);
    for (var y = 0; y < height; y++) {
      final row = y * width;
      for (var x = 0; x < width; x++) {
        final l = labels[row + x];
        if (l == 0) continue;
        area[l]++;
        if (x < left[l]) left[l] = x;
        if (x > right[l]) right[l] = x;
        if (y < top[l]) top[l] = y;
        if (y > bottom[l]) bottom[l] = y;
      }
    }
    return [
      for (var l = 1; l <= count; l++)
        RegionInfo(left: left[l], top: top[l], right: right[l], bottom: bottom[l], area: area[l]),
    ];
  }
}

class _Components {
  _Components(this.labels, this.count, this.areas);

  final Int32List labels;
  final int count;

  /// `areas[c]` is the pixel count of component `c`; index 0 is unused.
  final List<int> areas;
}
