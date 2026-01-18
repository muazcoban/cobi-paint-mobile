import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/line_smoothing.dart';

/// Çizim canvas widget'ı
/// Arka plan resmi üzerine çizgi çizmeyi sağlar
class DrawingCanvas extends StatefulWidget {
  final Uint8List backgroundImage;
  final Function(List<DrawnLine>)? onLinesChanged;
  final DrawingTool currentTool;
  final double strokeWidth;
  final Color strokeColor;

  const DrawingCanvas({
    super.key,
    required this.backgroundImage,
    this.onLinesChanged,
    this.currentTool = DrawingTool.pen,
    this.strokeWidth = 3.0,
    this.strokeColor = Colors.black,
  });

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawnLine> _lines = [];
  final List<DrawnLine> _undoStack = [];
  List<Offset> _currentPoints = [];
  ui.Image? _backgroundImageDecoded;
  Size? _imageSize;

  // Transform değerleri
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Size _lastCanvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  @override
  void didUpdateWidget(DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundImage != widget.backgroundImage) {
      _loadBackgroundImage();
    }
  }

  Future<void> _loadBackgroundImage() async {
    final codec = await ui.instantiateImageCodec(widget.backgroundImage);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _backgroundImageDecoded = frame.image;
        _imageSize = Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
      });
    }
  }

  /// Transform değerlerini hesapla
  void _calculateTransform(Size canvasSize) {
    if (_imageSize == null) return;
    if (_lastCanvasSize == canvasSize) return;

    _lastCanvasSize = canvasSize;

    final scaleX = canvasSize.width / _imageSize!.width;
    final scaleY = canvasSize.height / _imageSize!.height;
    _scale = scaleX < scaleY ? scaleX : scaleY;

    final scaledWidth = _imageSize!.width * _scale;
    final scaledHeight = _imageSize!.height * _scale;
    _offset = Offset(
      (canvasSize.width - scaledWidth) / 2,
      (canvasSize.height - scaledHeight) / 2,
    );
  }

  /// Ekran koordinatlarını resim koordinatlarına dönüştür
  Offset _toImageCoords(Offset screenPoint) {
    return Offset(
      (screenPoint.dx - _offset.dx) / _scale,
      (screenPoint.dy - _offset.dy) / _scale,
    );
  }

  void _onPanStart(DragStartDetails details) {
    final imagePoint = _toImageCoords(details.localPosition);
    setState(() {
      _currentPoints = [imagePoint];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final imagePoint = _toImageCoords(details.localPosition);

    // Point decimation - çok yakın noktaları atla
    if (_currentPoints.isEmpty ||
        (imagePoint - _currentPoints.last).distance > 2.0) {
      setState(() {
        _currentPoints = [..._currentPoints, imagePoint];
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPoints.length < 2) {
      setState(() {
        _currentPoints = [];
      });
      return;
    }

    // Basit smoothing
    final smoothedPoints = _currentPoints.length > 4
        ? LineSmoother.smooth(_currentPoints, segments: 3)
        : List<Offset>.from(_currentPoints);

    final line = DrawnLine(
      points: smoothedPoints,
      strokeWidth: widget.strokeWidth,
      color: widget.currentTool == DrawingTool.eraser
          ? Colors.white
          : widget.strokeColor,
      isEraser: widget.currentTool == DrawingTool.eraser,
    );

    setState(() {
      _lines.add(line);
      _currentPoints = [];
      _undoStack.clear();
    });

    widget.onLinesChanged?.call(_lines);
  }

  void undo() {
    if (_lines.isEmpty) return;
    setState(() {
      _undoStack.add(_lines.removeLast());
    });
    widget.onLinesChanged?.call(_lines);
  }

  void redo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _lines.add(_undoStack.removeLast());
    });
    widget.onLinesChanged?.call(_lines);
  }

  void clear() {
    setState(() {
      _undoStack.addAll(_lines);
      _lines.clear();
    });
    widget.onLinesChanged?.call(_lines);
  }

  bool get canUndo => _lines.isNotEmpty;
  bool get canRedo => _undoStack.isNotEmpty;
  List<DrawnLine> get lines => List.unmodifiable(_lines);

  Future<Uint8List> renderToImage() async {
    if (_backgroundImageDecoded == null || _imageSize == null) {
      throw Exception('Background image not loaded');
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Arka plan resmini çiz
    canvas.drawImage(_backgroundImageDecoded!, Offset.zero, Paint());

    // Çizilen çizgileri çiz
    for (final line in _lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      if (line.points.length > 1) {
        final path = Path();
        path.moveTo(line.points.first.dx, line.points.first.dy);
        for (int i = 1; i < line.points.length; i++) {
          path.lineTo(line.points[i].dx, line.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      _imageSize!.width.toInt(),
      _imageSize!.height.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        _calculateTransform(canvasSize);

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          behavior: HitTestBehavior.opaque,
          child: CustomPaint(
            painter: _DrawingPainter(
              backgroundImage: _backgroundImageDecoded,
              scale: _scale,
              offset: _offset,
              lines: _lines,
              currentPoints: _currentPoints,
              currentStrokeWidth: widget.strokeWidth,
              currentColor: widget.currentTool == DrawingTool.eraser
                  ? Colors.white
                  : widget.strokeColor,
            ),
            size: canvasSize,
          ),
        );
      },
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final ui.Image? backgroundImage;
  final double scale;
  final Offset offset;
  final List<DrawnLine> lines;
  final List<Offset> currentPoints;
  final double currentStrokeWidth;
  final Color currentColor;

  _DrawingPainter({
    required this.backgroundImage,
    required this.scale,
    required this.offset,
    required this.lines,
    required this.currentPoints,
    required this.currentStrokeWidth,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage == null) return;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    // Arka plan
    canvas.drawImage(backgroundImage!, Offset.zero, Paint());

    // Tamamlanmış çizgiler
    for (final line in lines) {
      _drawPath(canvas, line.points, line.strokeWidth, line.color);
    }

    // Aktif çizgi
    if (currentPoints.length >= 2) {
      _drawPath(canvas, currentPoints, currentStrokeWidth, currentColor);
    }

    canvas.restore();
  }

  void _drawPath(Canvas canvas, List<Offset> points, double strokeWidth, Color color) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.currentPoints.length != currentPoints.length ||
        oldDelegate.lines.length != lines.length ||
        oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.scale != scale;
  }
}
