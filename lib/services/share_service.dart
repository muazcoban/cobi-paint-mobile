import 'dart:io';
import 'dart:typed_data';
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

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: text ?? 'Cobi Paint ile boyadım! 🎨',
        subject: subject,
      );
    } catch (e) {
      print('Error sharing image: $e');
      rethrow;
    }
  }

  /// Share to WhatsApp specifically
  Future<void> shareToWhatsApp(
    Uint8List imageData, {
    String? text,
  }) async {
    try {
      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/share_whatsapp.png');
      await tempFile.writeAsBytes(imageData);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: text ?? 'Cobi Paint ile boyadım! 🎨',
      );
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
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

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: shareText,
        subject: artworkName ?? 'Benim Boyamam',
      );
    } catch (e) {
      print('Error sharing artwork: $e');
      rethrow;
    }
  }

  /// Share multiple images
  Future<void> shareMultipleImages(
    List<String> imagePaths, {
    String? text,
  }) async {
    try {
      final xFiles = <XFile>[];
      for (final path in imagePaths) {
        final file = File(path);
        if (await file.exists()) {
          xFiles.add(XFile(path));
        }
      }

      if (xFiles.isEmpty) {
        throw Exception('No valid images to share');
      }

      await Share.shareXFiles(
        xFiles,
        text: text ?? 'Cobi Paint ile boyadım! 🎨',
      );
    } catch (e) {
      print('Error sharing multiple images: $e');
      rethrow;
    }
  }

  /// Share text only
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject);
    } catch (e) {
      print('Error sharing text: $e');
      rethrow;
    }
  }
}
