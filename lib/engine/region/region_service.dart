import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'label_map.dart';
import 'region_builder.dart';

/// Builds label maps off the UI thread and keeps them in an on-disk cache,
/// so a page is analysed once per device instead of on every open.
class RegionService {
  RegionService({required Future<Directory> Function() cacheDirectory}) : _cacheDirectory = cacheDirectory;

  final Future<Directory> Function() _cacheDirectory;

  /// [pageBytes] is the encoded page image (PNG or anything package:image decodes).
  Future<LabelMap> labelMapFor(
    Uint8List pageBytes, {
    RegionBuilderOptions options = const RegionBuilderOptions(),
  }) async {
    final file = await _cacheFile(pageBytes, options);
    if (file != null && await file.exists()) {
      final cached = LabelMap.fromBytes(await file.readAsBytes());
      if (cached != null) return cached;
    }

    final map = await Isolate.run(() => _buildFromEncoded(pageBytes, options));

    if (file != null) {
      try {
        await file.parent.create(recursive: true);
        await file.writeAsBytes(map.toBytes(), flush: true);
      } catch (e) {
        // A missing cache only costs time on the next open.
        debugPrint('Region cache write failed: $e');
      }
    }
    return map;
  }

  Future<File?> _cacheFile(Uint8List pageBytes, RegionBuilderOptions options) async {
    try {
      final dir = await _cacheDirectory();
      final key = [
        'v${RegionBuilder.algorithmVersion}',
        'g${options.gapPx}',
        't${options.lineThreshold}',
        fnv1a32(pageBytes).toRadixString(16),
        pageBytes.length.toRadixString(16),
      ].join('_');
      return File('${dir.path}/regions/$key.clm');
    } catch (e) {
      debugPrint('Region cache unavailable: $e');
      return null;
    }
  }

  static LabelMap _buildFromEncoded(Uint8List pageBytes, RegionBuilderOptions options) {
    final decoded = img.decodeImage(pageBytes);
    if (decoded == null) {
      throw const FormatException('Coloring page could not be decoded');
    }
    final rgba = decoded.convert(numChannels: 4).getBytes(order: img.ChannelOrder.rgba);
    return RegionBuilder.build(rgba, decoded.width, decoded.height, options: options);
  }
}

/// 32-bit FNV-1a hash; enough to tell page files apart for the cache key.
int fnv1a32(Uint8List bytes) {
  var hash = 0x811C9DC5;
  for (final b in bytes) {
    hash = ((hash ^ b) * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
