import 'dart:convert';
import 'dart:io';

import 'package:cobi_paint_mobile/data/builtin_images.dart';
import 'package:cobi_paint_mobile/l10n/app_localizations.dart';
import 'package:cobi_paint_mobile/models/category.dart';
import 'package:cobi_paint_mobile/screens/home_screen.dart' show categoryName;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  final coloringCategories = Category.getDefaultCategories().where((c) => !c.isImportCategory).toList()
    ..sort((a, b) => a.order.compareTo(b.order));

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
    for (final category in coloringCategories) {
      expect(
        builtInImages.where((page) => page.category == category.id),
        isNotEmpty,
        reason: category.id,
      );
    }
  });

  test('English page names have no Turkish-only letters (VoiceOver reads them)', () {
    final turkishOnly = RegExp('[İıŞşĞğ]'); // dotted and dotless i, s and g with cedilla/breve
    for (final page in builtInImages) {
      expect(page.nameEn, isNot(contains(turkishOnly)), reason: page.id);
    }
  });

  test('every built-in page folder is bundled through pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final page in builtInImages) {
      final folder = page.imagePath.substring(0, page.imagePath.lastIndexOf('/') + 1);
      expect(pubspec, contains('- $folder\n'), reason: page.imagePath);
    }
  });

  group('categories', () {
    test('ten coloring categories, the older nine keep their places on the home screen', () {
      // A child finds a card by where it is, so new categories only ever go last.
      expect(
        coloringCategories.map((c) => c.id),
        ['animals', 'plants', 'vehicles', 'nature', 'food', 'things', 'space', 'music', 'clothes', 'celebrations'],
      );
    });

    test('a page lent to another category keeps its own id and category', () {
      final ids = coloringCategories.map((c) => c.id).toSet();
      for (final page in builtInImages) {
        for (final other in page.alsoIn) {
          expect(ids, contains(other), reason: '${page.id} is lent to an unknown category');
          expect(other, isNot(page.category), reason: '${page.id} lends itself to its own category');
        }
        expect(page.id, startsWith('${page.category}_'), reason: 'the id names the home category');
      }
    });

    test('celebrations gathers the winter and new year pages of the older categories', () {
      final lent = builtInImages.where((page) => page.alsoIn.contains('celebrations')).toList();
      expect(lent.length, greaterThanOrEqualTo(20));
      for (final name in ['Snowman', 'Christmas tree', 'Penguin', 'Wrapped gift', 'Gloves']) {
        expect(lent.map((page) => page.nameEn), contains(name));
      }
      // The free rule counts a category's own pages; a lent page is free or
      // not where it lives.
      final own = builtInImages.where((page) => page.category == 'celebrations');
      expect(own.length, greaterThanOrEqualTo(10));
    });

    test('every page belongs to a category on the home screen', () {
      final ids = coloringCategories.map((c) => c.id).toSet();
      for (final page in builtInImages) {
        expect(ids, contains(page.category), reason: page.id);
      }
    });

    test('every coloring category has exactly 8 free pages', () {
      for (final category in coloringCategories) {
        final free = builtInImages.where((page) => page.category == category.id && page.free);
        expect(free, hasLength(8), reason: category.id);
      }
    });

    test('the new categories start with easy pages: most free pages are level 1', () {
      for (final id in ['space', 'music', 'clothes', 'celebrations']) {
        final pages = builtInImages.where((page) => page.category == id).toList();
        expect(pages.length, greaterThanOrEqualTo(12), reason: id);
        final freeLevel1 = pages.where((page) => page.free && page.level == 1);
        expect(freeLevel1.length, greaterThan(4), reason: id);
      }
    });

    test('nature and plants have at least 20 pages each', () {
      for (final id in ['nature', 'plants']) {
        expect(builtInImages.where((page) => page.category == id).length, greaterThanOrEqualTo(20), reason: id);
      }
    });

    test('every coloring category has one icon glyph and its name in Turkish and English', () {
      final tr = lookupAppLocalizations(const Locale('tr'));
      final en = lookupAppLocalizations(const Locale('en'));
      for (final category in coloringCategories) {
        expect(category.icon.characters, hasLength(1), reason: category.id);
        expect(categoryName(tr, category), category.name, reason: category.id);
        expect(categoryName(en, category), category.nameEn, reason: category.id);
      }
    });

    test('every draft language names every coloring category', () {
      final drafts = Directory('lib/l10n/drafts').listSync().whereType<File>().where((f) => f.path.endsWith('.arb'));
      expect(drafts, isNotEmpty);
      for (final draft in drafts) {
        final strings = jsonDecode(draft.readAsStringSync()) as Map<String, dynamic>;
        for (final category in coloringCategories) {
          expect(strings[category.id], isA<String>().having((s) => s.trim(), 'name', isNotEmpty),
              reason: '${draft.path}: ${category.id}');
        }
      }
    });

    test('every coloring category has a spoken name in the recording list', () {
      final voice = File('tool/voice/README.md').readAsStringSync();
      for (final category in coloringCategories) {
        expect(voice, contains('| category_${category.id} | ${category.name} | ${category.nameEn} |'), reason: category.id);
      }
    });
  });

  test('the catalog and the bundled pages agree', () {
    final catalog = jsonDecode(File('tool/pages/catalog.json').readAsStringSync()) as Map<String, dynamic>;
    final byId = {for (final page in builtInImages) page.id: page};
    final listed = <String>{};
    for (final entry in (catalog['pages'] as List).cast<Map<String, dynamic>>()) {
      final id = '${entry['category']}_${entry['code']}';
      final skip = entry['skip'];
      if (skip != null) {
        // A page that is not built says why, and is not bundled.
        expect(skip, isA<String>().having((s) => s.trim(), 'reason', isNotEmpty), reason: id);
        expect(byId, isNot(contains(id)), reason: id);
        continue;
      }
      listed.add(id);
      final page = byId[id];
      expect(page, isNotNull, reason: '$id is in the catalog but not bundled; mark it "skip" with the reason');
      expect(page!.free, entry['free'] == true, reason: id);
    }
    expect(byId.keys.toSet().difference(listed), isEmpty, reason: 'bundled pages missing from the catalog');
  });
}
