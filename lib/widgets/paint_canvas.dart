import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/document/coloring_document.dart';
import '../engine/document/stroke.dart';
import '../engine/input/canvas_gestures.dart';
import '../engine/render/page_layers.dart';
import '../engine/render/symmetry.dart';
import 'motion.dart';

export '../engine/input/canvas_gestures.dart' show CanvasTool;

/// The coloring surface: region fills, brush strokes and the line art on
/// top, driven by [CanvasGestureMachine].
class PaintCanvas extends StatefulWidget {
  const PaintCanvas({
    super.key,
    required this.document,
    required this.page,
    required this.tool,
    required this.color,
    required this.brushSize,
    this.brush = BrushKind.marker,
    this.stayInside = true,
    this.eraseFills = true,
    this.symmetry = 1,
    this.allowZoom = false,
    this.paperColor = Colors.white,
    this.onFilled,
    this.onStrokeCommitted,
  });

  final ColoringDocument document;

  /// The line art, same size as [document]'s label map.
  final ui.Image page;
  final CanvasTool tool;
  final Color color;

  /// Brush diameter in page pixels.
  final double brushSize;

  /// The brush used while [tool] is [CanvasTool.marker].
  final BrushKind brush;

  /// Marker strokes stay inside the region they started in.
  final bool stayInside;

  /// Whether the eraser also clears the fill of the regions it crosses.
  final bool eraseFills;

  /// Mirror copies of every stroke, the eraser included (see
  /// [symmetryWays]): the free drawing page's mirror. Fills ignore it.
  final int symmetry;
  final bool allowZoom;
  final Color paperColor;

  /// A region was filled from a tap; good moment for sound and haptics.
  final void Function(int label)? onFilled;
  final void Function(BrushKind kind)? onStrokeCommitted;

  @override
  State<PaintCanvas> createState() => _PaintCanvasState();
}

/// The tool pictures drawn under the finger while it paints, decoded once
/// for the whole app.
final Map<BrushKind, ui.Image> _toolImages = {};
Future<void>? _toolImagesLoading;

