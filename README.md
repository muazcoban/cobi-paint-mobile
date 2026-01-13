# Cobi Paint 🎨

Çocuklar için eğlenceli ve yaratıcı bir boyama uygulaması.

## Özellikler

### Temel Özellikler
- 🎨 **Renkli Palet**: Çocuk dostu geniş renk seçenekleri
- 🖼️ **Kategoriler**: Hayvanlar, Bitkiler, Araçlar, Karakterler ve daha fazlası
- 💾 **Kaydetme**: Boyadığınız resimleri kaydedin ve daha sonra devam edin
- ↩️ **Geri Al/İleri Al**: Hataları kolayca düzeltin
- 🔍 **Yakınlaştırma**: Detaylı boyama için zoom özelliği

### İçe Aktarma
- 📸 **Kamera/Galeri**: Kendi fotoğraflarınızı içe aktarın
- ✨ **Otomatik Dönüştürme**: Resimleri boyama sayfasına çevirin
- 📊 **Günlük Limit**: Free: 3/gün, Pro: Sınırsız

### Paylaşım
- 📱 **WhatsApp**: Arkadaşlarınızla paylaşın
- 📷 **Instagram**: Eserlerinizi sergileyin
- 🔗 **Diğer**: Tüm sosyal medya platformları

### Ebeveyn Kontrolü
- 🔐 **PIN Koruması**: Ayarlara erişimi sınırlayın
- 👨‍👩‍👧 **Güvenli Kullanım**: Çocuklar için güvenli ortam

### Pro Özellikler
- ♾️ Sınırsız içe aktarma
- 🆕 Özel boyama resimleri
- 🚫 Reklamsız deneyim

## Kurulum

### Gereksinimler
- Flutter 3.10.0+
- Dart 3.0.0+
- iOS 12.0+ / Android 5.0+

### Adımlar

1. **Projeyi klonlayın**
```bash
git clone https://github.com/your-repo/cobi-paint-mobile.git
cd Cobi.Paint.Mobile
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Firebase Kurulumu**
- `firebase_setup.md` dosyasını takip edin
- `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını ekleyin

4. **Uygulamayı çalıştırın**
```bash
flutter run
```

## Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── models/                   # Veri modelleri
│   ├── category.dart
│   ├── coloring_image.dart
│   ├── saved_artwork.dart
│   └── user_settings.dart
├── providers/                # State management
│   ├── app_provider.dart
│   └── coloring_provider.dart
├── screens/                  # Ekranlar
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── category_screen.dart
│   ├── coloring_screen.dart
│   ├── my_artworks_screen.dart
│   ├── import_screen.dart
│   ├── settings_screen.dart
│   └── pro_screen.dart
├── services/                 # İş mantığı servisleri
│   ├── storage_service.dart
│   ├── firebase_service.dart
│   ├── image_processing_service.dart
│   ├── purchase_service.dart
│   └── share_service.dart
├── widgets/                  # Yeniden kullanılabilir bileşenler
│   ├── color_palette.dart
│   └── coloring_canvas.dart
├── theme/                    # Tema ve stiller
│   └── app_theme.dart
└── utils/                    # Yardımcı fonksiyonlar
    ├── constants.dart
    └── sample_images_generator.dart
```

## Boyama Resimleri Ekleme

### Statik Resimler
1. `assets/images/categories/{kategori}/` klasörüne PNG resmi ekleyin
2. `pubspec.yaml` dosyasında assets yolunu tanımlayın
3. `app_provider.dart` dosyasında `_loadStaticImages()` metoduna ekleyin

### Firebase Resimleri
1. Firebase Storage'a resmi yükleyin
2. Firestore'da metadata ekleyin
3. Uygulama otomatik olarak çekecektir

## In-App Purchase Kurulumu

### iOS (App Store Connect)
1. App Store Connect'te uygulama oluşturun
2. In-App Purchase ekleyin:
   - `cobi_paint_pro_monthly` (Aylık abonelik)
   - `cobi_paint_pro_lifetime` (Tek seferlik)

### Android (Google Play Console)
1. Google Play Console'da uygulama oluşturun
2. Ürün ekleyin (aynı ID'ler ile)

## Lisans

Bu proje özel lisans altındadır. Tüm hakları saklıdır.

## İletişim

- Email: support@cobipaint.com
- Website: https://cobipaint.com

---

Made with ❤️ for kids
