import 'dart:ui';

/// Çizgi yumuşatma algoritmaları
class LineSmoother {
  /// Catmull-Rom spline ile noktaları yumuşat
  /// [points] - Ham dokunma noktaları
  /// [segments] - Her iki nokta arası segment sayısı (daha yüksek = daha pürüzsüz)
  static List<Offset> smooth(List<Offset> points, {int segments = 8}) {
    if (points.length < 4) {
      // Yetersiz nokta varsa orijinali döndür
      return points;
    }

    final result = <Offset>[];

    // İlk noktayı ekle
    result.add(points.first);

    // Catmull-Rom için her 4 noktayı kullan
    for (int i = 0; i < points.length - 1; i++) {
      // Kontrol noktalarını belirle
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      // Ara noktaları hesapla
      for (int j = 1; j <= segments; j++) {
        final t = j / segments;
        result.add(_catmullRom(p0, p1, p2, p3, t));
      }
    }

    return result;
  }

  /// Catmull-Rom interpolasyonu
  static Offset _catmullRom(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t,
  ) {
    final t2 = t * t;
    final t3 = t2 * t;

    // Catmull-Rom matrix çarpımı
    final x = 0.5 *
        ((2 * p1.dx) +
            (-p0.dx + p2.dx) * t +
            (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
            (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3);

    final y = 0.5 *
        ((2 * p1.dy) +
            (-p0.dy + p2.dy) * t +
            (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
            (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3);

    return Offset(x, y);
  }

  /// Çok yakın noktaları filtrele (point decimation)
  /// [minDistance] - Minimum mesafe (piksel)
  static List<Offset> decimate(List<Offset> points, {double minDistance = 2.0}) {
    if (points.length < 2) return points;

    final result = <Offset>[points.first];

    for (int i = 1; i < points.length; i++) {
      final lastPoint = result.last;
      final currentPoint = points[i];

      if ((currentPoint - lastPoint).distance >= minDistance) {
        result.add(currentPoint);
      }
    }

    // Son noktayı ekle (eğer eklenmemişse)
    if (result.last != points.last) {
      result.add(points.last);
    }

    return result;
  }

  /// Moving average ile yumuşatma (daha basit ama hızlı)
  static List<Offset> movingAverage(List<Offset> points, {int windowSize = 3}) {
    if (points.length < windowSize) return points;

    final result = <Offset>[];
    final halfWindow = windowSize ~/ 2;

    for (int i = 0; i < points.length; i++) {
      double sumX = 0;
      double sumY = 0;
      int count = 0;

      for (int j = -halfWindow; j <= halfWindow; j++) {
        final index = i + j;
        if (index >= 0 && index < points.length) {
          sumX += points[index].dx;
          sumY += points[index].dy;
          count++;
        }
      }

      result.add(Offset(sumX / count, sumY / count));
    }

    return result;
  }
}

/// Çizilen çizgi verisi
class DrawnLine {
  final List<Offset> points;
  final double strokeWidth;
  final Color color;
  final bool isEraser;

  DrawnLine({
    required this.points,
    required this.strokeWidth,
    required this.color,
    this.isEraser = false,
  });

  /// Yumuşatılmış çizgi oluştur
  DrawnLine smoothed({int segments = 8}) {
    return DrawnLine(
      points: LineSmoother.smooth(points, segments: segments),
      strokeWidth: strokeWidth,
      color: color,
      isEraser: isEraser,
    );
  }

  /// Kopyala
  DrawnLine copyWith({
    List<Offset>? points,
    double? strokeWidth,
    Color? color,
    bool? isEraser,
  }) {
    return DrawnLine(
      points: points ?? this.points,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      color: color ?? this.color,
      isEraser: isEraser ?? this.isEraser,
    );
  }
}

/// Çizim aracı türleri
enum DrawingTool {
  pen,
  eraser,
}
