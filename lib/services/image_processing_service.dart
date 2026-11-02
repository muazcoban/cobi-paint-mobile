import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  /// Create thumbnail
  Future<Uint8List> createThumbnail(Uint8List imageData, {int size = 200}) async {
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final thumbnail = img.copyResizeCropSquare(image, size: size);
    return Uint8List.fromList(img.encodePng(thumbnail));
  }
}
