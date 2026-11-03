import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../document/coloring_document.dart';
import '../document/stroke.dart';
import '../region/label_map.dart';
import 'symmetry.dart';

/// Draws black line art with its brightness turned into transparency, so
/// white paper becomes see-through and the fills underneath show.
const ColorFilter lineArtFilter = ColorFilter.matrix(<double>[
  0, 0, 0, 0, 0, //
  0, 0, 0, 0, 0, //
  0, 0, 0, 0, 0, //
  -0.299, -0.587, -0.114, 1, 0,
]);

/// Smooth path through stroke points: quadratic curves through midpoints.
Path strokePath(Float32List points) {
  final path = Path();
  final count = points.length ~/ 3;
  if (count == 0) return path;
  path.moveTo(points[0], points[1]);
  if (count == 1) {
    path.lineTo(points[0], points[1]);
    return path;
  }
  for (var i = 1; i < count - 1; i++) {
    final x = points[i * 3], y = points[i * 3 + 1];
    final nx = points[(i + 1) * 3], ny = points[(i + 1) * 3 + 1];
    path.quadraticBezierTo(x, y, (x + nx) / 2, (y + ny) / 2);
  }
  path.lineTo(points[(count - 1) * 3], points[(count - 1) * 3 + 1]);
  return path;
}

Paint strokePaint(Stroke stroke) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..strokeWidth = stroke.size
  ..isAntiAlias = true
  ..color = stroke.kind == BrushKind.eraser ? const Color(0xFF000000) : Color(stroke.argb)
  ..blendMode = stroke.kind == BrushKind.eraser ? BlendMode.clear : BlendMode.srcOver;

/// Draws [stroke] in its own style. Rainbow and crayon are deterministic:
/// the same stroke looks the same on every device and after every reload.
void drawStroke(Canvas canvas, Stroke stroke) {
  final path = strokePath(stroke.points);
  switch (stroke.kind) {
    case BrushKind.marker:
    case BrushKind.eraser:
      canvas.drawPath(path, strokePaint(stroke));
    case BrushKind.rainbow:
      _drawRainbow(canvas, path, stroke);
    case BrushKind.crayon:
      _drawCrayon(canvas, path, stroke);
  }
}

void _drawRainbow(Canvas canvas, Path path, Stroke stroke) {
  final paint = strokePaint(stroke);
  final step = math.max(3.0, stroke.size * 0.5);
  final cycle = math.max(160.0, stroke.size * 10);
  Color hue(double d) => HSVColor.fromAHSV(1, (d / cycle * 360) % 360, 0.85, 0.95).toColor();
  for (final metric in path.computeMetrics()) {
    if (metric.length < 0.5) {
      canvas.drawPath(path, paint..color = hue(0)); // a tap: one dot
      continue;
    }
    for (var d = 0.0; d < metric.length; d += step) {
      // Segments overlap by a pixel so the seams do not show.
      canvas.drawPath(metric.extractPath(d, math.min(metric.length, d + step + 1)), paint..color = hue(d));
    }
  }
}

void _drawCrayon(Canvas canvas, Path path, Stroke stroke) {
  final color = Color(stroke.argb);
  canvas.drawPath(
    path,
    strokePaint(stroke)
      ..color = color.withValues(alpha: 0.72)
      ..strokeWidth = stroke.size * 0.9,
  );
  // Grainy edges: dots scattered along the path from a seed taken from the
  // stroke itself, so a replayed stroke gets the same grain.
  final pts = stroke.points;
  final random = math.Random(pts.isEmpty ? 1 : (pts[0] * 7919 + pts[1] * 104729 + stroke.size * 31).round());
  final grain = Paint()..color = color.withValues(alpha: 0.35);
  final radius = math.max(1.0, stroke.size * 0.11);
  final spread = stroke.size * 0.5;
  final step = math.max(2.0, stroke.size * 0.22);
  for (final metric in path.computeMetrics()) {
    for (var d = 0.0; d <= metric.length; d += step) {
      final tangent = metric.getTangentForOffset(d);
      if (tangent == null) continue;
      for (var i = 0; i < 2; i++) {
        final off = Offset((random.nextDouble() * 2 - 1) * spread, (random.nextDouble() * 2 - 1) * spread);
        canvas.drawCircle(tangent.position + off, radius, grain);
      }
    }
  }
}

