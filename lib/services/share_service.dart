import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Share an image to social media
  Future<void> shareImage(
    Uint8List imageData, {
    String? text,
    String? subject,
  }) async {
    try {
      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/share_image.png');
      await tempFile.writeAsBytes(imageData);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          text: text ?? 'Cobi Paint ile boyadım! 🎨',
          subject: subject,
        ),
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
      rethrow;
    }
  }

  /// Share artwork with metadata
  Future<void> shareArtwork(
    String imagePath, {
    String? artworkName,
    String? message,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final shareText = message ??
          '${artworkName != null ? '"$artworkName" - ' : ''}Cobi Paint ile boyadım! 🎨\n\nÇocuklar için eğlenceli boyama uygulaması!';

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath)],
          text: shareText,
          subject: artworkName ?? 'Benim Boyamam',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing artwork: $e');
      rethrow;
    }
  }
}
