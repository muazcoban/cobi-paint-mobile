import 'package:cobi_paint_mobile/models/coloring_image.dart';
import 'package:cobi_paint_mobile/models/saved_artwork.dart';
import 'package:cobi_paint_mobile/models/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSettings', () {
    test('reads settings saved by older versions', () {
      final settings = UserSettings.fromJson({
        'isPro': true,
        'dailyImportCount': 2,
        'lastImportDate': '2026-01-18T10:00:00.000',
        'selectedTheme': 'ocean',
        'language': 'en',
        'soundEnabled': false,
        'soundVolume': 1,
        'coloringCompletedCount': 1,
      });

      expect(settings.selectedTheme, 'ocean');
      expect(settings.soundEnabled, isFalse);
      expect(settings.soundVolume, 1.0);
      expect(settings.hapticsEnabled, isTrue, reason: 'haptics stay on unless a parent turns them off');
    });

    test('survives a save and load round trip', () {
      final original = UserSettings(
        selectedTheme: 'forest',
        soundEnabled: false,
        hapticsEnabled: false,
        soundVolume: 0.3,
        ageMode: AgeMode.big,
      );
      final restored = UserSettings.fromJson(original.toJson());

      expect(restored.selectedTheme, 'forest');
      expect(restored.soundEnabled, isFalse);
      expect(restored.hapticsEnabled, isFalse);
      expect(restored.soundVolume, 0.3);
      expect(restored.ageMode, AgeMode.big);
    });

    test('starts in Minik mode for a 3-year-old', () {
      expect(UserSettings().ageMode, AgeMode.little);
      expect(UserSettings.fromJson({'selectedTheme': 'coral'}).ageMode, AgeMode.little);
    });
  });

  test('ColoringImage reads imported page metadata saved by older versions', () {
    final image = ColoringImage.fromJson({
      'id': 'imported_1',
      'name': 'Fotoğrafım',
      'category': 'import',
      'imagePath': '/data/imported/imported_1.png',
      'isFromFirebase': false,
      'isImported': true,
      'createdAt': '2026-01-18T10:00:00.000',
    });

    expect(image.isImported, isTrue);
    expect(image.imagePath, '/data/imported/imported_1.png');
    expect(image.createdAt, DateTime(2026, 1, 18, 10));
  });

  test('SavedArtwork survives a save and load round trip', () {
    final original = SavedArtwork(
      id: 'a1',
      originalImageId: 'animal_cat',
      originalImagePath: 'assets/images/categories/animals/cat.png',
      savedImagePath: 'a1.png',
      thumbnailPath: 'a1_thumb.png',
      name: 'Kedi',
      createdAt: DateTime(2026, 11, 2, 9),
      updatedAt: DateTime(2026, 11, 2, 10),
      coloredRegions: {'5': 0xFFE53935},
    );
    final restored = SavedArtwork.fromJson(original.toJson());

    expect(restored.id, 'a1');
    expect(restored.originalImageId, 'animal_cat');
    expect(restored.coloredRegions, {'5': 0xFFE53935});
    expect(restored.updatedAt, DateTime(2026, 11, 2, 10));
    expect(restored.schema, 2);
  });

  test('artworks saved before version 2 read as schema 1 with their pixel colours', () {
    final legacy = SavedArtwork.fromJson({
      'id': 'old',
      'originalImageId': 'animal_cat',
      'originalImagePath': 'assets/images/categories/animals/cat.png',
      'savedImagePath': '/var/mobile/Containers/Data/Application/OLD/Documents/artworks/old.png',
      'thumbnailPath': '/var/mobile/Containers/Data/Application/OLD/Documents/artworks/old_thumb.png',
      'name': 'Kedi',
      'createdAt': '2026-01-18T10:00:00.000',
      'updatedAt': '2026-01-18T10:00:00.000',
      'coloredRegions': {'5': 0xFFE53935},
    });
    expect(legacy.schema, 1);
    expect(legacy.coloredRegions, {'5': 0xFFE53935});
  });
}
