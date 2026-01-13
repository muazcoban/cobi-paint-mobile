import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:collection';

/// Drawing tool types
enum DrawingTool {
  fill,    // Flood fill (default)
  pencil,  // Free draw
  eraser,  // Erase colored pixels
}

class ColoringProvider extends ChangeNotifier {
  // Current color
  Color _selectedColor = Colors.red;

  // History for undo/redo (stores both colored pixels and manual edges)
  final List<_HistoryState> _history = [];
  int _historyIndex = -1;

  // Current colored regions (pixel position -> color)
  Map<int, Color> _coloredPixels = {};

  // Original image data
  Uint8List? _originalImageData;
  img.Image? _originalImage;

  // Processed image for display
  Uint8List? _processedImageData;

  // Zoom and pan
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  // Image dimensions
  int _imageWidth = 0;
  int _imageHeight = 0;

  // Grayscale cache for performance
  Uint8List? _grayscaleCache;

  // Gradient cache for anti-aliased edge detection
  Uint8List? _gradientCache;

  // Edge threshold for flood fill (lower = more sensitive to edges)
  int _edgeThreshold = 30;

  // Gradient threshold for anti-aliased edges
  int _gradientThreshold = 25;

  // Hash for colored pixels to track changes efficiently
  int _coloredPixelsVersion = 0;

  // Drawing tool state
  DrawingTool _currentTool = DrawingTool.fill;
  double _brushSize = 3.0;

  // Manually drawn edge pixels (tracked separately for undo support)
  Set<int> _manualEdges = {};

  // Getters
  Color get selectedColor => _selectedColor;
  Uint8List? get originalImageData => _originalImageData;
  Uint8List? get processedImageData => _processedImageData;
  Map<int, Color> get coloredPixels => _coloredPixels;
  double get scale => _scale;
  Offset get offset => _offset;
  int get imageWidth => _imageWidth;
  int get imageHeight => _imageHeight;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  int get edgeThreshold => _edgeThreshold;
  int get gradientThreshold => _gradientThreshold;
  int get coloredPixelsVersion => _coloredPixelsVersion;
  DrawingTool get currentTool => _currentTool;
  double get brushSize => _brushSize;

  void setEdgeThreshold(int value) {
    _edgeThreshold = value.clamp(10, 100);
    notifyListeners();
  }

  void setGradientThreshold(int value) {
    _gradientThreshold = value.clamp(10, 100);
    notifyListeners();
  }

  void setCurrentTool(DrawingTool tool) {
    _currentTool = tool;
    notifyListeners();
  }

  void setBrushSize(double size) {
    _brushSize = size.clamp(0.5, 30.0);
    notifyListeners();
  }

  /// Calculate proper grayscale using luminance formula
  int _getGrayValue(img.Pixel pixel) {
    return ((pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114)).round();
  }

  /// Build grayscale cache for faster flood fill
  void _buildGrayscaleCache() {
    if (_originalImage == null) return;
    _grayscaleCache = Uint8List(_imageWidth * _imageHeight);
    for (int y = 0; y < _imageHeight; y++) {
      for (int x = 0; x < _imageWidth; x++) {
        final pixel = _originalImage!.getPixel(x, y);
        _grayscaleCache![y * _imageWidth + x] = _getGrayValue(pixel);
      }
    }
  }

