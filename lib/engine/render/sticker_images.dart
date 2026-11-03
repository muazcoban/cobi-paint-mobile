import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../document/sticker.dart';

/// The sticker pictures, decoded once for the whole app. A picture that is
/// missing is skipped: the page still draws, the sticker just stays empty.
class StickerImages {
  StickerImages._();

  static final Map<String, ui.Image> _images = {};
  static final Map<String, Future<void>> _loading = {};

  static ui.Image? of(String code) => _images[code];

  static bool get isEmpty => _images.isEmpty;

  /// Loads the pictures for [codes] that are not loaded yet.
  static Future<void> ensure(Iterable<String> codes) =>
      Future.wait([for (final code in codes.toSet()) if (!_images.containsKey(code)) _load(code)]);

  static Future<void> _load(String code) => _loading.putIfAbsent(code, () async {
        try {
          final data = await rootBundle.load('assets/stickers/$code.png');
          _images[code] = await decodeImageFromList(data.buffer.asUint8List());
        } catch (e) {
          debugPrint('Sticker picture missing: $code: $e');
        } finally {
          unawaited(_loading.remove(code));
        }
      });

  /// Draws [stickers] in page coordinates, each turned by its tilt.
  static void draw(Canvas canvas, Iterable<Sticker> stickers) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    for (final sticker in stickers) {
      final image = _images[sticker.code];
      if (image == null) continue;
      canvas.save();
      canvas.translate(sticker.x, sticker.y);
      canvas.rotate(sticker.angle);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromCenter(center: Offset.zero, width: sticker.size, height: sticker.size),
        paint,
      );
      canvas.restore();
    }
  }
}
