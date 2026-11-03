// Renders the fill regions of coloring pages so leaks and missing regions are
// easy to spot: every region gets its own colour, lines are drawn on top.
//
// Usage: dart run tool/region_preview.dart <out_dir> <page.png>...
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cobi_paint_mobile/engine/region/region_builder.dart';
import 'package:image/image.dart' as img;

const _palette = [
  [255, 99, 99], [99, 180, 255], [255, 200, 60], [120, 220, 120],
  [200, 130, 255], [255, 150, 200], [90, 220, 220], [255, 170, 90],
];

void main(List<String> args) {
  if (args.length < 2) {
    print('Usage: dart run tool/region_preview.dart <out_dir> <page.png>...');
    exit(64);
  }
  final outDir = Directory(args.first)..createSync(recursive: true);
  for (final path in args.skip(1)) {
    final page = img.decodePng(File(path).readAsBytesSync())!.convert(numChannels: 4);
    final rgba = page.getBytes(order: img.ChannelOrder.rgba);
    final watch = Stopwatch()..start();
    final map = RegionBuilder.build(rgba, page.width, page.height);
    final ms = watch.elapsedMilliseconds;
    final lines = RegionBuilder.lineMask(rgba, page.width, page.height);

    final out = img.Image(width: page.width, height: page.height);
    for (var y = 0; y < page.height; y++) {
      for (var x = 0; x < page.width; x++) {
        final i = y * page.width + x;
        if (lines[i] == 1) {
          out.setPixelRgb(x, y, 0, 0, 0);
        } else {
          final c = _palette[map.labels[i] % _palette.length];
          out.setPixelRgb(x, y, c[0], c[1], c[2]);
        }
      }
    }
    final name = path.split('/').reversed.take(2).toList().reversed.join('_');
    File('${outDir.path}/$name').writeAsBytesSync(img.encodePng(out));
    print('$path: ${map.regionCount} regions in $ms ms');
  }
}
