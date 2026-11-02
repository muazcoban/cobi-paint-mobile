import 'dart:io';
import 'dart:typed_data';

import 'package:cobi_paint_mobile/engine/region/region_builder.dart';
import 'package:cobi_paint_mobile/engine/region/region_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory cacheDir;

  setUp(() => cacheDir = Directory.systemTemp.createTempSync('region_cache_test'));
  tearDown(() => cacheDir.deleteSync(recursive: true));

  final page = File('assets/images/categories/animals/cat.png').readAsBytesSync();

  test('builds a label map and serves the second request from the cache', () async {
    final service = RegionService(cacheDirectory: () async => cacheDir);

    final first = await service.labelMapFor(page);
    final cached = cacheDir.listSync(recursive: true).whereType<File>().toList();
    expect(cached, hasLength(1));

    final second = await service.labelMapFor(page);
    expect(second.labels, first.labels);
    expect(second.regionCount, first.regionCount);
  });

  test('a different gap setting gets its own cache entry', () async {
    final service = RegionService(cacheDirectory: () async => cacheDir);

    await service.labelMapFor(page);
    await service.labelMapFor(page, options: const RegionBuilderOptions(gapPx: 0));

    expect(cacheDir.listSync(recursive: true).whereType<File>(), hasLength(2));
  });

  test('a corrupt cache file is rebuilt instead of crashing', () async {
    final service = RegionService(cacheDirectory: () async => cacheDir);
    final good = await service.labelMapFor(page);
    final file = cacheDir.listSync(recursive: true).whereType<File>().single;
    file.writeAsBytesSync(Uint8List.fromList([1, 2, 3]));

    final rebuilt = await service.labelMapFor(page);
    expect(rebuilt.labels, good.labels);
  });

  test('works without a cache directory', () async {
    final service = RegionService(cacheDirectory: () async => throw const FileSystemException('no dir'));

    final map = await service.labelMapFor(page);
    expect(map.regionCount, greaterThan(1));
  });

  test('fnv1a32 matches the reference value', () {
    expect(fnv1a32(Uint8List.fromList('a'.codeUnits)), 0xE40C292C);
  });
}
