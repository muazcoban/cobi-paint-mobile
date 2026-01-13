import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../models/category.dart';
import '../models/coloring_image.dart';
import '../models/saved_artwork.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final FirebaseService _firebaseService = FirebaseService();

  UserSettings _settings = UserSettings();
  List<Category> _categories = [];
  List<ColoringImage> _staticImages = [];
  List<ColoringImage> _firebaseImages = [];
  List<ColoringImage> _importedImages = [];
  List<SavedArtwork> _savedArtworks = [];
  bool _isLoading = true;
  bool _isInitialized = false;

  UserSettings get settings => _settings;
  List<Category> get categories => _categories;
  List<ColoringImage> get staticImages => _staticImages;
  List<ColoringImage> get firebaseImages => _firebaseImages;
  List<ColoringImage> get importedImages => _importedImages;
  List<SavedArtwork> get savedArtworks => _savedArtworks;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  StorageService get storageService => _storageService;
  FirebaseService get firebaseService => _firebaseService;

  Future<void> init() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Initialize services
      await _storageService.init();
      await _firebaseService.init();

      // Load settings
      _settings = await _storageService.getUserSettings();

      // Apply saved theme
      AppTheme.setTheme(_settings.selectedTheme);

      // Apply saved sound settings
      SoundService().setSoundEnabled(_settings.soundEnabled);
      SoundService().setVolume(_settings.soundVolume);

      // Load categories
      _categories = Category.getDefaultCategories();

      // Try to load Firebase categories
      if (_firebaseService.isInitialized) {
        final firebaseCategories = await _firebaseService.getCategories();
        for (final cat in firebaseCategories) {
          if (!_categories.any((c) => c.id == cat.id)) {
            _categories.add(cat);
          }
        }
      }

      // Sort categories by order
      _categories.sort((a, b) => a.order.compareTo(b.order));

      // Load static images
      _loadStaticImages();

      // Load Firebase images
      if (_firebaseService.isInitialized) {
        _firebaseImages = await _firebaseService.getAllImages();
      }

      // Load imported images
      _importedImages = await _storageService.getImportedImages();

      // Load saved artworks
      _savedArtworks = await _storageService.getSavedArtworks();

      _isInitialized = true;
    } catch (e) {
      print('Error initializing app: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadStaticImages() {
    // Static images bundled with the app
    _staticImages = [
      // Animals (8 images)
      ColoringImage(
        id: 'animal_cat',
        name: 'Kedi',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/cat.png',
      ),
      ColoringImage(
        id: 'animal_dog',
        name: 'Köpek',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/dog.png',
      ),
      ColoringImage(
        id: 'animal_bird',
        name: 'Kuş',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/bird.png',
      ),
      ColoringImage(
        id: 'animal_fish',
        name: 'Balık',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/fish.png',
      ),
      ColoringImage(
        id: 'animal_butterfly',
        name: 'Kelebek',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/butterfly.png',
      ),
      ColoringImage(
        id: 'animal_rabbit',
        name: 'Tavşan',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/rabbit.png',
      ),
      ColoringImage(
        id: 'animal_elephant',
        name: 'Fil',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/elephant.png',
      ),
      ColoringImage(
        id: 'animal_turtle',
        name: 'Kaplumbağa',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/turtle.png',
      ),
      ColoringImage(
        id: 'animal_lion',
        name: 'Aslan',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/lion.png',
      ),
      ColoringImage(
        id: 'animal_giraffe',
        name: 'Zürafa',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/giraffe.png',
      ),
      ColoringImage(
        id: 'animal_penguin',
        name: 'Penguen',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/penguin.png',
      ),
      ColoringImage(
        id: 'animal_owl',
        name: 'Baykuş',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/owl.png',
      ),
      ColoringImage(
        id: 'animal_dolphin',
        name: 'Yunus',
        category: 'animals',
        imagePath: 'assets/images/categories/animals/dolphin.png',
      ),
      // Plants (12 images)
      ColoringImage(
        id: 'plant_flower',
        name: 'Çiçek',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/flower.png',
      ),
      ColoringImage(
        id: 'plant_tree',
        name: 'Ağaç',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/tree.png',
      ),
      ColoringImage(
        id: 'plant_rose',
        name: 'Gül',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/rose.png',
      ),
      ColoringImage(
        id: 'plant_tulip',
        name: 'Lale',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/tulip.png',
      ),
      ColoringImage(
        id: 'plant_sunflower',
        name: 'Ayçiçeği',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/sunflower.png',
      ),
      ColoringImage(
        id: 'plant_cactus',
        name: 'Kaktüs',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/cactus.png',
      ),
      ColoringImage(
        id: 'plant_mushroom',
        name: 'Mantar',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/mushroom.png',
      ),
      ColoringImage(
        id: 'plant_daisy',
        name: 'Papatya',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/daisy.png',
      ),
      ColoringImage(
        id: 'plant_palm',
        name: 'Palmiye',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/palm.png',
      ),
      ColoringImage(
        id: 'plant_clover',
        name: 'Yonca',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/clover.png',
      ),
      ColoringImage(
        id: 'plant_leaf',
        name: 'Yaprak',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/leaf.png',
      ),
      ColoringImage(
        id: 'plant_cherry_blossom',
        name: 'Kiraz Çiçeği',
        category: 'plants',
        imagePath: 'assets/images/categories/plants/cherry_blossom.png',
      ),
      // Vehicles (13 images)
      ColoringImage(
        id: 'vehicle_car',
        name: 'Araba',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/car.png',
      ),
      ColoringImage(
        id: 'vehicle_plane',
        name: 'Uçak',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/plane.png',
      ),
      ColoringImage(
        id: 'vehicle_boat',
        name: 'Gemi',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/boat.png',
      ),
      ColoringImage(
        id: 'vehicle_train',
        name: 'Tren',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/train.png',
      ),
      ColoringImage(
        id: 'vehicle_helicopter',
        name: 'Helikopter',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/helicopter.png',
      ),
      ColoringImage(
        id: 'vehicle_rocket',
        name: 'Roket',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/rocket.png',
      ),
      ColoringImage(
        id: 'vehicle_bicycle',
        name: 'Bisiklet',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/bicycle.png',
      ),
      ColoringImage(
        id: 'vehicle_bus',
        name: 'Otobüs',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/bus.png',
      ),
      ColoringImage(
        id: 'vehicle_motorcycle',
        name: 'Motosiklet',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/motorcycle.png',
      ),
      ColoringImage(
        id: 'vehicle_submarine',
        name: 'Denizaltı',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/submarine.png',
      ),
      ColoringImage(
        id: 'vehicle_tractor',
        name: 'Traktör',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/tractor.png',
      ),
      ColoringImage(
        id: 'vehicle_fire_truck',
        name: 'İtfaiye',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/fire_truck.png',
      ),
      ColoringImage(
        id: 'vehicle_ambulance',
        name: 'Ambulans',
        category: 'vehicles',
        imagePath: 'assets/images/categories/vehicles/ambulance.png',
      ),
      // Characters (12 images)
      ColoringImage(
        id: 'char_princess',
        name: 'Prenses',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/princess.png',
      ),
      ColoringImage(
        id: 'char_superhero',
        name: 'Süper Kahraman',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/superhero.png',
      ),
      ColoringImage(
        id: 'char_robot',
        name: 'Robot',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/robot.png',
      ),
      ColoringImage(
        id: 'char_pirate',
        name: 'Korsan',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/pirate.png',
      ),
      ColoringImage(
        id: 'char_fairy',
        name: 'Peri',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/fairy.png',
      ),
      ColoringImage(
        id: 'char_knight',
        name: 'Şövalye',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/knight.png',
      ),
      ColoringImage(
        id: 'char_mermaid',
        name: 'Deniz Kızı',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/mermaid.png',
      ),
      ColoringImage(
        id: 'char_wizard',
        name: 'Büyücü',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/wizard.png',
      ),
      ColoringImage(
        id: 'char_dragon',
        name: 'Ejderha',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/dragon.png',
      ),
      ColoringImage(
        id: 'char_unicorn',
        name: 'Unicorn',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/unicorn.png',
      ),
      ColoringImage(
        id: 'char_astronaut',
        name: 'Astronot',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/astronaut.png',
      ),
      ColoringImage(
        id: 'char_ninja',
        name: 'Ninja',
        category: 'characters',
        imagePath: 'assets/images/categories/characters/ninja.png',
      ),
      // Nature (13 images)
      ColoringImage(
        id: 'nature_sun',
        name: 'Güneş',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/sun.png',
      ),
      ColoringImage(
        id: 'nature_rainbow',
        name: 'Gökkuşağı',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/rainbow.png',
      ),
      ColoringImage(
        id: 'nature_cloud',
        name: 'Bulut',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/cloud.png',
      ),
      ColoringImage(
        id: 'nature_star',
        name: 'Yıldız',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/star.png',
      ),
      ColoringImage(
        id: 'nature_moon',
        name: 'Ay',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/moon.png',
      ),
      ColoringImage(
        id: 'nature_mountain',
        name: 'Dağ',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/mountain.png',
      ),
      ColoringImage(
        id: 'nature_wave',
        name: 'Dalga',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/wave.png',
      ),
      ColoringImage(
        id: 'nature_snowflake',
        name: 'Kar Tanesi',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/snowflake.png',
      ),
      ColoringImage(
        id: 'nature_lightning',
        name: 'Şimşek',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/lightning.png',
      ),
      ColoringImage(
        id: 'nature_volcano',
        name: 'Volkan',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/volcano.png',
      ),
      ColoringImage(
        id: 'nature_waterfall',
        name: 'Şelale',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/waterfall.png',
      ),
      ColoringImage(
        id: 'nature_tornado',
        name: 'Kasırga',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/tornado.png',
      ),
      ColoringImage(
        id: 'nature_island',
        name: 'Ada',
        category: 'nature',
        imagePath: 'assets/images/categories/nature/island.png',
      ),
      // Food (13 images)
      ColoringImage(
        id: 'food_apple',
        name: 'Elma',
        category: 'food',
        imagePath: 'assets/images/categories/food/apple.png',
      ),
      ColoringImage(
        id: 'food_icecream',
        name: 'Dondurma',
        category: 'food',
        imagePath: 'assets/images/categories/food/icecream.png',
      ),
      ColoringImage(
        id: 'food_cupcake',
        name: 'Cupcake',
        category: 'food',
        imagePath: 'assets/images/categories/food/cupcake.png',
      ),
      ColoringImage(
        id: 'food_pizza',
        name: 'Pizza',
        category: 'food',
        imagePath: 'assets/images/categories/food/pizza.png',
      ),
      ColoringImage(
        id: 'food_watermelon',
        name: 'Karpuz',
        category: 'food',
        imagePath: 'assets/images/categories/food/watermelon.png',
      ),
      ColoringImage(
        id: 'food_cookie',
        name: 'Kurabiye',
        category: 'food',
        imagePath: 'assets/images/categories/food/cookie.png',
      ),
      ColoringImage(
        id: 'food_lollipop',
        name: 'Lolipop',
        category: 'food',
        imagePath: 'assets/images/categories/food/lollipop.png',
      ),
      ColoringImage(
        id: 'food_banana',
        name: 'Muz',
        category: 'food',
        imagePath: 'assets/images/categories/food/banana.png',
      ),
      ColoringImage(
        id: 'food_strawberry',
        name: 'Çilek',
        category: 'food',
        imagePath: 'assets/images/categories/food/strawberry.png',
      ),
      ColoringImage(
        id: 'food_orange',
        name: 'Portakal',
        category: 'food',
        imagePath: 'assets/images/categories/food/orange.png',
      ),
      ColoringImage(
        id: 'food_donut',
        name: 'Donut',
        category: 'food',
        imagePath: 'assets/images/categories/food/donut.png',
      ),
      ColoringImage(
        id: 'food_cake',
        name: 'Pasta',
        category: 'food',
        imagePath: 'assets/images/categories/food/cake.png',
      ),
      ColoringImage(
        id: 'food_hamburger',
        name: 'Hamburger',
        category: 'food',
        imagePath: 'assets/images/categories/food/hamburger.png',
      ),
    ];
  }

  List<ColoringImage> getImagesForCategory(String categoryId) {
    final List<ColoringImage> result = [];

    // Add static images
    result.addAll(_staticImages.where((img) => img.category == categoryId));

    // Add Firebase images
    result.addAll(_firebaseImages.where((img) => img.category == categoryId));

    // Add imported images if looking at import category
    if (categoryId == 'import') {
      result.addAll(_importedImages);
    }

    return result;
  }

  // Settings management
  Future<void> updateSettings(UserSettings newSettings) async {
    _settings = newSettings;
    await _storageService.saveUserSettings(newSettings);
    notifyListeners();
  }

  Future<void> setPro(bool isPro) async {
    _settings = _settings.copyWith(isPro: isPro);
    await _storageService.saveUserSettings(_settings);
    notifyListeners();
  }

  // Import management
  Future<bool> canImportImage() async {
    if (_settings.isPro) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      _settings.lastImportDate.year,
      _settings.lastImportDate.month,
      _settings.lastImportDate.day,
    );

    if (today.isAfter(lastDate)) {
      // New day, reset count
      _settings = _settings.copyWith(
        dailyImportCount: 0,
        lastImportDate: now,
      );
      await _storageService.saveUserSettings(_settings);
    }

    return _settings.dailyImportCount < UserSettings.maxFreeImportsPerDay;
  }

  Future<void> incrementImportCount() async {
    final now = DateTime.now();
    _settings = _settings.copyWith(
      dailyImportCount: _settings.dailyImportCount + 1,
      lastImportDate: now,
    );
    await _storageService.saveUserSettings(_settings);
    notifyListeners();
  }

  // Imported images management
  Future<void> addImportedImage(ColoringImage image) async {
    _importedImages.insert(0, image);
    await _storageService.saveImportedImageMetadata(image);
    notifyListeners();
  }

  Future<void> removeImportedImage(String id) async {
    _importedImages.removeWhere((img) => img.id == id);
    await _storageService.deleteImportedImage(id);
    notifyListeners();
  }

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

  SavedArtwork? getArtworkById(String id) {
    try {
      return _savedArtworks.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh data from Firebase
  Future<void> refreshFromFirebase() async {
    if (!_firebaseService.isInitialized) return;

    try {
      // Refresh categories
      final firebaseCategories = await _firebaseService.getCategories();
      for (final cat in firebaseCategories) {
        final index = _categories.indexWhere((c) => c.id == cat.id);
        if (index >= 0) {
          _categories[index] = cat;
        } else {
          _categories.add(cat);
        }
      }
      _categories.sort((a, b) => a.order.compareTo(b.order));

      // Refresh images
      _firebaseImages = await _firebaseService.getAllImages();

      notifyListeners();
    } catch (e) {
      print('Error refreshing from Firebase: $e');
    }
  }
}
