import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Gelişmiş resim işleme servisi - OpenCV'ye gerek kalmadan
/// Canny-benzeri edge detection ve morphological operations içerir
class EnhancedImageService {
  /// Ana dönüştürme fonksiyonu - compute ile arka planda çalışır
  Future<Uint8List> convertToColoringPage(
    Uint8List imageData, {
    int lineThickness = 2,
    int detailLevel = 1, // 0: düşük, 1: orta, 2: yüksek
    int smoothness = 1, // 0: az, 1: orta, 2: çok
  }) async {
    return compute(
      _processImage,
      _ProcessingParams(
        imageData: imageData,
        lineThickness: lineThickness,
        detailLevel: detailLevel,
        smoothness: smoothness,
      ),
    );
  }

  /// Arka planda çalışacak işlem fonksiyonu
  static Uint8List _processImage(_ProcessingParams params) {
    // 1. Decode image
    final image = img.decodeImage(params.imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // 2. Resize if needed (max 1024px)
    img.Image processed = _resizeIfNeeded(image, 1024);

    // 3. Bilateral-benzeri gürültü azaltma (kenar koruyucu)
    final blurRadius = [1, 2, 3][params.smoothness];
    processed = _edgePreservingSmooth(processed, blurRadius);

    // 4. Convert to grayscale
    processed = img.grayscale(processed);

    // 5. Canny-benzeri edge detection (dual threshold)
    // Çıktı: beyaz zemin (255), siyah çizgiler (0)
    final thresholds = _getThresholds(params.detailLevel);
    processed = _cannyEdgeDetection(processed, thresholds.$1, thresholds.$2);

    // 6. Clean up isolated noise pixels (invert'ten önce, siyah çizgiler üzerinde)
    processed = _removeNoise(processed, 2);

    // 7. Morphological Closing (çizgi boşluklarını kapat)
    // Daha güçlü closing için radius artırıldı
    final closeRadius = params.lineThickness + 1;
    processed = _morphologicalClose(processed, closeRadius);

    // 8. Dilate edges (çizgi kalınlığı)
    if (params.lineThickness > 1) {
      processed = _dilateEdges(processed, params.lineThickness);
    }

    // NOT: Invert YOK! Canny zaten beyaz zemin + siyah çizgi veriyor
    // Bu boyama için doğru format

    // 9. Encode as PNG
    return Uint8List.fromList(img.encodePng(processed));
  }

  /// Threshold değerlerini detay seviyesine göre ayarla
  static (int, int) _getThresholds(int detailLevel) {
    switch (detailLevel) {
      case 0:
        return (80, 160); // Düşük detay - kalın ana çizgiler
      case 1:
        return (40, 100); // Orta detay
      case 2:
        return (20, 60); // Yüksek detay - ince çizgiler
      default:
        return (40, 100);
    }
  }

  /// Resmi max boyuta küçült
  static img.Image _resizeIfNeeded(img.Image image, int maxSize) {
    if (image.width <= maxSize && image.height <= maxSize) return image;

    if (image.width > image.height) {
      return img.copyResize(image, width: maxSize);
    } else {
      return img.copyResize(image, height: maxSize);
    }
  }

  /// Kenar koruyucu yumuşatma (Bilateral filter benzeri)
  static img.Image _edgePreservingSmooth(img.Image image, int radius) {
    if (radius <= 0) return image;

    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    // Sigma values
    final sigmaSpace = radius.toDouble();
    final sigmaColor = 30.0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final centerPixel = image.getPixel(x, y);
        final centerR = centerPixel.r.toDouble();
        final centerG = centerPixel.g.toDouble();
        final centerB = centerPixel.b.toDouble();

        double sumR = 0, sumG = 0, sumB = 0;
        double weightSum = 0;

        for (int ky = -radius; ky <= radius; ky++) {
          for (int kx = -radius; kx <= radius; kx++) {
            final nx = (x + kx).clamp(0, width - 1);
            final ny = (y + ky).clamp(0, height - 1);

            final pixel = image.getPixel(nx, ny);
            final r = pixel.r.toDouble();
            final g = pixel.g.toDouble();
            final b = pixel.b.toDouble();

            // Spatial weight
            final spatialDist = math.sqrt(kx * kx + ky * ky);
            final spatialWeight =
                math.exp(-(spatialDist * spatialDist) / (2 * sigmaSpace * sigmaSpace));

            // Color weight
            final colorDist = math.sqrt(
              (r - centerR) * (r - centerR) +
                  (g - centerG) * (g - centerG) +
                  (b - centerB) * (b - centerB),
            );
            final colorWeight =
                math.exp(-(colorDist * colorDist) / (2 * sigmaColor * sigmaColor));

            final weight = spatialWeight * colorWeight;
            sumR += r * weight;
            sumG += g * weight;
            sumB += b * weight;
            weightSum += weight;
          }
        }

        if (weightSum > 0) {
          result.setPixel(
            x,
            y,
            img.ColorRgb8(
              (sumR / weightSum).round().clamp(0, 255),
              (sumG / weightSum).round().clamp(0, 255),
              (sumB / weightSum).round().clamp(0, 255),
            ),
          );
        } else {
          result.setPixel(x, y, centerPixel);
        }
      }
    }

