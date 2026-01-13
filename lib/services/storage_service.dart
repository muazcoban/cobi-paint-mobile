import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/saved_artwork.dart';
import '../models/user_settings.dart';
import '../models/coloring_image.dart';

class StorageService {
  static const String _artworksKey = 'saved_artworks';
  static const String _settingsKey = 'user_settings';
  static const String _importedImagesKey = 'imported_images';

  late SharedPreferences _prefs;
  late Directory _appDir;
  late Directory _artworksDir;
  late Directory _importedDir;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _appDir = await getApplicationDocumentsDirectory();

    _artworksDir = Directory('${_appDir.path}/artworks');
    _importedDir = Directory('${_appDir.path}/imported');

    if (!await _artworksDir.exists()) {
      await _artworksDir.create(recursive: true);
    }
    if (!await _importedDir.exists()) {
      await _importedDir.create(recursive: true);
    }
  }

  // User Settings
  Future<UserSettings> getUserSettings() async {
    final data = _prefs.getString(_settingsKey);
    if (data != null) {
      return UserSettings.fromJson(jsonDecode(data));
    }
    return UserSettings();
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // Saved Artworks
  Future<List<SavedArtwork>> getSavedArtworks() async {
    final data = _prefs.getString(_artworksKey);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => SavedArtwork.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveArtwork(SavedArtwork artwork) async {
    final artworks = await getSavedArtworks();
    final index = artworks.indexWhere((a) => a.id == artwork.id);

    if (index >= 0) {
      artworks[index] = artwork;
    } else {
      artworks.insert(0, artwork);
    }

    await _prefs.setString(
      _artworksKey,
      jsonEncode(artworks.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> deleteArtwork(String id) async {
    final artworks = await getSavedArtworks();
    artworks.removeWhere((a) => a.id == id);

    await _prefs.setString(
      _artworksKey,
      jsonEncode(artworks.map((a) => a.toJson()).toList()),
    );

    // Delete files
    final artworkFile = File('${_artworksDir.path}/$id.png');
    final thumbnailFile = File('${_artworksDir.path}/${id}_thumb.png');

    if (await artworkFile.exists()) {
      await artworkFile.delete();
    }
    if (await thumbnailFile.exists()) {
      await thumbnailFile.delete();
    }
  }

  // Image saving
  Future<String> saveArtworkImage(String id, Uint8List imageData) async {
    final file = File('${_artworksDir.path}/$id.png');
    await file.writeAsBytes(imageData);
    return file.path;
  }

  Future<String> saveThumbnail(String id, Uint8List thumbnailData) async {
    final file = File('${_artworksDir.path}/${id}_thumb.png');
    await file.writeAsBytes(thumbnailData);
    return file.path;
  }

  Future<String> saveImportedImage(Uint8List imageData) async {
    final uuid = const Uuid();
    final id = uuid.v4();
    final file = File('${_importedDir.path}/$id.png');
    await file.writeAsBytes(imageData);
    return file.path;
  }

  // Imported Images
  Future<List<ColoringImage>> getImportedImages() async {
    final data = _prefs.getString(_importedImagesKey);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => ColoringImage.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveImportedImageMetadata(ColoringImage image) async {
    final images = await getImportedImages();
    images.insert(0, image);

    await _prefs.setString(
      _importedImagesKey,
      jsonEncode(images.map((i) => i.toJson()).toList()),
    );
  }

  Future<void> deleteImportedImage(String id) async {
    final images = await getImportedImages();
    final image = images.firstWhere((i) => i.id == id, orElse: () => ColoringImage(id: '', name: '', category: '', imagePath: ''));

    if (image.id.isNotEmpty) {
      final file = File(image.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    images.removeWhere((i) => i.id == id);
    await _prefs.setString(
      _importedImagesKey,
      jsonEncode(images.map((i) => i.toJson()).toList()),
    );
  }

  String get artworksPath => _artworksDir.path;
  String get importedPath => _importedDir.path;
}
