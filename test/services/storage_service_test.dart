import 'dart:io';
import 'dart:typed_data';

import 'package:cobi_paint_mobile/models/saved_artwork.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory docs;
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    docs = Directory.systemTemp.createTempSync('storage_test');
    storage = StorageService(documentsDirectory: () async => docs);
    await storage.init();
  });

  tearDown(() => docs.deleteSync(recursive: true));

  final png = Uint8List.fromList([1, 2, 3]);

  test('artwork files are written under artworks/<id> with relative paths', () async {
    final files = await storage.writeArtworkFiles('a1', document: {'schema': 2}, imagePng: png, thumbnailPng: png);

    expect(files.image, 'artworks/a1/image.png');
    expect(storage.resolveArtworkFile(files.thumbnail).existsSync(), isTrue);
    expect(await storage.readArtworkDocument('a1'), {'schema': 2});
  });

  test('a version 1 absolute path from an old app container is found by name', () async {
    File('${docs.path}/artworks/old.png').writeAsBytesSync(png);
    final file = storage.resolveArtworkFile('/var/mobile/Containers/Data/Application/OLD/Documents/artworks/old.png');

    expect(file.path, '${docs.path}/artworks/old.png');
    expect(file.existsSync(), isTrue);
  });

  test('writing version 2 files removes the old flat version 1 files', () async {
    File('${docs.path}/artworks/a1.png').writeAsBytesSync(png);
    File('${docs.path}/artworks/a1_thumb.png').writeAsBytesSync(png);

    await storage.writeArtworkFiles('a1', document: {}, imagePng: png, thumbnailPng: png);

    expect(File('${docs.path}/artworks/a1.png').existsSync(), isFalse);
    expect(File('${docs.path}/artworks/a1_thumb.png').existsSync(), isFalse);
  });

  test('deleting an artwork removes its entry and its folder', () async {
    await storage.writeArtworkFiles('a1', document: {}, imagePng: png, thumbnailPng: png);
    final now = DateTime(2026, 11, 3);
    await storage.saveArtwork(SavedArtwork(
      id: 'a1',
      originalImageId: 'animal_cat',
      originalImagePath: 'assets/images/categories/animals/cat.png',
      savedImagePath: 'artworks/a1/image.png',
      thumbnailPath: 'artworks/a1/thumb.png',
      name: 'Kedi',
      createdAt: now,
      updatedAt: now,
    ));

    await storage.deleteArtwork('a1');

    expect(await storage.getSavedArtworks(), isEmpty);
    expect(Directory('${docs.path}/artworks/a1').existsSync(), isFalse);
  });

  test('a corrupt document reads as missing instead of crashing', () async {
    await storage.writeArtworkFiles('a1', document: {}, imagePng: png, thumbnailPng: png);
    File('${docs.path}/artworks/a1/doc.json').writeAsStringSync('{not json');

    expect(await storage.readArtworkDocument('a1'), isNull);
  });
}