    return result;
  }

  /// Canny-benzeri edge detection (Sobel + dual threshold + hysteresis)
  static img.Image _cannyEdgeDetection(
    img.Image image,
    int lowThreshold,
    int highThreshold,
  ) {
    final width = image.width;
    final height = image.height;

    // Gaussian blur first
    final blurred = img.gaussianBlur(image, radius: 1);

    // Gradient magnitude and direction
    final magnitude = List.generate(height, (_) => List.filled(width, 0.0));
    final direction = List.generate(height, (_) => List.filled(width, 0.0));

    // Sobel kernels
    const sobelX = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1]
    ];
    const sobelY = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1]
    ];

    // Calculate gradients
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double gx = 0;
        double gy = 0;

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = blurred.getPixel(x + kx, y + ky);
            final gray = pixel.r.toDouble();
            gx += gray * sobelX[ky + 1][kx + 1];
            gy += gray * sobelY[ky + 1][kx + 1];
          }
        }

        magnitude[y][x] = math.sqrt(gx * gx + gy * gy);
        direction[y][x] = math.atan2(gy, gx);
      }
    }

    // Non-maximum suppression
    final suppressed = List.generate(height, (_) => List.filled(width, 0.0));

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final angle = direction[y][x] * 180 / math.pi;
        final normalizedAngle = angle < 0 ? angle + 180 : angle;

        double q = 255.0;
        double r = 255.0;

        // Check neighbors based on gradient direction
        if ((normalizedAngle >= 0 && normalizedAngle < 22.5) ||
            (normalizedAngle >= 157.5 && normalizedAngle <= 180)) {
          q = magnitude[y][x + 1];
          r = magnitude[y][x - 1];
        } else if (normalizedAngle >= 22.5 && normalizedAngle < 67.5) {
          q = magnitude[y + 1][x - 1];
          r = magnitude[y - 1][x + 1];
        } else if (normalizedAngle >= 67.5 && normalizedAngle < 112.5) {
          q = magnitude[y + 1][x];
          r = magnitude[y - 1][x];
        } else if (normalizedAngle >= 112.5 && normalizedAngle < 157.5) {
          q = magnitude[y - 1][x - 1];
          r = magnitude[y + 1][x + 1];
        }

        if (magnitude[y][x] >= q && magnitude[y][x] >= r) {
          suppressed[y][x] = magnitude[y][x];
        }
      }
    }

    // Double threshold and hysteresis
    final result = img.Image(width: width, height: height);

    // Fill with white
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        result.setPixel(x, y, img.ColorRgb8(255, 255, 255));
      }
    }

    // Strong edges
    final strong = List.generate(height, (_) => List.filled(width, false));

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (suppressed[y][x] >= highThreshold) {
          result.setPixel(x, y, img.ColorRgb8(0, 0, 0));
          strong[y][x] = true;
        }
      }
    }

    // Hysteresis: connect weak edges to strong edges
    bool changed = true;
    while (changed) {
      changed = false;
      for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
          if (suppressed[y][x] >= lowThreshold && !strong[y][x]) {
            // Check if connected to a strong edge
            bool connectedToStrong = false;
            for (int dy = -1; dy <= 1 && !connectedToStrong; dy++) {
              for (int dx = -1; dx <= 1 && !connectedToStrong; dx++) {
                if (strong[y + dy][x + dx]) {
                  connectedToStrong = true;
                }
              }
            }

            if (connectedToStrong) {
              result.setPixel(x, y, img.ColorRgb8(0, 0, 0));
              strong[y][x] = true;
              changed = true;
            }
          }
        }
      }
    }

    return result;
  }

  /// Morphological closing (dilation then erosion) - çizgi boşluklarını kapat
  static img.Image _morphologicalClose(img.Image image, int radius) {
    // Önce gap bridging uygula (yakın çizgileri birleştir)
    var result = _bridgeGaps(image, radius * 2);
    // Sonra standard closing
    final dilated = _dilateEdges(result, radius);
    return _erodeEdges(dilated, radius);
  }

  /// Yakın çizgi uçlarını birleştir (gap bridging)
  static img.Image _bridgeGaps(img.Image image, int maxGap) {
    final width = image.width;
    final height = image.height;
    final result = img.Image.from(image);

    // Her siyah piksel için, yakınında başka siyah piksel ara
    // ve aralarını doldur
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final pixel = image.getPixel(x, y);
        if (pixel.r < 128) {
          // Siyah piksel bulundu, çevresinde boşluk sonrası başka siyah ara
          for (int direction = 0; direction < 8; direction++) {
            final dx = [1, 1, 0, -1, -1, -1, 0, 1][direction];
            final dy = [0, 1, 1, 1, 0, -1, -1, -1][direction];

            // Bu yönde maxGap mesafeye kadar tara
            bool foundGap = false;
            int gapStart = 0;
            int gapEnd = 0;

            for (int dist = 1; dist <= maxGap; dist++) {
              final nx = x + dx * dist;
              final ny = y + dy * dist;

              if (nx < 0 || nx >= width || ny < 0 || ny >= height) break;

              final neighborPixel = image.getPixel(nx, ny);
              if (neighborPixel.r >= 128) {
                // Beyaz piksel (boşluk)
                if (!foundGap) {
                  foundGap = true;
                  gapStart = dist;
                }
                gapEnd = dist;
              } else if (foundGap) {
                // Boşluktan sonra tekrar siyah bulundu - köprü kur
                final gapSize = gapEnd - gapStart + 1;
                if (gapSize <= maxGap) {
                  // Boşluğu doldur
                  for (int fill = gapStart; fill <= gapEnd; fill++) {
                    final fx = x + dx * fill;
                    final fy = y + dy * fill;
                    result.setPixel(fx, fy, img.ColorRgb8(0, 0, 0));
                  }
                }
                break;
              }
            }
          }
        }
      }
    }

    return result;
  }

  /// Dilate edges (genişlet)
  static img.Image _dilateEdges(img.Image image, int radius) {
    if (radius <= 0) return image;

    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    // Fill with white
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        result.setPixel(x, y, img.ColorRgb8(255, 255, 255));
      }
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        if (pixel.r < 128) {
          // Black pixel (edge)
          for (int dy = -radius; dy <= radius; dy++) {
            for (int dx = -radius; dx <= radius; dx++) {
              final nx = x + dx;
              final ny = y + dy;
              if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
                if (dx * dx + dy * dy <= radius * radius) {
                  result.setPixel(nx, ny, img.ColorRgb8(0, 0, 0));
                }
              }
            }
          }
        }
      }
    }

    return result;
  }

  /// Erode edges (daralt)
  static img.Image _erodeEdges(img.Image image, int radius) {
    if (radius <= 0) return image;

    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    // Fill with white (inverse of dilation)
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        result.setPixel(x, y, img.ColorRgb8(255, 255, 255));
      }
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        if (pixel.r < 128) {
          // Check if all neighbors within radius are also black
          bool allBlack = true;
          for (int dy = -radius; dy <= radius && allBlack; dy++) {
            for (int dx = -radius; dx <= radius && allBlack; dx++) {
              if (dx * dx + dy * dy <= radius * radius) {
                final nx = x + dx;
                final ny = y + dy;
                if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
                  final neighborPixel = image.getPixel(nx, ny);
                  if (neighborPixel.r >= 128) {
                    allBlack = false;
                  }
                } else {
                  allBlack = false;
                }
              }
            }
          }

          if (allBlack) {
            result.setPixel(x, y, img.ColorRgb8(0, 0, 0));
          }
        }
      }
    }

    return result;
  }

  /// Remove isolated noise pixels
  static img.Image _removeNoise(img.Image image, int minNeighbors) {
    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);

        if (pixel.r < 128) {
          // Black pixel - count black neighbors
          int blackNeighbors = 0;
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              if (dx == 0 && dy == 0) continue;
              final nx = x + dx;
              final ny = y + dy;
              if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
                final neighborPixel = image.getPixel(nx, ny);
                if (neighborPixel.r < 128) {
                  blackNeighbors++;
                }
              }
            }
          }

          if (blackNeighbors >= minNeighbors) {
            result.setPixel(x, y, img.ColorRgb8(0, 0, 0));
          } else {
            result.setPixel(x, y, img.ColorRgb8(255, 255, 255));
          }
        } else {
          result.setPixel(x, y, img.ColorRgb8(255, 255, 255));
        }
      }
    }

    return result;
  }
}

