import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../data/builtin_images.dart';
import '../engine/region/region_service.dart';
import '../models/user_settings.dart';
import '../models/category.dart';
import '../models/coloring_image.dart';
import '../models/saved_artwork.dart';
import '../services/haptics.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  /// Label maps are derived data, so the OS may clear them with the cache.
  final RegionService regionService = RegionService(cacheDirectory: getApplicationCacheDirectory);

  UserSettings _settings = UserSettings();
  List<Category> _categories = [];
  List<ColoringImage> _importedImages = [];
  List<SavedArtwork> _savedArtworks = [];
  bool _isLoading = true;
  bool _isInitialized = false;

  UserSettings get settings => _settings;
  List<Category> get categories => _categories;
  List<ColoringImage> get staticImages => builtInImages;
  List<ColoringImage> get importedImages => _importedImages;
  List<SavedArtwork> get savedArtworks => _savedArtworks;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  StorageService get storageService => _storageService;

  Future<void> init() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Initialize services
      await _storageService.init();

      // Load settings
      _settings = await _storageService.getUserSettings();

      // Apply saved theme
      AppTheme.setTheme(_settings.selectedTheme);

      // Apply saved sound settings
      SoundService().setSoundEnabled(_settings.soundEnabled);
      SoundService().setVolume(_settings.soundVolume);
      Haptics.enabled = _settings.hapticsEnabled;

      // Photo import is frozen until it is rebuilt on the new coloring engine.
      // Pages imported before the freeze stay reachable through the import category.
      _importedImages = await _storageService.getImportedImages();

      // Load categories, showing the import category only when it has pages
      _categories = Category.getDefaultCategories()
          .where((c) => !c.isImportCategory || _importedImages.isNotEmpty)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      // Load saved artworks
      _savedArtworks = await _storageService.getSavedArtworks();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ColoringImage> getImagesForCategory(String categoryId) {
    // Imported pages only live in the import category
    if (categoryId == 'import') return _importedImages;
    return builtInImages.where((img) => img.category == categoryId).toList();
  }

  // Settings management
  Future<void> updateSettings(UserSettings newSettings) async {
    _settings = newSettings;
    await _storageService.saveUserSettings(newSettings);
    notifyListeners();
  }

  Future<void> setAgeMode(AgeMode mode) => updateSettings(_settings.copyWith(ageMode: mode));

  // Saved artworks management
  Future<void> saveArtwork(SavedArtwork artwork) async {
    final index = _savedArtworks.indexWhere((a) => a.id == artwork.id);
    if (index >= 0) {
      _savedArtworks[index] = artwork;
    } else {
      _savedArtworks.insert(0, artwork);
    }
    await _storageService.saveArtwork(artwork);
    notifyListeners();
  }

  Future<void> deleteArtwork(String id) async {
    _savedArtworks.removeWhere((a) => a.id == id);
    await _storageService.deleteArtwork(id);
    notifyListeners();
  }
}
