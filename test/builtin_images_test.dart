import 'dart:io';

import 'package:cobi_paint_mobile/data/builtin_images.dart';
import 'package:cobi_paint_mobile/models/category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('every built-in page exists and decodes as PNG', () {
    for (final page in builtInImages) {
      final file = File(page.imagePath);
      expect(file.existsSync(), isTrue, reason: page.imagePath);
      expect(img.decodePng(file.readAsBytesSync()), isNotNull, reason: page.imagePath);
    }
  });

  test('built-in page ids are unique', () {
    final ids = builtInImages.map((page) => page.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every coloring category has built-in pages', () {
    final categories = Category.getDefaultCategories().where((c) => !c.isImportCategory);
    for (final category in categories) {
      expect(
        builtInImages.where((page) => page.category == category.id),
        isNotEmpty,
        reason: category.id,
      );
    }
  });

  test('every built-in page folder is bundled through pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final page in builtInImages) {
      final folder = page.imagePath.substring(0, page.imagePath.lastIndexOf('/') + 1);
      expect(pubspec, contains('- $folder\n'), reason: page.imagePath);
    }
  });
}