Future<void> _loadToolImages() => _toolImagesLoading ??= () async {
  for (final entry in {
    BrushKind.marker: 'paintbrush',
    BrushKind.rainbow: 'paintbrush',
    BrushKind.crayon: 'crayon',
  }.entries) {
    try {
      final data = await rootBundle.load('assets/images/tools/${entry.value}.png');
      _toolImages[entry.key] = await decodeImageFromList(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('Tool picture missing: $e');
    }
  }
}();

class _PaintCanvasState extends State<PaintCanvas> with SingleTickerProviderStateMixin {
  late PageLayers _layers;
  late CanvasGestureMachine _gestures;
  late final AnimationController _reveal;
  final _repaint = ValueNotifier<int>(0);

  // View: screen = _pan + page * _scale (in widget coordinates).
  Size _viewport = Size.zero;
  double _fitScale = 1;
  Offset _fitOffset = Offset.zero;
  double _zoom = 1;
  Offset _pan = Offset.zero;
  double _transformStartZoom = 1;
  Offset _transformStartPan = Offset.zero;
  Offset _transformStartFocal = Offset.zero;

  // Fill reveal animation.
  ui.Image? _revealFrom;
  Offset _revealOrigin = Offset.zero;
  double _revealRadius = 0;
  bool _revealPending = false;

  // Live stroke in page coordinates.
  final List<double> _live = [];
  BrushKind? _liveKind;
  int _liveClip = 0;

  static const double maxZoom = 6;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))..addListener(_bump);
    unawaited(_loadToolImages().then((_) => mounted ? _bump() : null));
    _reveal.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _revealFrom?.dispose();
        _revealFrom = null;
        _bump();
      }
    });
    _gestures = CanvasGestureMachine(
      callbacks: CanvasGestureCallbacks(
        onFill: _fill,
        onStrokeStart: _strokeStart,
        onStrokeUpdate: _strokeUpdate,
        onStrokeEnd: _strokeEnd,
        onStrokeCancel: _strokeCancel,
        onTransformStart: _transformStart,
        onTransformUpdate: _transformUpdate,
        onTransformEnd: () {},
      ),
      tool: widget.tool,
      allowTransform: widget.allowZoom,
    );
    _attach(widget.document);
  }

  @override
  void didUpdateWidget(PaintCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    _gestures
      ..tool = widget.tool
      ..allowTransform = widget.allowZoom;
    if (!widget.allowZoom && (_zoom != 1 || _pan != Offset.zero)) {
      _zoom = 1;
      _pan = Offset.zero;
    }
    if (oldWidget.document != widget.document) {
      oldWidget.document.removeListener(_documentChanged);
      _layers.dispose();
      _attach(widget.document);
    }
  }

  void _attach(ColoringDocument document) {
    _layers = PageLayers(document: document);
    document.addListener(_documentChanged);
    unawaited(_syncLayers());
  }

  @override
  void dispose() {
    widget.document.removeListener(_documentChanged);
    _reveal.dispose();
    _revealFrom?.dispose();
    _layers.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _bump() => _repaint.value++;

  void _documentChanged() => unawaited(_syncLayers());

  Future<void> _syncLayers() async {
    final animate = _revealPending;
    _revealPending = false;
    final previous = await _layers.syncFills();
    if (!mounted) {
      previous?.dispose();
      return;
    }
    if (animate && previous != null && !reduceMotion(context)) {
      _revealFrom?.dispose();
      _revealFrom = previous;
      unawaited(_reveal.forward(from: 0));
    } else {
      previous?.dispose();
    }
    _bump();
    await _layers.syncBrush();
    if (mounted) _bump();
  }

  // Coordinates ------------------------------------------------------------

  double get _scale => _fitScale * _zoom;

  Offset get _origin => _fitOffset + _pan;

  Offset _toPage(Offset local) => (local - _origin) / _scale;

  void _layout(Size size) {
    if (size == _viewport) return;
    _viewport = size;
    final map = widget.document.map;
    _fitScale = math.min(size.width / map.width, size.height / map.height);
    _fitOffset = Offset((size.width - map.width * _fitScale) / 2, (size.height - map.height * _fitScale) / 2);
    _pan = _clampPan(_pan, _zoom);
  }

  Offset _clampPan(Offset pan, double zoom) {
    final map = widget.document.map;
    final w = map.width * _fitScale * zoom;
    final h = map.height * _fitScale * zoom;
    double axis(double p, double content, double view, double fit) {
      if (content <= view) return (view - content) / 2 - fit;
      return p.clamp(view - content - fit, -fit);
    }

    return Offset(axis(pan.dx, w, _viewport.width, _fitOffset.dx), axis(pan.dy, h, _viewport.height, _fitOffset.dy));
  }

  // Gesture callbacks ------------------------------------------------------

  void _fill(Offset local) {
    final p = _toPage(local);
    final x = p.dx.floor();
    final y = p.dy.floor();
    final document = widget.document;
    final label = document.map.labelAt(x, y);
    final argb = widget.color.toARGB32();
    if (label == 0 || document.fillOf(label) == argb) return;

    // Set up the reveal before the document notifies the layers.
    final r = document.map.region(label);
    _revealOrigin = p;
    _revealRadius = [
      Offset(r.left.toDouble(), r.top.toDouble()),
      Offset(r.right + 1.0, r.top.toDouble()),
      Offset(r.left.toDouble(), r.bottom + 1.0),
      Offset(r.right + 1.0, r.bottom + 1.0),
    ].map((c) => (c - p).distance).reduce(math.max);
    _revealPending = true;
    document.fillAt(x, y, argb);
    widget.onFilled?.call(label);
  }

  void _strokeStart(Offset local) {
    final p = _toPage(local);
    _live
      ..clear()
      ..addAll([p.dx, p.dy, 0.5]);
    _liveKind = widget.tool == CanvasTool.eraser ? BrushKind.eraser : widget.brush;
    _liveClip = _liveKind != BrushKind.eraser && widget.stayInside
        ? widget.document.map.labelAt(p.dx.floor(), p.dy.floor())
        : 0;
    if (_liveClip > 0) _layers.maskIfReady(_liveClip);
    _bump();
  }

  void _strokeUpdate(Offset local) {
    if (_liveKind == null) return;
    final p = _toPage(local);
    final n = _live.length;
    if ((Offset(_live[n - 3], _live[n - 2]) - p).distance < 0.75) return;
    _live.addAll([p.dx, p.dy, 0.5]);
    _bump();
  }

  void _strokeEnd() {
    final kind = _liveKind;
    if (kind == null) return;
    final stroke = Stroke(
      kind: kind,
      argb: kind == BrushKind.marker ? widget.color.toARGB32() : 0,
      size: widget.brushSize,
      clipLabel: _liveClip,
      symmetry: widget.symmetry,
      points: Float32List.fromList(_live),
    );
    _liveKind = null;
    if (kind == BrushKind.eraser) {
      widget.document.erase(stroke, widget.eraseFills ? _labelsAlong(stroke) : const {});
    } else {
      widget.document.addStroke(stroke);
    }
    widget.onStrokeCommitted?.call(kind);
    _bump();
  }

  void _strokeCancel() {
    _liveKind = null;
    _live.clear();
    _bump();
  }

  /// Regions under an eraser path, sampled every few pixels.
  Set<int> _labelsAlong(Stroke stroke) {
    final map = widget.document.map;
    final labels = <int>{};
    final step = math.max(1.0, stroke.size / 3);
    final pts = stroke.points;
    void sample(double x, double y) => labels.add(map.labelAt(x.floor(), y.floor()));
    sample(pts[0], pts[1]);
    for (var i = 3; i < pts.length; i += 3) {
      final a = Offset(pts[i - 3], pts[i - 2]);
      final b = Offset(pts[i], pts[i + 1]);
      final steps = math.max(1, ((b - a).distance / step).ceil());
      for (var s = 1; s <= steps; s++) {
        final q = Offset.lerp(a, b, s / steps)!;
        sample(q.dx, q.dy);
      }
    }
    labels.remove(0);
    return labels;
  }

  void _transformStart(Offset focal) {
    _transformStartZoom = _zoom;
    _transformStartPan = _pan;
    _transformStartFocal = focal;
  }

  void _transformUpdate(Offset focal, double scale) {
    final zoom = (_transformStartZoom * scale).clamp(1.0, maxZoom);
    // Keep the page point that was under the starting focal point under the
    // current focal point.
    final startScale = _fitScale * _transformStartZoom;
    final pagePoint = (_transformStartFocal - _fitOffset - _transformStartPan) / startScale;
    final pan = focal - _fitOffset - pagePoint * (_fitScale * zoom);
    _zoom = zoom;
    _pan = _clampPan(pan, zoom);
    _bump();
  }

  // Pointer plumbing ---------------------------------------------------------

  void _onPointerDown(PointerDownEvent e) => _gestures.pointerDown(e.pointer, e.localPosition, e.timeStamp);
  void _onPointerMove(PointerMoveEvent e) => _gestures.pointerMove(e.pointer, e.localPosition, e.timeStamp);
  void _onPointerUp(PointerUpEvent e) => _gestures.pointerUp(e.pointer, e.localPosition, e.timeStamp);
  void _onPointerCancel(PointerCancelEvent e) => _gestures.pointerCancel(e.pointer);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _layout(constraints.biggest);
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: RepaintBoundary(
            child: CustomPaint(size: constraints.biggest, painter: _CanvasPainter(this)),
          ),
        );
      },
    );
  }
}

