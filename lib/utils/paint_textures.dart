import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Boyama doku tipleri
enum PaintTexture {
  none, // Düz renk (texture yok)
  canvas, // Tuval dokusu
  paper, // Kağıt dokusu
  watercolor, // Sulu boya efekti
}

extension PaintTextureExtension on PaintTexture {
  String get displayName {
    switch (this) {
      case PaintTexture.none:
        return 'Düz';
      case PaintTexture.canvas:
        return 'Tuval';
      case PaintTexture.paper:
        return 'Kağıt';
      case PaintTexture.watercolor:
        return 'Sulu Boya';
    }
  }

  String get icon {
    switch (this) {
      case PaintTexture.none:
        return '🎨';
      case PaintTexture.canvas:
        return '🖼️';
      case PaintTexture.paper:
        return '📄';
      case PaintTexture.watercolor:
        return '💧';
    }
  }
}

/// Procedural texture generator - runtime'da doku oluşturur
class TextureGenerator {
  /// Tuval dokusu oluştur (canvas weave pattern)
  static Uint8List generateCanvasTexture(int width, int height) {
    final pixels = Uint8List(width * height * 4);
    final random = math.Random(42);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * width + x) * 4;

        // Tuval örgü deseni - yatay ve dikey çizgiler
        final weaveX = (x % 4 < 2) ? 1.0 : 0.85;
        final weaveY = (y % 4 < 2) ? 1.0 : 0.85;
        final weave = weaveX * weaveY;

        // Rastgele gürültü ekle
        final noise = 0.9 + random.nextDouble() * 0.2;

        // Alpha değeri (doku yoğunluğu)
        final alpha = ((1.0 - weave * noise) * 80).clamp(0, 255).toInt();

        pixels[index] = 0; // R
        pixels[index + 1] = 0; // G
        pixels[index + 2] = 0; // B
        pixels[index + 3] = alpha; // A
      }
    }

    return pixels;
  }

  /// Kağıt dokusu oluştur (paper grain)
  static Uint8List generatePaperTexture(int width, int height) {
    final pixels = Uint8List(width * height * 4);
    final random = math.Random(123);

    // Perlin-benzeri gürültü için önceden hesaplanmış değerler
    final noiseGrid = List.generate(
      (height ~/ 8 + 2),
      (_) => List.generate((width ~/ 8 + 2), (_) => random.nextDouble()),
    );

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * width + x) * 4;

        // Büyük ölçekli gürültü (kağıt fiber dokusu)
        final gx = x / 8.0;
        final gy = y / 8.0;
        final ix = gx.floor();
        final iy = gy.floor();
        final fx = gx - ix;
        final fy = gy - iy;

        // Bilinear interpolation
        final n00 = noiseGrid[iy % noiseGrid.length][ix % noiseGrid[0].length];
        final n10 = noiseGrid[iy % noiseGrid.length][(ix + 1) % noiseGrid[0].length];
        final n01 = noiseGrid[(iy + 1) % noiseGrid.length][ix % noiseGrid[0].length];
        final n11 = noiseGrid[(iy + 1) % noiseGrid.length][(ix + 1) % noiseGrid[0].length];

        final nx0 = n00 * (1 - fx) + n10 * fx;
        final nx1 = n01 * (1 - fx) + n11 * fx;
        final largeNoise = nx0 * (1 - fy) + nx1 * fy;

        // Küçük ölçekli gürültü (ince taneler)
        final fineNoise = random.nextDouble() * 0.3;

        // Birleştir
        final combined = largeNoise * 0.7 + fineNoise;
        final alpha = (combined * 40).clamp(0, 255).toInt();

        pixels[index] = 0; // R
        pixels[index + 1] = 0; // G
        pixels[index + 2] = 0; // B
        pixels[index + 3] = alpha; // A
      }
    }

    return pixels;
  }

  /// Sulu boya dokusu oluştur (watercolor effect)
  static Uint8List generateWatercolorTexture(int width, int height) {
    final pixels = Uint8List(width * height * 4);
    final random = math.Random(456);

    // Sulu boya efekti için blob'lar oluştur
    final blobs = <_WatercolorBlob>[];
    final blobCount = (width * height) ~/ 2000;

    for (int i = 0; i < blobCount; i++) {
      blobs.add(_WatercolorBlob(
        x: random.nextDouble() * width,
        y: random.nextDouble() * height,
        radius: 10 + random.nextDouble() * 30,
        intensity: 0.3 + random.nextDouble() * 0.4,
      ));
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * width + x) * 4;

        // Blob'lardan gelen etki
        double blobEffect = 0;
        for (final blob in blobs) {
          final dx = x - blob.x;
          final dy = y - blob.y;
          final dist = math.sqrt(dx * dx + dy * dy);
          if (dist < blob.radius) {
            // Yumuşak kenar
            final falloff = 1 - (dist / blob.radius);
            blobEffect += blob.intensity * falloff * falloff;
          }
        }

        // Rastgele pigment dağılımı
        final pigmentNoise = random.nextDouble() * 0.15;

        // Kenar koyulaşması efekti
        final edgeDarkening = random.nextDouble() * 0.1;

        final combined = (blobEffect + pigmentNoise + edgeDarkening).clamp(0.0, 1.0);
        final alpha = (combined * 60).clamp(0, 255).toInt();

        // Sulu boya için hafif renk varyasyonu
        final tint = (random.nextDouble() * 20).toInt();

        pixels[index] = tint; // R - hafif sıcak ton
        pixels[index + 1] = 0; // G
        pixels[index + 2] = (tint * 0.5).toInt(); // B
        pixels[index + 3] = alpha; // A
      }
    }

    return pixels;
  }

  /// Belirtilen tipteki dokuyu oluştur ve ui.Image'a dönüştür
  static Future<ui.Image?> createTextureImage(
    PaintTexture texture,
    int width,
    int height,
  ) async {
    if (texture == PaintTexture.none) return null;

    Uint8List pixels;
    switch (texture) {
      case PaintTexture.canvas:
        pixels = generateCanvasTexture(width, height);
        break;
      case PaintTexture.paper:
        pixels = generatePaperTexture(width, height);
        break;
      case PaintTexture.watercolor:
        pixels = generateWatercolorTexture(width, height);
        break;
      case PaintTexture.none:
        return null;
    }

    // Uint8List'i ui.Image'a dönüştür
    final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );

    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    final image = frame.image;

    codec.dispose();
    descriptor.dispose();
    buffer.dispose();

    return image;
  }
}

class _WatercolorBlob {
  final double x;
  final double y;
  final double radius;
  final double intensity;

  _WatercolorBlob({
    required this.x,
    required this.y,
    required this.radius,
    required this.intensity,
  });
}
