import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_artwork.dart';
import '../models/user_settings.dart';
import '../models/coloring_image.dart';

/// Relative paths written by [StorageService.writeArtworkFiles].
class ArtworkFiles {
  const ArtworkFiles({required this.image, required this.thumbnail});

  final String image;
  final String thumbnail;
}

class StorageService {
  StorageService({Future<Directory> Function()? documentsDirectory})
      : _documentsDirectory = documentsDirectory ?? getApplicationDocumentsDirectory;

  static const String _artworksKey = 'saved_artworks';
  static const String _settingsKey = 'user_settings';
  static const String _importedImagesKey = 'imported_images';

  final Future<Directory> Function() _documentsDirectory;
  late SharedPreferences _prefs;
  late Directory _appDir;
  late Directory _artworksDir;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _appDir = await _documentsDirectory();

    _artworksDir = Directory('${_appDir.path}/artworks');

    if (!await _artworksDir.exists()) {
      await _artworksDir.create(recursive: true);
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

    // Version 2 folder and version 1 files
    final folder = _artworkFolder(id);
    if (await folder.exists()) {
      await folder.delete(recursive: true);
    }
    for (final name in ['$id.png', '${id}_thumb.png']) {
      final file = File('${_artworksDir.path}/$name');
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  // Version 2 artwork files: artworks/<id>/{doc.json,image.png,thumb.png}
  Directory _artworkFolder(String id) => Directory('${_artworksDir.path}/$id');

  /// Writes the drawing and its pictures; returns the paths to store in
  /// [SavedArtwork], relative to the documents folder.
  Future<ArtworkFiles> writeArtworkFiles(
    String id, {
    required Map<String, Object?> document,
    required Uint8List imagePng,
    required Uint8List thumbnailPng,
  }) async {
    final folder = _artworkFolder(id);
    await folder.create(recursive: true);
    await _writeAtomically(File('${folder.path}/doc.json'), utf8.encode(jsonEncode(document)));
    await _writeAtomically(File('${folder.path}/image.png'), imagePng);
    await _writeAtomically(File('${folder.path}/thumb.png'), thumbnailPng);
    // A migrated version 1 artwork no longer needs its old flat files.
    for (final name in ['$id.png', '${id}_thumb.png']) {
      final legacy = File('${_artworksDir.path}/$name');
      if (await legacy.exists()) await legacy.delete();
    }
    return ArtworkFiles(image: 'artworks/$id/image.png', thumbnail: 'artworks/$id/thumb.png');
  }

  Future<Map<String, Object?>?> readArtworkDocument(String id) async {
    final file = File('${_artworkFolder(id).path}/doc.json');
    if (!await file.exists()) return null;
    try {
      final json = jsonDecode(await file.readAsString());
      return json is Map<String, Object?> ? json : null;
    } catch (_) {
      return null;
    }
  }

  /// Finds a stored artwork file. Relative paths are resolved against the
  /// documents folder; a version 1 absolute path from an older app
  /// container is looked up by file name in today's artworks folder.
  File resolveArtworkFile(String storedPath) {
    if (storedPath.isEmpty) return File('');
    if (!storedPath.startsWith('/')) return File('${_appDir.path}/$storedPath');
    final file = File(storedPath);
    if (file.existsSync()) return file;
    final name = storedPath.split('/').last;
    return File('${_artworksDir.path}/$name');
  }

  Future<void> _writeAtomically(File target, List<int> bytes) async {
    final temp = File('${target.path}.tmp');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(target.path);
  }

  // Pages imported before the photo import freeze (read-only)
  Future<List<ColoringImage>> getImportedImages() async {
    final data = _prefs.getString(_importedImagesKey);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => ColoringImage.fromJson(json)).toList();
    }
    return [];
  }
}