void _drawTool(Canvas canvas, BrushKind kind, Offset tip, double size) {
  if (kind == BrushKind.eraser) {
    // A pink eraser block with a blue band, one corner at the finger.
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(-0.45);
    final body = Rect.fromLTWH(-size * 0.06, -size * 0.4, size * 0.4, size * 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(size * 0.05)),
      Paint()..color = const Color(0xFFF48FB1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(body.left, body.top, body.width, body.height * 0.35),
        Radius.circular(size * 0.05),
      ),
      Paint()..color = const Color(0xFF64B5F6),
    );
    canvas.restore();
    return;
  }
  final image = _toolImages[kind];
  if (image == null) return;
  // Where the tip sits inside each picture, as a fraction of its size.
  final anchor = kind == BrushKind.crayon ? const Offset(0.14, 0.9) : const Offset(0.17, 0.84);
  final dst = Rect.fromLTWH(tip.dx - size * anchor.dx, tip.dy - size * anchor.dy, size, size);
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    dst,
    Paint()..filterQuality = FilterQuality.medium,
  );
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter(this.state) : super(repaint: state._repaint);

  final _PaintCanvasState state;

  @override
  void paint(Canvas canvas, Size size) {
    final layers = state._layers;
    final map = state.widget.document.map;
    final pageRect = Rect.fromLTWH(0, 0, map.width.toDouble(), map.height.toDouble());

    canvas.save();
    canvas.translate(state._origin.dx, state._origin.dy);
    canvas.scale(state._scale);
    canvas.clipRect(pageRect);

    // 1. Paper, and the mirror lines when the mirror is on, so the child
    // sees where the copies come from. Paint covers them; they are not
    // part of the picture.
    canvas.drawRect(pageRect, Paint()..color = state.widget.paperColor);
    final symmetry = state.widget.symmetry;
    if (symmetry > 1) {
      final centre = pageRect.center;
      final guide = Paint()
        ..color = const Color(0x332D3142)
        ..strokeWidth = 2 / state._scale
        ..strokeCap = StrokeCap.round;
      for (final angle in symmetryAxes(symmetry)) {
        final reach = Offset(math.cos(angle), math.sin(angle)) * pageRect.longestSide;
        canvas.drawLine(centre - reach, centre + reach, guide);
      }
    }

    // 2. Region fills, revealed as a growing circle from the tap point.
    final smooth = Paint()..filterQuality = FilterQuality.low;
    final fill = layers.fillImage;
    final from = state._revealFrom;
    if (from != null && fill != null && state._reveal.isAnimating) {
      canvas.drawImage(from, Offset.zero, smooth);
      final t = Curves.easeOutCubic.transform(state._reveal.value);
      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: state._revealOrigin, radius: state._revealRadius * t + 1)),
      );
      canvas.drawImage(fill, Offset.zero, smooth);
      canvas.restore();
    } else if (fill != null) {
      canvas.drawImage(fill, Offset.zero, smooth);
    }

    // 3. Brush layer plus the stroke under the finger.
    final brush = layers.brushImage;
    final liveKind = state._liveKind;
    final pending = layers.pendingStrokes();
    if (brush != null || liveKind != null || pending.isNotEmpty) {
      canvas.saveLayer(pageRect, Paint());
      if (brush != null) canvas.drawImage(brush, Offset.zero, smooth);
      for (final stroke in pending) {
        layers.paintStroke(canvas, stroke);
      }
      if (liveKind != null && state._live.isNotEmpty) {
        layers.paintStroke(
          canvas,
          Stroke(
            kind: liveKind,
            argb: state.widget.color.toARGB32(),
            size: state.widget.brushSize,
            clipLabel: state._liveClip,
            symmetry: symmetry,
            points: Float32List.fromList(state._live),
          ),
        );
      }
      canvas.restore();
    }

    // 4. Line art on top, so fills tuck under the lines.
    canvas.drawImageRect(
      state.widget.page,
      Rect.fromLTWH(0, 0, state.widget.page.width.toDouble(), state.widget.page.height.toDouble()),
      pageRect,
      Paint()
        ..colorFilter = lineArtFilter
        ..filterQuality = FilterQuality.medium,
    );

    // 5. The tool in the child's hand: its tip at the finger, the handle up
    // and to the right, so the picture reads as "I am holding a brush".
    if (liveKind != null && state._live.length >= 3) {
      final n = state._live.length;
      _drawTool(canvas, liveKind, Offset(state._live[n - 3], state._live[n - 2]), map.width * 0.28);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CanvasPainter oldDelegate) => true;
}