/// İşlem parametrelerini taşıyan sınıf (compute için gerekli)
class _ProcessingParams {
  final Uint8List imageData;
  final int lineThickness;
  final int detailLevel;
  final int smoothness;

  _ProcessingParams({
    required this.imageData,
    required this.lineThickness,
    required this.detailLevel,
    required this.smoothness,
  });
}

/// Resim işleme preset'leri
enum ImagePreset {
  portrait, // Portre fotoğrafları için
  landscape, // Manzara fotoğrafları için
  detailed, // Detaylı çizimler için
  cartoon, // Karikatür tarzı için
}

/// Preset parametreleri
extension ImagePresetExtension on ImagePreset {
  /// Preset'e göre parametreleri döndür
  ({int detailLevel, int smoothness, int lineThickness}) get params {
    switch (this) {
      case ImagePreset.portrait:
        // Portre: Düşük detay, kalın çizgi, çok yumuşatma
        return (detailLevel: 0, smoothness: 2, lineThickness: 3);
      case ImagePreset.landscape:
        // Manzara: Orta detay, ince çizgi, orta yumuşatma
        return (detailLevel: 1, smoothness: 1, lineThickness: 2);
      case ImagePreset.detailed:
        // Detaylı: Yüksek detay, ince çizgi, az yumuşatma
        return (detailLevel: 2, smoothness: 0, lineThickness: 1);
      case ImagePreset.cartoon:
        // Karikatür: Düşük detay, kalın çizgi, az yumuşatma
        return (detailLevel: 0, smoothness: 0, lineThickness: 4);
    }
  }

  /// Preset adı (Türkçe)
  String get displayName {
    switch (this) {
      case ImagePreset.portrait:
        return 'Portre';
      case ImagePreset.landscape:
        return 'Manzara';
      case ImagePreset.detailed:
        return 'Detaylı';
      case ImagePreset.cartoon:
        return 'Karikatür';
    }
  }

  /// Preset ikonu
  String get icon {
    switch (this) {
      case ImagePreset.portrait:
        return '👤';
      case ImagePreset.landscape:
        return '🏞️';
      case ImagePreset.detailed:
        return '🔍';
      case ImagePreset.cartoon:
        return '🎨';
    }
  }
}
