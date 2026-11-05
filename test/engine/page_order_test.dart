import 'package:cobi_paint_mobile/data/page_order.dart';
import 'package:cobi_paint_mobile/models/coloring_image.dart';
import 'package:cobi_paint_mobile/models/saved_artwork.dart';
import 'package:cobi_paint_mobile/models/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';

ColoringImage _page(String id, int level) =>
    ColoringImage(id: id, name: id, category: 'animals', imagePath: 'assets/pages/animals/$id.png', level: level);

SavedArtwork _artwork(String pageId) => SavedArtwork(
      id: 'a-$pageId',
      originalImageId: pageId,
      originalImagePath: 'assets/pages/animals/$pageId.png',
      savedImagePath: 'x',
      thumbnailPath: 'x',
      name: pageId,
      createdAt: DateTime(2026, 11, 3),
      updatedAt: DateTime(2026, 11, 3),
    );

void main() {
  final pages = [_page('a', 1), _page('b', 2), _page('c', 3), _page('d', 1), _page('e', 2)];
  final byId = {for (final p in pages) p.id: p};

  group('currentLevel', () {
    // Enough pages per level to count different ones.
    final levelPages = [
      for (var i = 0; i < pagesPerLevel; i++) _page('one$i', 1),
      for (var i = 0; i < pagesPerLevel; i++) _page('two$i', 2),
      _page('three', 3),
    ];
    final levelById = {for (final p in levelPages) p.id: p};

    test('a new child starts at level 1', () {
      expect(currentLevel(UserSettings(), const [], byId), 1);
    });

    test('moves up after enough different pages of the current level were coloured', () {
      final four = List.generate(pagesPerLevel, (i) => _artwork('one$i'));
      expect(currentLevel(UserSettings(), four.take(pagesPerLevel - 1), levelById), 1);
      expect(currentLevel(UserSettings(), four, levelById), 2);
    });

    test('copies of one page count once', () {
      final copies = List.generate(pagesPerLevel, (_) => _artwork('one0'));
      expect(currentLevel(UserSettings(), copies, levelById), 1, reason: 'the same page four times is practice');
    });

    test('Minik mode stops at level 2, Büyük mode goes on to 3', () {
      final many = [
        ...List.generate(pagesPerLevel, (i) => _artwork('one$i')),
        ...List.generate(pagesPerLevel, (i) => _artwork('two$i')),
      ];
      expect(currentLevel(UserSettings(), many, levelById), littleModeMaxLevel);
      expect(currentLevel(UserSettings(ageMode: AgeMode.big), many, levelById), 3);
    });

    test('a level pinned by a parent wins', () {
      expect(currentLevel(UserSettings(level: 3), const [], byId), 3);
      expect(currentLevel(UserSettings(level: 1, ageMode: AgeMode.big), [_artwork('b')], byId), 1);
    });

    test('artworks of pages that left the app do not count', () {
      final gone = List.generate(pagesPerLevel, (_) => _artwork('old_page'));
      expect(currentLevel(UserSettings(), gone, byId), 1);
    });
  });

  group('orderPages', () {
    test('current level first, then easier, then harder, nearest level first', () {
      expect(orderPages(pages, 2).map((p) => p.id), ['b', 'e', 'a', 'd', 'c']);
      expect(orderPages(pages, 1).map((p) => p.id), ['a', 'd', 'b', 'e', 'c']);
      expect(orderPages(pages, 3).map((p) => p.id), ['c', 'b', 'e', 'a', 'd']);
    });

    test('does not change the input list', () {
      final copy = List.of(pages);
      orderPages(pages, 3);
      expect(pages.map((p) => p.id), copy.map((p) => p.id));
    });
  });
}
