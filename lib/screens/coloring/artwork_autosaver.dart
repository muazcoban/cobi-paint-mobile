import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:uuid/uuid.dart';

import '../../engine/document/coloring_document.dart';
import '../../engine/render/artwork_renderer.dart';
import '../../models/coloring_image.dart';
import '../../models/saved_artwork.dart';
import '../../providers/app_provider.dart';

/// Saves the drawing on its own: shortly after every change, when the child
/// leaves the page and when the app goes to the background. Nothing a child
/// made is lost to a back swipe, and there is no Save button to forget.
class ArtworkAutosaver {
  ArtworkAutosaver({
    required this.document,
    required this.page,
    required this.image,
    required this.app,
    SavedArtwork? existing,
    this.delay = const Duration(milliseconds: 1200),
  }) : _artwork = existing;

  final ColoringDocument document;
  final ui.Image page;
  final ColoringImage image;
  final AppProvider app;
  final Duration delay;

  SavedArtwork? _artwork;
  Timer? _timer;
  bool _saving = false;
  bool _again = false;
  bool _dirty = false;

  SavedArtwork? get artwork => _artwork;

  void start() => document.addListener(_changed);

  /// Marks the document as changed without an edit, e.g. after migrating a
  /// version 1 artwork, so it is written in the new format.
  void markDirty() => _changed();

  void _changed() {
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(delay, () => unawaited(flush()));
  }

  /// Writes now if anything changed since the last save.
  Future<void> flush() async {
    _timer?.cancel();
    if (!_dirty) return;
    if (_saving) {
      _again = true;
      return;
    }
    // An untouched page is not worth a gallery entry.
    if (document.isEmpty && _artwork == null) {
      _dirty = false;
      return;
    }
    _saving = true;
    _dirty = false;
    try {
      final pngs = await renderArtworkPngs(document, page);
      final id = _artwork?.id ?? const Uuid().v4();
      final storage = app.storageService;
      final files = await storage.writeArtworkFiles(
        id,
        document: {
          ...document.toJson(),
          'pageId': image.id,
          'pagePath': image.imagePath,
        },
        imagePng: pngs.image,
        thumbnailPng: pngs.thumbnail,
      );
      // The gallery shows the new thumbnail instead of a cached old one.
      await FileImage(storage.resolveArtworkFile(files.thumbnail)).evict();
      await FileImage(storage.resolveArtworkFile(files.image)).evict();

      final now = DateTime.now();
      final saved = SavedArtwork(
        id: id,
        originalImageId: image.id,
        originalImagePath: image.imagePath,
        savedImagePath: files.image,
        thumbnailPath: files.thumbnail,
        name: image.name,
        createdAt: _artwork?.createdAt ?? now,
        updatedAt: now,
        schema: 2,
      );
      await app.saveArtwork(saved);
      _artwork = saved;
    } catch (e) {
      // Try again on the next change rather than lose the drawing silently.
      _dirty = true;
      rethrow;
    } finally {
      _saving = false;
      if (_again) {
        _again = false;
        await flush();
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    document.removeListener(_changed);
  }
}
