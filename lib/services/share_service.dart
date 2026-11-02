import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Shares a saved artwork through the system share sheet. [text] comes
  /// from the caller in the app's language. [origin] is the global rect of
  /// the control that opened it; iPad and Mac need it to anchor the share
  /// popover and fail without it.
  Future<void> shareArtwork(
    String imagePath, {
    required String text,
    String? subject,
    Rect? origin,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath)],
          text: text,
          subject: subject,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      debugPrint('Error sharing artwork: $e');
      rethrow;
    }
  }
}