/// The bitmaps behind a coloring page: region fills, committed brush
/// strokes and per-region masks for strokes that stay inside the lines.
/// Images are rebuilt off the paint path and swapped in when ready.
class PageLayers {
  PageLayers({required this.document}) : _fillPixels = Uint8List(document.map.width * document.map.height * 4);

  final ColoringDocument document;
  LabelMap get map => document.map;

  final Uint8List _fillPixels;
  ui.Image? fillImage;
  ui.Image? brushImage;
  final Map<int, ui.Image> _masks = {};
  final Map<int, Future<ui.Image>> _pendingMasks = {};

  bool _disposed = false;
  bool _fillBusy = false;
  bool _fillAgain = false;
  bool _firstFillSync = true;
  int _brushRevisionDone = -1;
  int _bakedCount = 0;
  Stroke? _bakedLast;
  Future<void>? _brushJob;

  Rect regionRect(int label) {
    final r = map.region(label);
    return Rect.fromLTRB(r.left.toDouble(), r.top.toDouble(), r.right + 1.0, r.bottom + 1.0);
  }

  /// Mask of [label] if it is ready; starts building it otherwise.
  ui.Image? maskIfReady(int label) {
    final mask = _masks[label];
    if (mask == null) unawaited(maskFor(label));
    return mask;
  }

  Future<ui.Image> maskFor(int label) {
    final ready = _masks[label];
    if (ready != null) return Future.value(ready);
    return _pendingMasks.putIfAbsent(label, () async {
      final r = map.region(label);
      final w = r.right - r.left + 1;
      final h = r.bottom - r.top + 1;
      final pixels = Uint8List(w * h * 4);
      for (var y = 0; y < h; y++) {
        var src = (r.top + y) * map.width + r.left;
        var dst = y * w * 4;
        for (var x = 0; x < w; x++, src++, dst += 4) {
          if (map.labels[src] == label) {
            pixels[dst + 3] = 255;
          }
        }
      }
      final image = await _imageFromPixels(pixels, w, h);
      unawaited(_pendingMasks.remove(label));
      if (_disposed) {
        image.dispose();
      } else {
        _masks[label] = image;
      }
      return image;
    });
  }

  /// Brings [fillImage] up to date with the document. Returns the image that
  /// was current before, so the caller can animate between the two; the
  /// caller owns and must dispose it.
  Future<ui.Image?> syncFills() async {
    if (_fillBusy) {
      _fillAgain = true;
      return null;
    }
    _fillBusy = true;
    ui.Image? previous;
    try {
      do {
        _fillAgain = false;
        // The first sync paints every region and leaves the document's dirty
        // set alone, so a short-lived second PageLayers (the saver) never
        // steals changes from the canvas.
        final Set<int>? dirty;
        if (_firstFillSync) {
          dirty = null;
        } else {
          dirty = document.takeDirtyLabels();
          if (dirty != null && dirty.isEmpty) break;
        }
        _paintFills(dirty);
        _firstFillSync = false;
        final image = await _imageFromPixels(_fillPixels, map.width, map.height);
        if (_disposed) {
          image.dispose();
          return null;
        }
        previous?.dispose();
        previous = fillImage;
        fillImage = image;
      } while (_fillAgain);
    } finally {
      _fillBusy = false;
    }
    return previous;
  }

  void _paintFills(Set<int>? labels) {
    final px = _fillPixels;
    final lab = map.labels;
    if (labels == null) {
      for (var i = 0, p = 0; i < lab.length; i++, p += 4) {
        _write(px, p, document.fillOf(lab[i]));
      }
      return;
    }
    for (final label in labels) {
      if (label <= 0 || label > map.regionCount) continue;
      final argb = document.fillOf(label);
      final r = map.region(label);
      for (var y = r.top; y <= r.bottom; y++) {
        var i = y * map.width + r.left;
        for (var x = r.left; x <= r.right; x++, i++) {
          if (lab[i] == label) _write(px, i * 4, argb);
        }
      }
    }
  }

