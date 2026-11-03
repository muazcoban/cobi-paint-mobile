// Checks coloring pages the way the app sees them and prints one line per
// page: regions, finger-sized areas, background share, ink share, problems.
// Run it on new art before adding it to lib/data/builtin_images.dart.
//
// Usage: dart run tool/page_report.dart <page.png>...
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cobi_paint_mobile/engine/region/page_check.dart';
import 'package:cobi_paint_mobile/engine/region/region_builder.dart';
import 'package:image/image.dart' as img;

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run tool/page_report.dart <page.png>...');
    exit(64);
  }
  var bad = 0;
  for (final path in args) {
    final page = img.decodePng(File(path).readAsBytesSync())!.convert(numChannels: 4);
    final rgba = page.getBytes(order: img.ChannelOrder.rgba);
    final map = RegionBuilder.build(rgba, page.width, page.height);
    final check = PageCheck.of(map, RegionBuilder.lineMask(rgba, page.width, page.height));
    final problems = check.problems;
    final warnings = check.warnings;
    if (problems.isNotEmpty) bad++;
    print([
      path,
      '${page.width}x${page.height}',
      'regions ${check.regions}',
      'finger ${check.fingerRegions}',
      'background ${(check.backgroundShare * 100).round()}%',
      'ink ${(check.lineShare * 100).toStringAsFixed(1)}%',
      if (problems.isNotEmpty) 'PROBLEM: ${problems.join('; ')}',
      if (warnings.isNotEmpty) 'weak: ${warnings.join('; ')}',
    ].join('  '));
  }
  print('${args.length} pages, $bad with problems');
  exit(bad == 0 ? 0 : 1);
}
