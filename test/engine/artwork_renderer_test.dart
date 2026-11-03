import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/sticker.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/engine/render/artwork_renderer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 40 x 40 page that is one region, and a blank white page image for it.
LabelMap _map() => LabelMap(
      width: 40,
      height: 40,
      labels: Uint16List(1600)..fillRange(0, 1600, 1),
      regions: const [RegionInfo(left: 0, top: 0, right: 39, bottom: 39, area: 1600)],
    );

Future<ui.Image> _blankPage() async {
  final rgba = Uint8List(40 * 40 * 4)..fillRange(0, 40 * 40 * 4, 255);
  final buffer = await ui.ImmutableBuffer.fromUint8List(rgba);
  final descriptor = ui.ImageDescriptor.raw(buffer, width: 40, height: 40, pixelFormat: ui.PixelFormat.rgba8888);
  final codec = await descriptor.instantiateCodec();
  return (await codec.getNextFrame()).image;
}

Future<List<int>> _rgbAt(Uint8List png, int x, int y) async {
  final image = await decodeImageFromList(png);
  final bytes = (await image.toByteData())!.buffer.asUint8List();
  final p = (y * image.width + x) * 4;
  return bytes.sublist(p, p + 3);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the saved picture has the stickers on it, the thumbnail too', () async {
    final document = ColoringDocument(_map())
      ..stamp([const Sticker(code: 'red_heart', x: 20, y: 20, size: 24)]);
    final page = await _blankPage();
    final pngs = await renderArtworkPngs(document, page, thumbnailSide: 20);

    final centre = await _rgbAt(pngs.image, 20, 20);
    expect(centre[0], greaterThan(150), reason: 'the heart is red: $centre');
    expect(centre[1], lessThan(120), reason: 'not white: $centre');
    final corner = await _rgbAt(pngs.image, 2, 2);
    expect(corner, [255, 255, 255], reason: 'paper stays white around it');
    final thumb = await _rgbAt(pngs.thumbnail, 10, 10);
    expect(thumb[1], lessThan(120), reason: 'the thumbnail shows it as well: $thumb');
  });
}