  static void _write(Uint8List px, int p, int argb) {
    if (argb == 0) {
      px[p] = px[p + 1] = px[p + 2] = px[p + 3] = 0;
    } else {
      px[p] = (argb >> 16) & 0xFF;
      px[p + 1] = (argb >> 8) & 0xFF;
      px[p + 2] = argb & 0xFF;
      px[p + 3] = (argb >> 24) & 0xFF;
    }
  }

  /// Rasterises committed strokes when they changed. Safe to call often.
  Future<void> syncBrush() {
    return _brushJob ??= _syncBrush().whenComplete(() => _brushJob = null);
  }

  /// Whether the stroke list only grew since the last bake, so the new
  /// strokes can go on top of the baked image.
  bool _grewOnly(List<Stroke> strokes) =>
      _bakedCount <= strokes.length && (_bakedCount == 0 || identical(strokes[_bakedCount - 1], _bakedLast));

  /// Strokes committed to the document but not yet in [brushImage]. The
  /// canvas draws them itself, so a finished stroke never blinks away.
  List<Stroke> pendingStrokes() {
    if (_brushRevisionDone == document.strokeRevision) return const [];
    final strokes = document.strokes;
    return _grewOnly(strokes) ? strokes.sublist(_bakedCount) : const [];
  }

  Future<void> _syncBrush() async {
    while (!_disposed && _brushRevisionDone != document.strokeRevision) {
      final revision = document.strokeRevision;
      final strokes = document.strokes;
      // Only the new strokes are drawn when the list merely grew; an undo
      // or a clear draws everything again.
      final incremental = brushImage != null && _grewOnly(strokes);
      final toDraw = incremental ? strokes.sublist(_bakedCount) : strokes;
      for (final s in toDraw) {
        if (s.clipLabel > 0 && s.clipLabel <= map.regionCount) await maskFor(s.clipLabel);
      }
      if (_disposed) return;
      ui.Image? image;
      if (strokes.isNotEmpty) {
        final bounds = Rect.fromLTWH(0, 0, map.width.toDouble(), map.height.toDouble());
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder, bounds);
        canvas.saveLayer(bounds, Paint());
        if (incremental) canvas.drawImage(brushImage!, Offset.zero, Paint());
        for (final stroke in toDraw) {
          paintStroke(canvas, stroke);
        }
        canvas.restore();
        final picture = recorder.endRecording();
        image = await picture.toImage(map.width, map.height);
        picture.dispose();
      }
      if (_disposed) {
        image?.dispose();
        return;
      }
      brushImage?.dispose();
      brushImage = image;
      _bakedCount = strokes.length;
      _bakedLast = strokes.isEmpty ? null : strokes.last;
      _brushRevisionDone = revision;
    }
  }

  /// Draws one stroke in page coordinates, with its mirror copies when it
  /// has a symmetry, clipped to its region when it has one and the region's
  /// mask is ready (bounding box otherwise).
  void paintStroke(Canvas canvas, Stroke stroke) {
    if (stroke.symmetry <= 1) {
      _paintOne(canvas, stroke);
      return;
    }
    for (final transform in symmetryTransforms(stroke.symmetry, map.width / 2, map.height / 2)) {
      canvas.save();
      canvas.transform(transform.storage);
      _paintOne(canvas, stroke);
      canvas.restore();
    }
  }

  void _paintOne(Canvas canvas, Stroke stroke) {
    final clip = stroke.kind != BrushKind.eraser && stroke.clipLabel > 0 && stroke.clipLabel <= map.regionCount;
    if (!clip) {
      drawStroke(canvas, stroke);
      return;
    }
    final rect = regionRect(stroke.clipLabel);
    final mask = maskIfReady(stroke.clipLabel);
    canvas.save();
    canvas.clipRect(rect);
    if (mask == null) {
      drawStroke(canvas, stroke);
    } else {
      canvas.saveLayer(rect, Paint());
      drawStroke(canvas, stroke);
      canvas.drawImage(mask, rect.topLeft, Paint()..blendMode = BlendMode.dstIn);
      canvas.restore();
    }
    canvas.restore();
  }

  void dispose() {
    _disposed = true;
    fillImage?.dispose();
    brushImage?.dispose();
    for (final mask in _masks.values) {
      mask.dispose();
    }
    _masks.clear();
  }

  static Future<ui.Image> _imageFromPixels(Uint8List pixels, int width, int height) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
    return frame.image;
  }
}
