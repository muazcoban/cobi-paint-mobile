import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/coloring_image.dart';
import '../models/category.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _initialized = true;
    } catch (e) {
      print('Firebase initialization error: $e');
      // App can work offline without Firebase
    }
  }

  bool get isInitialized => _initialized;

  // Categories from Firebase
  Future<List<Category>> getCategories() async {
    if (!_initialized || _firestore == null) return [];

    try {
      final snapshot = await _firestore!
          .collection('categories')
          .orderBy('order')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['isFromFirebase'] = true;
        return Category.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Images from Firebase for a category
  Future<List<ColoringImage>> getImagesForCategory(String categoryId) async {
    if (!_initialized || _firestore == null) return [];

    try {
      final snapshot = await _firestore!
          .collection('images')
          .where('category', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['isFromFirebase'] = true;
        return ColoringImage.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  // All Firebase images
  Future<List<ColoringImage>> getAllImages() async {
    if (!_initialized || _firestore == null) return [];

    try {
      final snapshot = await _firestore!
          .collection('images')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['isFromFirebase'] = true;
        return ColoringImage.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching all images: $e');
      return [];
    }
  }

  // Download image from Firebase Storage
  Future<Uint8List?> downloadImage(String path) async {
    if (!_initialized || _storage == null) return null;

    try {
      final ref = _storage!.ref(path);
      final data = await ref.getData();
      return data;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  // Get download URL for an image
  Future<String?> getImageUrl(String path) async {
    if (!_initialized || _storage == null) return null;

    try {
      final ref = _storage!.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting image URL: $e');
      return null;
    }
  }

  // Stream of new images (for real-time updates)
  Stream<List<ColoringImage>>? getImagesStream(String categoryId) {
    if (!_initialized || _firestore == null) return null;

    return _firestore!
        .collection('images')
        .where('category', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              data['isFromFirebase'] = true;
              return ColoringImage.fromJson(data);
            }).toList());
  }

  // Check for updates
  Future<DateTime?> getLastUpdateTime() async {
    if (!_initialized || _firestore == null) return null;

    try {
      final doc = await _firestore!.collection('meta').doc('lastUpdate').get();
      if (doc.exists) {
        final timestamp = doc.data()?['timestamp'] as Timestamp?;
        return timestamp?.toDate();
      }
      return null;
    } catch (e) {
      print('Error getting last update time: $e');
      return null;
    }
  }

  // Upload user artwork (optional feature)
  Future<String?> uploadArtwork(String userId, Uint8List imageData, String filename) async {
    if (!_initialized || _storage == null) return null;

    try {
      final ref = _storage!.ref('user_artworks/$userId/$filename');
      await ref.putData(imageData, SettableMetadata(contentType: 'image/png'));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading artwork: $e');
      return null;
    }
  }
}
