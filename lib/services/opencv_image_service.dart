import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

/// OpenCV tabanlı görüntü işleme servisi
/// Kapalı konturlu boyama sayfaları oluşturur
class OpenCVImageService {
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
    final mat = cv.imdecode(params.imageData, cv.IMREAD_COLOR);
    if (mat.isEmpty) {
      throw Exception('Failed to decode image');
    }

    // 2. Resize if needed (max 1024px)
    cv.Mat processed = _resizeIfNeeded(mat, 1024);

    // 3. Bilateral Filter (kenar koruyucu gürültü azaltma)
    // Smoothness'a göre ayarla: daha yüksek = daha fazla blur
    final d = [5, 9, 13][params.smoothness.clamp(0, 2)];
    final sigmaColor = [50.0, 75.0, 100.0][params.smoothness.clamp(0, 2)];
    processed = cv.bilateralFilter(processed, d, sigmaColor, sigmaColor);

    // 4. Convert to grayscale
    processed = cv.cvtColor(processed, cv.COLOR_BGR2GRAY);

    // 5. Canny Edge Detection (dual threshold)
    final thresholds = _getThresholds(params.detailLevel);
    processed = cv.canny(processed, thresholds.$1, thresholds.$2);

    // 6. Agresif Morphological Closing (çizgi boşluklarını kapat)
    // Bu en kritik adım - birden fazla closing pass uygula
    processed = _aggressiveClosing(processed, params.lineThickness);

    // 7. Dilate edges (çizgi kalınlığı)
    if (params.lineThickness > 1) {
      final dilateKernel = cv.getStructuringElement(
        cv.MORPH_ELLIPSE,
        (params.lineThickness, params.lineThickness),
      );
      processed = cv.dilate(processed, dilateKernel);
    }

    // 8. Invert colors (beyaz zemin, siyah çizgi)
    // Canny siyah zemin + beyaz çizgi verir, biz tersini istiyoruz
    processed = cv.bitwiseNOT(processed);

    // 9. Encode as PNG
    final (success, encoded) = cv.imencode('.png', processed);
    if (!success) {
      throw Exception('Failed to encode image');
    }

    return encoded;
  }

  /// Çok agresif morphological closing - boşlukları tamamen kapat
  static cv.Mat _aggressiveClosing(cv.Mat image, int lineThickness) {
    cv.Mat result = image;

    // ====== AŞAMA 1: Küçük boşlukları kapat ======
    // 3x3 ellipse ile başla
    final kernel3 = cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, kernel3);

    // 5x5 ellipse
    final kernel5 = cv.getStructuringElement(cv.MORPH_ELLIPSE, (5, 5));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, kernel5);

    // ====== AŞAMA 2: Orta boşlukları kapat ======
    // 7x7 ellipse
    final kernel7 = cv.getStructuringElement(cv.MORPH_ELLIPSE, (7, 7));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, kernel7);

    // 9x9 ellipse
    final kernel9 = cv.getStructuringElement(cv.MORPH_ELLIPSE, (9, 9));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, kernel9);

    // ====== AŞAMA 3: Büyük boşlukları kapat ======
    // 11x11 ellipse
    final kernel11 = cv.getStructuringElement(cv.MORPH_ELLIPSE, (11, 11));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, kernel11);

    // 15x15 ellipse - çok büyük boşluklar için
    final kernel15 = cv.getStructuringElement(cv.MORPH_ELLIPSE, (15, 15));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, kernel15);

    // ====== AŞAMA 4: Yönlü boşlukları kapat ======
    // Yatay çizgiler için geniş dikdörtgen
    final rectH = cv.getStructuringElement(cv.MORPH_RECT, (15, 3));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, rectH);

    // Dikey çizgiler için uzun dikdörtgen
    final rectV = cv.getStructuringElement(cv.MORPH_RECT, (3, 15));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, rectV);

    // Çapraz boşluklar için (45 derece)
    final rect45a = cv.getStructuringElement(cv.MORPH_RECT, (11, 5));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, rect45a);

    final rect45b = cv.getStructuringElement(cv.MORPH_RECT, (5, 11));
    result = cv.morphologyEx(result, cv.MORPH_CLOSE, rect45b);

    // ====== AŞAMA 5: Son temizlik - dilation sonra erosion ======
    // lineThickness'a göre ekstra closing
    if (lineThickness >= 2) {
      final extraSize = lineThickness * 3 + 1;
      final extraKernel = cv.getStructuringElement(
        cv.MORPH_ELLIPSE,
        (extraSize, extraSize),
      );
      result = cv.morphologyEx(result, cv.MORPH_CLOSE, extraKernel);
    }

    // ====== AŞAMA 6: Çok küçük delikleri doldur ======
    // Dilation -> Erosion tekrar (closing'in özü)
    final finalKernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (5, 5));
    result = cv.dilate(result, finalKernel);
    result = cv.erode(result, finalKernel);

    return result;
  }

  /// Threshold değerlerini detay seviyesine göre ayarla
  static (double, double) _getThresholds(int detailLevel) {
    switch (detailLevel.clamp(0, 2)) {
      case 0:
        return (80.0, 160.0); // Düşük detay - sadece ana çizgiler
      case 1:
        return (50.0, 120.0); // Orta detay
      case 2:
        return (30.0, 80.0); // Yüksek detay - ince çizgiler
      default:
        return (50.0, 120.0);
    }
  }

  /// Resmi max boyuta küçült
  static cv.Mat _resizeIfNeeded(cv.Mat mat, int maxSize) {
    if (mat.rows <= maxSize && mat.cols <= maxSize) return mat;

    final scale = maxSize / (mat.rows > mat.cols ? mat.rows : mat.cols);
    final newWidth = (mat.cols * scale).round();
    final newHeight = (mat.rows * scale).round();

    return cv.resize(mat, (newWidth, newHeight));
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
        // Manzara: Orta detay, orta çizgi, orta yumuşatma
        return (detailLevel: 1, smoothness: 1, lineThickness: 2);
      case ImagePreset.detailed:
        // Detaylı: Yüksek detay, ince çizgi, az yumuşatma
        return (detailLevel: 2, smoothness: 0, lineThickness: 2);
      case ImagePreset.cartoon:
        // Karikatür: Düşük detay, kalın çizgi, çok yumuşatma
        return (detailLevel: 0, smoothness: 2, lineThickness: 4);
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
