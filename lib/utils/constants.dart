class AppConstants {
  // App info
  static const String appName = 'Cobi Paint';
  static const String appVersion = '1.0.0';

  // Free tier limits
  static const int maxFreeImportsPerDay = 3;

  // Image settings
  static const int maxImageSize = 1024;
  static const int thumbnailSize = 200;

  // Edge detection settings
  static const int defaultEdgeThreshold = 30;
  static const int defaultLineThickness = 2;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Grid settings
  static const int categoryGridCrossAxisCount = 2;
  static const double categoryGridSpacing = 16;
  static const double categoryAspectRatio = 1.0;

  // Padding and margins
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border radius
  static const double defaultRadius = 16.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 24.0;

  // Icon sizes
  static const double smallIconSize = 20.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;

  // Firebase collections
  static const String categoriesCollection = 'categories';
  static const String imagesCollection = 'images';
  static const String usersCollection = 'users';

  // Storage keys
  static const String settingsKey = 'user_settings';
  static const String artworksKey = 'saved_artworks';
  static const String importedImagesKey = 'imported_images';
}

class AppStrings {
  // Turkish strings
  static const String welcome = 'Hoş Geldin!';
  static const String startColoring = 'Boyamaya Başla';
  static const String categories = 'Kategoriler';
  static const String myArtworks = 'Resimlerim';
  static const String settings = 'Ayarlar';
  static const String animals = 'Hayvanlar';
  static const String plants = 'Bitkiler';
  static const String vehicles = 'Araçlar';
  static const String characters = 'Karakterler';
  static const String nature = 'Doğa';
  static const String food = 'Yiyecekler';
  static const String importImage = 'İçe Aktar';
  static const String selectColor = 'Renk Seç';
  static const String save = 'Kaydet';
  static const String share = 'Paylaş';
  static const String delete = 'Sil';
  static const String undo = 'Geri Al';
  static const String redo = 'İleri Al';
  static const String clear = 'Temizle';
  static const String zoom = 'Yakınlaştır';
  static const String reset = 'Sıfırla';
  static const String saved = 'Kaydedildi!';
  static const String selectFromGallery = 'Galeriden Seç';
  static const String processing = 'İşleniyor...';
  static const String importLimitReached = 'Günlük içe aktarma limitine ulaştınız';
  static const String upgradeToPro = 'Pro\'ya Yükselt';
  static const String proFeatures = 'Sınırsız içe aktarma ve daha fazlası!';
  static const String parentControl = 'Ebeveyn Kontrolü';
  static const String enterPin = 'PIN Girin';
  static const String setPin = 'PIN Ayarla';
  static const String incorrectPin = 'Hatalı PIN';
  static const String shareViaWhatsApp = 'WhatsApp ile Paylaş';
  static const String shareViaInstagram = 'Instagram ile Paylaş';
  static const String shareOther = 'Diğer';
  static const String loading = 'Yükleniyor...';
  static const String error = 'Hata';
  static const String retry = 'Tekrar Dene';
  static const String noArtworks = 'Henüz kayıtlı resim yok';
  static const String startColoringNow = 'Hemen boyamaya başla!';
  static const String remainingImports = 'Kalan içe aktarma hakkı';
  static const String unlimited = 'Sınırsız';
  static const String daily = 'günlük';
}
