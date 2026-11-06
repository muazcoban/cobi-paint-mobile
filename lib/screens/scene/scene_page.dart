import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../../engine/scene/scene_placement.dart';
import '../../models/coloring_image.dart';
import '../../models/scene.dart';

/// The scene as one line-art page, the way a bundled page looks: the empty
/// background with every placed piece drawn into its slot, white inside. The
/// rough prototype opens it in today's coloring screen like any page; the
/// real scene engine keeps background and pieces apart (council condition 21).
Future<Uint8List> composeScenePage(ScenePlacement placement, {AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  final scene = placement.scene;
  final side = scene.size.round();
  final images = <ui.Image>[];
  Future<ui.Image> load(String path) async {
    final data = await assets.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final image = (await codec.getNextFrame()).image;
    codec.dispose();
    images.add(image);
    return image;
  }

  try {
    final background = await load(scene.background);
    final pieces = [for (final step in placement.placed) (await load(step.piece.asset), step.slot.rect)];
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final page = ui.Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble());
    canvas.drawRect(page, ui.Paint()..color = const ui.Color(0xFFFFFFFF));
    canvas.drawImageRect(background, _bounds(background), page, ui.Paint());
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    for (final (art, rect) in pieces) {
      canvas.drawImageRect(art, _bounds(art), rect, paint);
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(side, side);
    picture.dispose();
    try {
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      return png!.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
    } finally {
      image.dispose();
    }
  } finally {
    for (final image in images) {
      image.dispose();
    }
  }
}

ui.Rect _bounds(ui.Image image) => ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

/// The page the coloring screen opens for a composed scene: a file in the
/// app's scenes folder, read like an imported page. Its id is not a bundled
/// page's, so the level counter and "paint again" leave it alone.
ColoringImage scenePageImage(SceneDefinition scene, File file, DateTime at) => ColoringImage(
      id: 'scene_${scene.id}_${at.millisecondsSinceEpoch}',
      name: 'Manzara',
      nameEn: 'Scene',
      category: 'scene',
      imagePath: file.path,
      level: 1,
      isImported: true,
      createdAt: at,
    );
