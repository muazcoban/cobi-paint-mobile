import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../document/coloring_document.dart';
import 'page_layers.dart';
import 'sticker_images.dart';

/// The finished picture as PNG bytes, at page size and as a thumbnail.
class ArtworkPngs {
  const ArtworkPngs({required this.image, required this.thumbnail});

  final Uint8List image;
  final Uint8List thumbnail;
}

/// Flattens paper, fills, brush strokes and line art into PNGs for saving,
/// sharing and the gallery. Uses its own layers, so it never disturbs the
/// canvas on screen.
Future<ArtworkPngs> renderArtworkPngs(
  ColoringDocument document,
  ui.Image page, {
  Color paper = const Color(0xFFFFFFFF),
  int thumbnailSide = 360,
}) async {
  final layers = PageLayers(document: document);
  try {
    await layers.syncFills();
    await layers.syncBrush();
    await StickerImages.ensure(document.stickers.map((s) => s.code));
    final w = document.map.width;
    final h = document.map.height;
    final thumbScale = math.min(1.0, thumbnailSide / math.max(w, h));
    final full = await _compose(layers, page, paper, w, h, 1);
    final thumb = await _compose(layers, page, paper, (w * thumbScale).round(), (h * thumbScale).round(), thumbScale);
    try {
      return ArtworkPngs(image: await _png(full), thumbnail: await _png(thumb));
    } finally {
      full.dispose();
      thumb.dispose();
    }
  } finally {
    layers.dispose();
  }
}

Future<ui.Image> _compose(PageLayers layers, ui.Image page, Color paper, int width, int height, double scale) {
  final map = layers.map;
  final pageRect = Rect.fromLTWH(0, 0, map.width.toDouble(), map.height.toDouble());
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
  canvas.scale(scale);
  final smooth = Paint()..filterQuality = FilterQuality.medium;
  canvas.drawRect(pageRect, Paint()..color = paper);
  if (layers.fillImage case final fill?) canvas.drawImage(fill, Offset.zero, smooth);
  if (layers.brushImage case final brush?) canvas.drawImage(brush, Offset.zero, smooth);
  canvas.drawImageRect(
    page,
    Rect.fromLTWH(0, 0, page.width.toDouble(), page.height.toDouble()),
    pageRect,
    Paint()
      ..colorFilter = lineArtFilter
      ..filterQuality = FilterQuality.medium,
  );
  // Stickers sit on top of the lines, like real ones.
  StickerImages.draw(canvas, layers.document.stickers);
  final picture = recorder.endRecording();
  return picture.toImage(width, height).whenComplete(picture.dispose);
}

Future<Uint8List> _png(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) throw StateError('PNG encoding failed');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