  /// Build gradient cache using Sobel operator for anti-aliased edge detection
  void _buildGradientCache() {
    if (_grayscaleCache == null) return;
    _gradientCache = Uint8List(_imageWidth * _imageHeight);

    // Sobel kernels
    const sobelX = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]];
    const sobelY = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]];

    for (int y = 1; y < _imageHeight - 1; y++) {
      for (int x = 1; x < _imageWidth - 1; x++) {
        double gx = 0;
        double gy = 0;

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final gray = _grayscaleCache![(y + ky) * _imageWidth + (x + kx)];
            gx += gray * sobelX[ky + 1][kx + 1];
            gy += gray * sobelY[ky + 1][kx + 1];
          }
        }

        final magnitude = math.sqrt(gx * gx + gy * gy).clamp(0, 255).toInt();
        _gradientCache![y * _imageWidth + x] = magnitude;
      }
    }
  }

  /// Get cached grayscale value
  int _getCachedGray(int x, int y) {
    if (_grayscaleCache == null) return 255;
    return _grayscaleCache![y * _imageWidth + x];
  }

  /// Get cached gradient value
  int _getCachedGradient(int x, int y) {
    if (_gradientCache == null) return 0;
    return _gradientCache![y * _imageWidth + x];
  }

  /// Check if a pixel is an edge (using both gray and gradient + manual edges)
  bool _isEdgePixel(int x, int y) {
    final index = y * _imageWidth + x;

    // Check manual edges first (drawn by user)
    if (_manualEdges.contains(index)) return true;

    final gray = _getCachedGray(x, y);
    final gradient = _getCachedGradient(x, y);

    // Pixel is an edge if: gray is dark enough OR gradient is high enough
    return gray < _edgeThreshold || gradient > _gradientThreshold;
  }

  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Future<void> loadImage(Uint8List imageData) async {
    _originalImageData = imageData;
    _originalImage = img.decodeImage(imageData);

    if (_originalImage != null) {
      _imageWidth = _originalImage!.width;
      _imageHeight = _originalImage!.height;

      // Build grayscale cache for faster flood fill
      _buildGrayscaleCache();

      // Build gradient cache for anti-aliased edge detection
      _buildGradientCache();

      // Auto-detect optimal threshold using Otsu's method
      _autoDetectThresholdOtsu();
    }

    // Reset state
    _coloredPixels = {};
    _manualEdges = {};
    _coloredPixelsVersion = 0;
    _history.clear();
    _historyIndex = -1;
    _scale = 1.0;
    _offset = Offset.zero;

    // Save initial state
    _saveState();

    notifyListeners();
  }

  /// Auto-detect optimal edge threshold using Otsu's method
  /// This finds the optimal threshold that maximizes between-class variance
  void _autoDetectThresholdOtsu() {
    if (_grayscaleCache == null) return;

    // Build histogram
    final histogram = List<int>.filled(256, 0);
    for (final gray in _grayscaleCache!) {
      histogram[gray]++;
    }

    final totalPixels = _grayscaleCache!.length;
    double sumAll = 0;
    for (int i = 0; i < 256; i++) {
      sumAll += i * histogram[i];
    }

    double sumBackground = 0;
    int weightBackground = 0;
    double maxVariance = 0;
    int bestThreshold = 30;

    for (int t = 0; t < 256; t++) {
      weightBackground += histogram[t];
      if (weightBackground == 0) continue;

      final weightForeground = totalPixels - weightBackground;
      if (weightForeground == 0) break;

      sumBackground += t * histogram[t];

      final meanBackground = sumBackground / weightBackground;
      final meanForeground = (sumAll - sumBackground) / weightForeground;

      final variance = weightBackground *
          weightForeground *
          (meanBackground - meanForeground) *
          (meanBackground - meanForeground);

      if (variance > maxVariance) {
        maxVariance = variance;
        bestThreshold = t;
      }
    }

    // Apply the Otsu threshold with some adjustments for coloring pages
    // Coloring pages typically have strong black lines, so we want to be on the lower side
    _edgeThreshold = (bestThreshold * 0.6).clamp(20, 80).toInt();

    // Also auto-detect gradient threshold based on gradient distribution
    _autoDetectGradientThreshold();
  }

  /// Auto-detect gradient threshold for anti-aliased edge detection
  void _autoDetectGradientThreshold() {
    if (_gradientCache == null) return;

    // Build gradient histogram
    final histogram = List<int>.filled(256, 0);
    for (final grad in _gradientCache!) {
      histogram[grad]++;
    }

    // Find the 95th percentile of gradient values as threshold
    // This means only the top 5% steepest gradients are considered edges
    final totalPixels = _gradientCache!.length;
    final targetCount = (totalPixels * 0.95).toInt();

    int cumulative = 0;
    for (int i = 0; i < 256; i++) {
      cumulative += histogram[i];
      if (cumulative >= targetCount) {
        _gradientThreshold = i.clamp(15, 80);
        break;
      }
    }
  }

  void loadExistingArtwork(Map<String, int> coloredRegions) {
    _coloredPixels = {};
    for (final entry in coloredRegions.entries) {
      final index = int.tryParse(entry.key);
      if (index != null) {
        _coloredPixels[index] = Color(entry.value);
      }
    }

    // Reset history
    _history.clear();
    _historyIndex = -1;
    _saveState();

    notifyListeners();
  }

  /// Flood fill algorithm to fill connected area
  /// Uses 8-connectivity and hybrid edge detection (gray + gradient)
  /// Returns the number of pixels filled (0 if none)
  int fillArea(int x, int y) {
    if (_originalImage == null || _grayscaleCache == null) return 0;
    if (x < 0 || x >= _imageWidth || y < 0 || y >= _imageHeight) return 0;

    // Don't fill if starting on an edge pixel
    if (_isEdgePixel(x, y)) return 0;

    // Get target color at this position (if already colored)
    final startIndex = y * _imageWidth + x;
    final existingColor = _coloredPixels[startIndex];

    // If already same color, skip
    if (existingColor == _selectedColor) return 0;

    // Flood fill using queue with 8-connectivity
    final queue = Queue<int>(); // Store indices directly for speed
    final visited = Uint8List(_imageWidth * _imageHeight); // Faster than Set
    final toFill = <int>[];

    queue.add(startIndex);
    visited[startIndex] = 1;

    // 8-connectivity offsets: right, left, down, up, and 4 diagonals
    final dx = [1, -1, 0, 0, 1, -1, 1, -1];
    final dy = [0, 0, 1, -1, 1, -1, -1, 1];

    while (queue.isNotEmpty) {
      final index = queue.removeFirst();
      final px = index % _imageWidth;
      final py = index ~/ _imageWidth;

      // Check if this is a fillable area using hybrid edge detection
      if (!_isEdgePixel(px, py)) {
        // Not an edge pixel
        final currentColor = _coloredPixels[index];

        // If we're replacing color, check if it matches start
        if (existingColor != null) {
          if (currentColor != existingColor) continue;
        } else {
          // If start had no color, only fill uncolored areas
          if (currentColor != null && currentColor != existingColor) continue;
        }

        toFill.add(index);

        // Add 8 neighbors (including diagonals)
        for (int i = 0; i < 8; i++) {
          final nx = px + dx[i];
          final ny = py + dy[i];

          if (nx >= 0 && nx < _imageWidth && ny >= 0 && ny < _imageHeight) {
            final neighborIndex = ny * _imageWidth + nx;
            if (visited[neighborIndex] == 0) {
              visited[neighborIndex] = 1;
              queue.add(neighborIndex);
            }
          }
        }
      }
    }

    // Apply fill
    for (final index in toFill) {
      _coloredPixels[index] = _selectedColor;
    }

    // Increment version for efficient repaint detection
    _coloredPixelsVersion++;

    // Save to history
    _saveState();

    notifyListeners();

    // Return number of pixels filled
    return toFill.length;
  }

  void _saveState() {
    // Remove any redo states
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    // Add current state (both colored pixels and manual edges)
    _history.add(_HistoryState(
      coloredPixels: Map<int, Color>.from(_coloredPixels),
      manualEdges: Set<int>.from(_manualEdges),
    ));
    _historyIndex = _history.length - 1;

    // Limit history size
    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void undo() {
    if (!canUndo) return;

    _historyIndex--;
    final state = _history[_historyIndex];
    _coloredPixels = Map<int, Color>.from(state.coloredPixels);
    _manualEdges = Set<int>.from(state.manualEdges);
    _coloredPixelsVersion++;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;

    _historyIndex++;
    final state = _history[_historyIndex];
    _coloredPixels = Map<int, Color>.from(state.coloredPixels);
    _manualEdges = Set<int>.from(state.manualEdges);
    _coloredPixelsVersion++;
    notifyListeners();
  }

  void setScale(double newScale) {
    _scale = newScale.clamp(0.5, 10.0);
    notifyListeners();
  }

  void setOffset(Offset newOffset) {
    _offset = newOffset;
    notifyListeners();
  }

  void resetView() {
    _scale = 1.0;
    _offset = Offset.zero;
    notifyListeners();
  }

  /// Zoom in by a fixed step (for button control)
  void zoomIn() {
    final newScale = (_scale * 1.5).clamp(0.5, 5.0);
    _scale = newScale;
    notifyListeners();
  }

  /// Zoom out by a fixed step (for button control)
  void zoomOut() {
    final newScale = (_scale / 1.5).clamp(0.5, 5.0);
    _scale = newScale;
    // If zooming back to near 1.0, reset offset too
    if (_scale < 1.1) {
      _offset = Offset.zero;
    }
    notifyListeners();
  }

  void clearAll() {
    _coloredPixels.clear();
    _manualEdges.clear();
    _coloredPixelsVersion++;
    _saveState();
    notifyListeners();
  }

  /// Draw a stroke with the given color and brush size
  /// If color is black, it also updates the grayscale cache to create new edges
  void drawStroke(List<Offset> points, Color color, double size) {
    if (points.length < 2) return;

    final radius = (size / 2).ceil();
    final isBlack = color.red < 50 && color.green < 50 && color.blue < 50;

    for (int i = 0; i < points.length - 1; i++) {
      _drawLineBresenham(
        points[i].dx.toInt(),
        points[i].dy.toInt(),
        points[i + 1].dx.toInt(),
        points[i + 1].dy.toInt(),
        color,
        radius,
        isBlack,
      );
    }

    _coloredPixelsVersion++;
    _saveState();
    notifyListeners();
  }

  /// Draw a line using Bresenham's algorithm with brush thickness
  void _drawLineBresenham(int x0, int y0, int x1, int y1, Color color, int radius, bool updateEdge) {
    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;
    var err = dx - dy;

    while (true) {
      // Draw circle at current position
      _drawCircle(x0, y0, radius, color, updateEdge);

      if (x0 == x1 && y0 == y1) break;

      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }
  }

  /// Draw a filled circle at the given position
  void _drawCircle(int cx, int cy, int radius, Color color, bool updateEdge) {
    for (int dy = -radius; dy <= radius; dy++) {
      for (int dx = -radius; dx <= radius; dx++) {
        if (dx * dx + dy * dy <= radius * radius) {
          final x = cx + dx;
          final y = cy + dy;

          if (x >= 0 && x < _imageWidth && y >= 0 && y < _imageHeight) {
            final index = y * _imageWidth + x;
            _coloredPixels[index] = color;

            // If drawing black, add to manual edges (supports undo)
            if (updateEdge) {
              _manualEdges.add(index);
            }
          }
        }
      }
    }
  }

  /// Erase colored pixels in the given stroke area
  void erase(List<Offset> points, double size) {
    if (points.isEmpty) return;

    final radius = (size / 2).ceil();

    for (final point in points) {
      final cx = point.dx.toInt();
      final cy = point.dy.toInt();

      for (int dy = -radius; dy <= radius; dy++) {
        for (int dx = -radius; dx <= radius; dx++) {
          if (dx * dx + dy * dy <= radius * radius) {
            final x = cx + dx;
            final y = cy + dy;

            if (x >= 0 && x < _imageWidth && y >= 0 && y < _imageHeight) {
              final index = y * _imageWidth + x;
              _coloredPixels.remove(index);
            }
          }
        }
      }
    }

    _coloredPixelsVersion++;
    _saveState();
    notifyListeners();
  }

  /// Generate the final colored image
  Future<Uint8List> generateColoredImage() async {
    if (_originalImage == null) {
      throw Exception('No image loaded');
    }

    // Create a copy of the original image
    final result = img.Image.from(_originalImage!);

    // Apply colors
    for (final entry in _coloredPixels.entries) {
      final index = entry.key;
      final color = entry.value;

      final x = index % _imageWidth;
      final y = index ~/ _imageWidth;

      if (x >= 0 && x < _imageWidth && y >= 0 && y < _imageHeight) {
        result.setPixel(
          x,
          y,
          img.ColorRgba8(color.red, color.green, color.blue, 255),
        );
      }
    }

    return Uint8List.fromList(img.encodePng(result));
  }

  /// Get colored regions as map for saving
  Map<String, int> getColoredRegionsMap() {
    final map = <String, int>{};
    for (final entry in _coloredPixels.entries) {
      map[entry.key.toString()] = entry.value.value;
    }
    return map;
  }

  void reset() {
    _coloredPixels.clear();
    _manualEdges.clear();
    _history.clear();
    _historyIndex = -1;
    _scale = 1.0;
    _offset = Offset.zero;
    _originalImageData = null;
    _originalImage = null;
    _grayscaleCache = null;
    _gradientCache = null;
    _coloredPixelsVersion = 0;
    notifyListeners();
  }
}

/// History state for undo/redo support
class _HistoryState {
  final Map<int, Color> coloredPixels;
  final Set<int> manualEdges;

  _HistoryState({
    required this.coloredPixels,
    required this.manualEdges,
  });
}
