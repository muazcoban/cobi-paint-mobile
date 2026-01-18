import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../providers/coloring_provider.dart';
import '../utils/paint_textures.dart';

class ColoringCanvas extends StatefulWidget {
  final Uint8List imageData;
  final int imageWidth;
  final int imageHeight;
  final Map<int, Color> coloredPixels;
  final int coloredPixelsVersion; // Version for efficient change detection
  final double scale;
  final Offset offset;
  final Function(int x, int y) onTap;
  final Function(double) onScaleChanged;
  final Function(Offset) onOffsetChanged;

  // Drawing tool support
  final DrawingTool currentTool;
  final Color selectedColor;
  final double brushSize;
  final Function(List<Offset>, Color, double)? onDraw;
  final Function(List<Offset>, double)? onErase;

  // Paint texture for visual effect
  final PaintTexture paintTexture;

  const ColoringCanvas({
    super.key,
    required this.imageData,
    required this.imageWidth,
    required this.imageHeight,
    required this.coloredPixels,
    required this.coloredPixelsVersion,
    required this.scale,
    required this.offset,
    required this.onTap,
    required this.onScaleChanged,
    required this.onOffsetChanged,
    this.currentTool = DrawingTool.fill,
    this.selectedColor = Colors.red,
    this.brushSize = 5.0,
    this.onDraw,
    this.onErase,
    this.paintTexture = PaintTexture.none,
  });

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> {
  ui.Image? _image;
  ui.Image? _coloredOverlay; // Bitmap buffer for colored pixels
  ui.Image? _textureImage; // Texture overlay image
  int _lastColoredVersion = -1; // Track last rendered version

  // Gesture state - captured at gesture START, never modified during gesture
  double _gestureStartScale = 1.0;
  Offset _gestureStartOffset = Offset.zero;
  Offset _gestureStartFocalPoint = Offset.zero;

  // For tracking the image point under focal at gesture start (normalized 0-1)
  Offset? _gestureStartImagePoint;

  // Double-tap detection
  DateTime _lastTapTime = DateTime.now();
  Offset _lastTapPosition = Offset.zero;

  // Drawing state - use ValueNotifier for efficient updates
  final ValueNotifier<List<Offset>> _strokeNotifier = ValueNotifier([]);
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ColoringCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageData != widget.imageData) {
      _loadImage();
      _coloredOverlay = null;
      _textureImage = null;
      _lastColoredVersion = -1;
    }
    // Rebuild overlay only when colored pixels actually change
    if (oldWidget.coloredPixelsVersion != widget.coloredPixelsVersion) {
      _buildColoredOverlay();
    }
    // Rebuild texture when texture type changes
    if (oldWidget.paintTexture != widget.paintTexture) {
      _buildTextureImage();
    }
  }

  Future<void> _loadImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageData);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _image = frame.image;
      });
      _buildColoredOverlay();
      _buildTextureImage();
    }
  }

  /// Build texture image based on selected paint texture
  Future<void> _buildTextureImage() async {
    if (widget.paintTexture == PaintTexture.none) {
      if (mounted && _textureImage != null) {
        setState(() {
          _textureImage = null;
        });
      }
      return;
    }

    // Generate texture image
    final textureImage = await TextureGenerator.createTextureImage(
      widget.paintTexture,
      widget.imageWidth,
      widget.imageHeight,
    );

    if (mounted) {
      setState(() {
        _textureImage = textureImage;
      });
    }
  }

  /// Build bitmap buffer for colored pixels - much faster than individual drawRect calls
  Future<void> _buildColoredOverlay() async {
    if (widget.coloredPixels.isEmpty) {
      if (mounted) {
        setState(() {
          _coloredOverlay = null;
          _lastColoredVersion = widget.coloredPixelsVersion;
        });
      }
      return;
    }

    // Create pixel buffer
    final pixels = Uint8List(widget.imageWidth * widget.imageHeight * 4);

    // Fill with transparent
    for (int i = 0; i < pixels.length; i += 4) {
      pixels[i] = 0; // R
      pixels[i + 1] = 0; // G
      pixels[i + 2] = 0; // B
      pixels[i + 3] = 0; // A (transparent)
    }

    // Set colored pixels
    for (final entry in widget.coloredPixels.entries) {
      final index = entry.key;
      final color = entry.value;
      final byteIndex = index * 4;

      if (byteIndex >= 0 && byteIndex + 3 < pixels.length) {
        pixels[byteIndex] = color.red;
        pixels[byteIndex + 1] = color.green;
        pixels[byteIndex + 2] = color.blue;
        pixels[byteIndex + 3] = color.alpha;
      }
    }

    // Decode to ui.Image
    final completer = ui.ImmutableBuffer.fromUint8List(pixels);
    final buffer = await completer;

    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: widget.imageWidth,
      height: widget.imageHeight,
      pixelFormat: ui.PixelFormat.rgba8888,
    );

    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();

    if (mounted) {
      setState(() {
        _coloredOverlay = frame.image;
        _lastColoredVersion = widget.coloredPixelsVersion;
      });
    }

    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
  }

  @override
  void dispose() {
    _coloredOverlay?.dispose();
    _textureImage?.dispose();
    _strokeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDrawingMode = widget.currentTool == DrawingTool.pencil ||
        widget.currentTool == DrawingTool.eraser;

    return GestureDetector(
      onScaleStart: (details) {
        if (isDrawingMode && details.pointerCount == 1) {
          // Start drawing - no setState needed
          final imageCoords = _convertToImageCoords(details.localFocalPoint);
          if (imageCoords != null) {
            _isDrawing = true;
            _strokeNotifier.value = [imageCoords];
          }
          return;
        }
        // Capture state at gesture START - these won't change during the gesture
        _gestureStartScale = widget.scale;
        _gestureStartOffset = widget.offset;
        _gestureStartFocalPoint = details.localFocalPoint;

        // Only calculate image point for pinch zoom (2+ fingers)
        if (details.pointerCount >= 2) {
          _gestureStartImagePoint = _screenToImageNormalized(details.localFocalPoint);
        } else {
          _gestureStartImagePoint = null;
        }
      },
      onScaleUpdate: (details) {
        if (_isDrawing && details.pointerCount == 1) {
          // Continue drawing - efficient update without setState
          final imageCoords = _convertToImageCoords(details.localFocalPoint);
          if (imageCoords != null) {
            _strokeNotifier.value = [..._strokeNotifier.value, imageCoords];
          }
          return;
        }

        // If we were drawing but now have 2 fingers, finish the stroke
        if (_isDrawing && details.pointerCount > 1) {
          _finishStroke();
        }

        final canvasSize = context.size;
        if (canvasSize == null) return;

        // Only handle 2-finger gestures (pinch zoom)
        // In fill mode, single finger is for tapping only (handled by onTapUp)
        if (details.pointerCount >= 2) {
          // If user just added second finger, capture current state as new baseline
          if (_gestureStartImagePoint == null) {
            _gestureStartScale = widget.scale;
            _gestureStartOffset = widget.offset;
            _gestureStartFocalPoint = details.localFocalPoint;
            _gestureStartImagePoint = _screenToImageNormalized(details.localFocalPoint);
          }

          // PINCH ZOOM
          // details.scale is CUMULATIVE from gesture start (starts at 1.0)
          // So newScale = gestureStartScale * details.scale
          final newScale = (_gestureStartScale * details.scale).clamp(0.5, 5.0);

          // Calculate offset to keep the same image point under the current focal point
          final currentFocalPoint = details.localFocalPoint;

          // Calculate offset to keep the image point under the focal point
          Offset newOffset = _calculateOffsetForImagePoint(
            _gestureStartImagePoint!,
            currentFocalPoint,
            newScale,
            canvasSize,
          );

          final boundedOffset = _applyBounds(newOffset, newScale, canvasSize);

          widget.onScaleChanged(newScale);
          widget.onOffsetChanged(boundedOffset);
        } else if (widget.currentTool == DrawingTool.pencil ||
                   widget.currentTool == DrawingTool.eraser) {
          // SINGLE FINGER PAN - only in drawing mode
          // In fill mode, single finger pan is disabled to avoid accidental panning
          final focalPointDelta = details.localFocalPoint - _gestureStartFocalPoint;
          final newOffset = _gestureStartOffset + focalPointDelta;

          final boundedOffset = _applyBounds(newOffset, widget.scale, canvasSize);
          widget.onOffsetChanged(boundedOffset);
        }
        // In fill mode with single finger: do nothing (tap is handled separately)
      },
      onTapUp: (details) {
        // Check for double-tap
        final now = DateTime.now();
        final timeDiff = now.difference(_lastTapTime).inMilliseconds;
        final positionDiff = (details.localPosition - _lastTapPosition).distance;

        if (timeDiff < 300 && positionDiff < 50) {
          // Double-tap detected - toggle zoom
          _handleDoubleTap(details.localPosition);
        } else {
          // Single tap - fill area
          _handleTap(details.localPosition);
        }

        _lastTapTime = now;
        _lastTapPosition = details.localPosition;
      },
      onScaleEnd: (details) {
        if (_isDrawing) {
          _finishStroke();
        }
        // Reset gesture state for next gesture
        _gestureStartImagePoint = null;
      },
      child: Container(
        color: Colors.white,
        child: ClipRect(
          child: _image == null
              ? const Center(child: CircularProgressIndicator())
              : ValueListenableBuilder<List<Offset>>(
                  valueListenable: _strokeNotifier,
                  builder: (context, currentStroke, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _ColoringPainter(
                        image: _image!,
                        coloredOverlay: _coloredOverlay,
                        textureImage: _textureImage,
                        imageWidth: widget.imageWidth,
                        imageHeight: widget.imageHeight,
                        coloredPixelsVersion: _lastColoredVersion,
                        scale: widget.scale,
                        offset: widget.offset,
                        currentStroke: currentStroke,
                        strokeColor: widget.currentTool == DrawingTool.eraser
                            ? Colors.white
                            : widget.selectedColor,
                        brushSize: widget.brushSize,
                        isEraser: widget.currentTool == DrawingTool.eraser,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  /// Apply bounds to offset to keep image partially visible
  Offset _applyBounds(Offset offset, double scale, Size canvasSize) {
    // Calculate image display size
    final imageAspect = widget.imageWidth / widget.imageHeight;
    final canvasAspect = canvasSize.width / canvasSize.height;

    double displayWidth, displayHeight;

    if (imageAspect > canvasAspect) {
      displayWidth = canvasSize.width;
      displayHeight = canvasSize.width / imageAspect;
    } else {
      displayHeight = canvasSize.height;
      displayWidth = canvasSize.height * imageAspect;
    }

    displayWidth *= scale;
    displayHeight *= scale;

    // Calculate center offset
    final centerOffsetX = (canvasSize.width - displayWidth) / 2;
    final centerOffsetY = (canvasSize.height - displayHeight) / 2;

    // Allow dragging but keep at least 20% of image visible
    final minVisibleRatio = 0.2;
    final minVisibleWidth = displayWidth * minVisibleRatio;
    final minVisibleHeight = displayHeight * minVisibleRatio;

    // Calculate bounds
    final minX = -displayWidth + minVisibleWidth + centerOffsetX;
    final maxX = canvasSize.width - minVisibleWidth + centerOffsetX;
    final minY = -displayHeight + minVisibleHeight + centerOffsetY;
    final maxY = canvasSize.height - minVisibleHeight + centerOffsetY;

    return Offset(
      offset.dx.clamp(minX, maxX),
      offset.dy.clamp(minY, maxY),
    );
  }

  /// Get base display dimensions (at scale 1.0)
  (double width, double height, double centerX, double centerY) _getBaseDisplayDimensions(Size canvasSize) {
    final imageAspect = widget.imageWidth / widget.imageHeight;
    final canvasAspect = canvasSize.width / canvasSize.height;

    double displayWidth, displayHeight;
    if (imageAspect > canvasAspect) {
      displayWidth = canvasSize.width;
      displayHeight = canvasSize.width / imageAspect;
    } else {
      displayHeight = canvasSize.height;
      displayWidth = canvasSize.height * imageAspect;
    }

    final centerOffsetX = (canvasSize.width - displayWidth) / 2;
    final centerOffsetY = (canvasSize.height - displayHeight) / 2;

    return (displayWidth, displayHeight, centerOffsetX, centerOffsetY);
  }

  /// Convert screen position to normalized image coordinates (0-1)
  /// Returns null if outside image bounds
  Offset? _screenToImageNormalized(Offset screenPos) {
    final canvasSize = context.size;
    if (canvasSize == null) return null;

    final (baseWidth, baseHeight, _, _) = _getBaseDisplayDimensions(canvasSize);

    // Current display dimensions
    final displayWidth = baseWidth * widget.scale;
    final displayHeight = baseHeight * widget.scale;
    final centerOffsetX = (canvasSize.width - displayWidth) / 2;
    final centerOffsetY = (canvasSize.height - displayHeight) / 2;

    // Calculate normalized position (0-1) on the image
    final imageX = (screenPos.dx - centerOffsetX - widget.offset.dx) / displayWidth;
    final imageY = (screenPos.dy - centerOffsetY - widget.offset.dy) / displayHeight;

    return Offset(imageX, imageY);
  }

  /// Calculate offset needed to place a normalized image point at a specific screen position
  Offset _calculateOffsetForImagePoint(
    Offset imagePoint,  // Normalized 0-1
    Offset screenPos,   // Where it should appear on screen
    double scale,
    Size canvasSize,
  ) {
    final (baseWidth, baseHeight, _, _) = _getBaseDisplayDimensions(canvasSize);

    final displayWidth = baseWidth * scale;
    final displayHeight = baseHeight * scale;
    final centerOffsetX = (canvasSize.width - displayWidth) / 2;
    final centerOffsetY = (canvasSize.height - displayHeight) / 2;

    // Where the image point would be without offset
    final imagePointScreenX = centerOffsetX + imagePoint.dx * displayWidth;
    final imagePointScreenY = centerOffsetY + imagePoint.dy * displayHeight;

    // Offset needed to move it to the target screen position
    return Offset(
      screenPos.dx - imagePointScreenX,
      screenPos.dy - imagePointScreenY,
    );
  }

  /// Handle double-tap to toggle zoom
  void _handleDoubleTap(Offset localPosition) {
    final canvasSize = context.size;
    if (canvasSize == null) return;

    if (widget.scale > 1.5) {
      // Zoom out to 1.0
      widget.onScaleChanged(1.0);
      widget.onOffsetChanged(Offset.zero);
    } else {
      // Zoom in to 3.0 centered on tap position
      const targetScale = 3.0;

      // Calculate image display size at scale 1.0
      final imageAspect = widget.imageWidth / widget.imageHeight;
      final canvasAspect = canvasSize.width / canvasSize.height;

      double displayWidth, displayHeight;
      if (imageAspect > canvasAspect) {
        displayWidth = canvasSize.width;
        displayHeight = canvasSize.width / imageAspect;
      } else {
        displayHeight = canvasSize.height;
        displayWidth = canvasSize.height * imageAspect;
      }

      // Image center offset (where image starts on canvas)
      final centerOffsetX = (canvasSize.width - displayWidth) / 2;
      final centerOffsetY = (canvasSize.height - displayHeight) / 2;

      // Calculate tap position relative to image (0-1 normalized)
      final imageRelX = (localPosition.dx - centerOffsetX) / displayWidth;
      final imageRelY = (localPosition.dy - centerOffsetY) / displayHeight;

      // Clamp to valid image area
      final clampedX = imageRelX.clamp(0.0, 1.0);
      final clampedY = imageRelY.clamp(0.0, 1.0);

      // Calculate zoomed display size
      final zoomedWidth = displayWidth * targetScale;
      final zoomedHeight = displayHeight * targetScale;

      // Calculate new center offset for zoomed image
      final newCenterOffsetX = (canvasSize.width - zoomedWidth) / 2;
      final newCenterOffsetY = (canvasSize.height - zoomedHeight) / 2;

      // Calculate where the tapped point would be after zoom (without offset adjustment)
      final tappedPointZoomedX = newCenterOffsetX + clampedX * zoomedWidth;
      final tappedPointZoomedY = newCenterOffsetY + clampedY * zoomedHeight;

      // Calculate offset to center the tapped point on screen
      final newOffsetX = canvasSize.width / 2 - tappedPointZoomedX;
      final newOffsetY = canvasSize.height / 2 - tappedPointZoomedY;

      final boundedOffset = _applyBounds(
        Offset(newOffsetX, newOffsetY),
        targetScale,
        canvasSize,
      );

      widget.onScaleChanged(targetScale);
      widget.onOffsetChanged(boundedOffset);
    }
  }

  void _handleTap(Offset localPosition) {
    if (_image == null) return;

    // Get canvas size
    final canvasSize = context.size;
    if (canvasSize == null) return;

    // Calculate image display size
    final imageAspect = widget.imageWidth / widget.imageHeight;
    final canvasAspect = canvasSize.width / canvasSize.height;

    double displayWidth, displayHeight;
    double offsetX, offsetY;

    if (imageAspect > canvasAspect) {
      displayWidth = canvasSize.width;
      displayHeight = canvasSize.width / imageAspect;
    } else {
      displayHeight = canvasSize.height;
      displayWidth = canvasSize.height * imageAspect;
    }

    // Apply scale
    displayWidth *= widget.scale;
    displayHeight *= widget.scale;

    // Calculate offset to center
    offsetX = (canvasSize.width - displayWidth) / 2 + widget.offset.dx;
    offsetY = (canvasSize.height - displayHeight) / 2 + widget.offset.dy;

    // Convert tap position to image coordinates using floor() for precision
    final imageX = ((localPosition.dx - offsetX) / displayWidth * widget.imageWidth).floor();
    final imageY = ((localPosition.dy - offsetY) / displayHeight * widget.imageHeight).floor();

    // Check bounds
    if (imageX >= 0 &&
        imageX < widget.imageWidth &&
        imageY >= 0 &&
        imageY < widget.imageHeight) {
      widget.onTap(imageX, imageY);
    }
  }

  /// Convert screen coordinates to image coordinates
  Offset? _convertToImageCoords(Offset localPosition) {
    final canvasSize = context.size;
    if (canvasSize == null) return null;

    // Calculate image display size
    final imageAspect = widget.imageWidth / widget.imageHeight;
    final canvasAspect = canvasSize.width / canvasSize.height;

    double displayWidth, displayHeight;

    if (imageAspect > canvasAspect) {
      displayWidth = canvasSize.width;
      displayHeight = canvasSize.width / imageAspect;
    } else {
      displayHeight = canvasSize.height;
      displayWidth = canvasSize.height * imageAspect;
    }

    // Apply scale
    displayWidth *= widget.scale;
    displayHeight *= widget.scale;

    // Calculate offset to center
    final offsetX = (canvasSize.width - displayWidth) / 2 + widget.offset.dx;
    final offsetY = (canvasSize.height - displayHeight) / 2 + widget.offset.dy;

    // Convert to image coordinates
    final imageX = (localPosition.dx - offsetX) / displayWidth * widget.imageWidth;
    final imageY = (localPosition.dy - offsetY) / displayHeight * widget.imageHeight;

    // Check bounds
    if (imageX >= 0 &&
        imageX < widget.imageWidth &&
        imageY >= 0 &&
        imageY < widget.imageHeight) {
      return Offset(imageX, imageY);
    }
    return null;
  }

  /// Finish the current stroke and send to provider
  void _finishStroke() {
    final stroke = _strokeNotifier.value;
    if (stroke.length >= 2) {
      if (widget.currentTool == DrawingTool.pencil) {
        widget.onDraw?.call(stroke, widget.selectedColor, widget.brushSize);
      } else if (widget.currentTool == DrawingTool.eraser) {
        widget.onErase?.call(stroke, widget.brushSize);
      }
    }
    _isDrawing = false;
    _strokeNotifier.value = [];
  }
}

class _ColoringPainter extends CustomPainter {
  final ui.Image image;
  final ui.Image? coloredOverlay; // Pre-rendered bitmap buffer
  final ui.Image? textureImage; // Texture overlay for paint effect
  final int imageWidth;
  final int imageHeight;
  final int coloredPixelsVersion; // Version for efficient change detection
  final double scale;
  final Offset offset;

  // Stroke preview
  final List<Offset> currentStroke;
  final Color strokeColor;
  final double brushSize;
  final bool isEraser;

  _ColoringPainter({
    required this.image,
    required this.coloredOverlay,
    this.textureImage,
    required this.imageWidth,
    required this.imageHeight,
    required this.coloredPixelsVersion,
    required this.scale,
    required this.offset,
    this.currentStroke = const [],
    this.strokeColor = Colors.red,
    this.brushSize = 5.0,
    this.isEraser = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate display size
    final imageAspect = imageWidth / imageHeight;
    final canvasAspect = size.width / size.height;

    double displayWidth, displayHeight;

    if (imageAspect > canvasAspect) {
      displayWidth = size.width;
      displayHeight = size.width / imageAspect;
    } else {
      displayHeight = size.height;
      displayWidth = size.height * imageAspect;
    }

    // Apply scale
    displayWidth *= scale;
    displayHeight *= scale;

    // Calculate offset to center
    final offsetX = (size.width - displayWidth) / 2 + offset.dx;
    final offsetY = (size.height - displayHeight) / 2 + offset.dy;

    // Draw checkerboard background
    _drawCheckerboard(canvas, Rect.fromLTWH(offsetX, offsetY, displayWidth, displayHeight));

    // Draw original image
    final srcRect = Rect.fromLTWH(0, 0, imageWidth.toDouble(), imageHeight.toDouble());
    final dstRect = Rect.fromLTWH(offsetX, offsetY, displayWidth, displayHeight);

    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    // Draw colored overlay (bitmap buffer - single draw call instead of thousands)
    if (coloredOverlay != null) {
      canvas.drawImageRect(coloredOverlay!, srcRect, dstRect, Paint());

      // Draw texture overlay on top of colored areas (only where colored)
      if (textureImage != null) {
        // Use srcIn blend mode to only show texture where colored overlay exists
        canvas.saveLayer(dstRect, Paint());
        canvas.drawImageRect(coloredOverlay!, srcRect, dstRect, Paint());
        canvas.drawImageRect(
          textureImage!,
          srcRect,
          dstRect,
          Paint()..blendMode = ui.BlendMode.srcATop,
        );
        canvas.restore();
      }
    }

    // Draw current stroke preview
    if (currentStroke.length >= 2) {
      final strokePaint = Paint()
        ..color = isEraser ? Colors.white.withOpacity(0.7) : strokeColor
        ..strokeWidth = brushSize * scale * (displayWidth / imageWidth)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      final firstPoint = _imageToScreen(currentStroke.first, offsetX, offsetY, displayWidth, displayHeight);
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (int i = 1; i < currentStroke.length; i++) {
        final point = _imageToScreen(currentStroke[i], offsetX, offsetY, displayWidth, displayHeight);
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, strokePaint);

      // Draw eraser outline if in eraser mode
      if (isEraser && currentStroke.isNotEmpty) {
        final lastPoint = _imageToScreen(currentStroke.last, offsetX, offsetY, displayWidth, displayHeight);
        final outlinePaint = Paint()
          ..color = Colors.grey
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(
          lastPoint,
          brushSize * scale * (displayWidth / imageWidth) / 2,
          outlinePaint,
        );
      }
    }
  }

  /// Convert image coordinates to screen coordinates
  Offset _imageToScreen(Offset imageCoords, double offsetX, double offsetY, double displayWidth, double displayHeight) {
    return Offset(
      offsetX + imageCoords.dx / imageWidth * displayWidth,
      offsetY + imageCoords.dy / imageHeight * displayHeight,
    );
  }

  void _drawCheckerboard(Canvas canvas, Rect rect) {
    const checkerSize = 10.0;
    final paint1 = Paint()..color = Colors.grey[300]!;
    final paint2 = Paint()..color = Colors.white;

    for (double x = rect.left; x < rect.right; x += checkerSize) {
      for (double y = rect.top; y < rect.bottom; y += checkerSize) {
        final isEven = ((x - rect.left) ~/ checkerSize + (y - rect.top) ~/ checkerSize) % 2 == 0;
        final checkerRect = Rect.fromLTWH(
          x,
          y,
          (x + checkerSize > rect.right) ? rect.right - x : checkerSize,
          (y + checkerSize > rect.bottom) ? rect.bottom - y : checkerSize,
        );
        canvas.drawRect(checkerRect, isEven ? paint1 : paint2);
      }
    }
  }

  @override
  bool shouldRepaint(_ColoringPainter oldDelegate) {
    // Use version comparison instead of Map reference comparison
    return oldDelegate.image != image ||
        oldDelegate.coloredOverlay != coloredOverlay ||
        oldDelegate.textureImage != textureImage ||
        oldDelegate.coloredPixelsVersion != coloredPixelsVersion ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.currentStroke.length != currentStroke.length ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.brushSize != brushSize;
  }
}
