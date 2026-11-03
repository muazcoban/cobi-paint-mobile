import 'dart:typed_data';

/// One fillable area of a coloring page.
class RegionInfo {
  const RegionInfo({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.area,
  });

  /// Inclusive pixel bounds.
  final int left;
  final int top;
  final int right;
  final int bottom;

  /// Pixel count, including the line pixels the region grew under.
  final int area;
}

/// Maps every pixel of a coloring page to the region it belongs to.
///
/// Labels start at 1. Label 0 means "no region" and only appears when the
/// page has no fillable area at all.
class LabelMap {
  LabelMap({
    required this.width,
    required this.height,
    required this.labels,
    required this.regions,
  }) : assert(labels.length == width * height);

  final int width;
  final int height;
  final Uint16List labels;

  /// `regions[label - 1]` describes `label`.
  final List<RegionInfo> regions;

  int get regionCount => regions.length;

  int labelAt(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return 0;
    return labels[y * width + x];
  }

  RegionInfo region(int label) => regions[label - 1];

  // Binary layout: magic, region count, width, height (uint32 each),
  // then 5 x uint32 per region, then the labels in host byte order.
  static const int _magic = 0x434C4D31; // "CLM1"
  static const int _headerBytes = 16;
  static const int _regionBytes = 20;

  /// Compact binary form for the on-disk cache.
  Uint8List toBytes() {
    final labelsStart = _headerBytes + regions.length * _regionBytes;
    final out = Uint8List(labelsStart + labels.lengthInBytes);
    final view = ByteData.sublistView(out)
      ..setUint32(0, _magic)
      ..setUint32(4, regions.length)
      ..setUint32(8, width)
      ..setUint32(12, height);
    var offset = _headerBytes;
    for (final r in regions) {
      view
        ..setUint32(offset, r.left)
        ..setUint32(offset + 4, r.top)
        ..setUint32(offset + 8, r.right)
        ..setUint32(offset + 12, r.bottom)
        ..setUint32(offset + 16, r.area);
      offset += _regionBytes;
    }
    out.setRange(labelsStart, out.length, labels.buffer.asUint8List(labels.offsetInBytes, labels.lengthInBytes));
    return out;
  }

  /// Reads [toBytes] output. Returns null when the data is not a label map.
  static LabelMap? fromBytes(Uint8List data) {
    if (data.length < _headerBytes) return null;
    final view = ByteData.sublistView(data);
    if (view.getUint32(0) != _magic) return null;
    final count = view.getUint32(4);
    final width = view.getUint32(8);
    final height = view.getUint32(12);
    final labelsStart = _headerBytes + count * _regionBytes;
    if (data.length != labelsStart + width * height * 2) return null;

    final regions = <RegionInfo>[];
    for (var i = 0; i < count; i++) {
      final o = _headerBytes + i * _regionBytes;
      regions.add(RegionInfo(
        left: view.getUint32(o),
        top: view.getUint32(o + 4),
        right: view.getUint32(o + 8),
        bottom: view.getUint32(o + 12),
        area: view.getUint32(o + 16),
      ));
    }
    // Copy so the labels are 2-byte aligned regardless of the source buffer.
    final labels = Uint16List(width * height);
    labels.buffer.asUint8List().setRange(0, labels.lengthInBytes, data, labelsStart);
    return LabelMap(width: width, height: height, labels: labels, regions: regions);
  }
}
