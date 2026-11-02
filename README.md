# Cobi Paint 🎨

3 yaş ve üstü çocuklar için boyama uygulaması.

Uygulama yeniden yapılandırılıyor. Yol haritası ve gerekçeler `plan/cobi-paint-yeniden-dogus-plani.html` dosyasında. Her değişiklikte ilk ölçüt şudur: 3 yaşındaki bir çocuk bunu kullanabilir mi?

## Bugünkü özellikler

- 🎨 **Dokun ve boya**: Bölgeye dokununca seçili renkle dolar.
- ✏️ **Kalem ve silgi**
- 🖼️ **Kategoriler**: Hayvanlar, Bitkiler, Araçlar, Karakterler, Doğa, Yiyecekler (76 sayfa).
- ↩️ **Geri al / ileri al**
- 💾 **Eserlerim**: Boyanan sayfalar kaydedilir ve sonra açılabilir.
- 📤 **Paylaşım**: Sistem paylaşım menüsü.
- 🔊 **Ses efektleri**

Uygulamada reklam, internet bağlantısı ve hesap yok.

### Kaldırılanlar ve dondurulanlar (Faz 0)

- **Firebase**: Yapılandırılmamıştı ve kullanılmıyordu. Ayrıca iOS derlemesini kırıyordu. Tamamen kaldırıldı.
- **Reklamlar (AdMob)**: Çocuk ekranında reklam olmayacak. Kaldırıldı.
- **Uygulama içi satın alma**: Arayüze hiçbir yerden ulaşılamıyordu. Buna rağmen her açılışta satın alma geri yükleme çağrısı yapılıyordu. Kaldırıldı. Faz 4'te ebeveyn kapısının arkasında yeniden kurulacak. Mağazadaki ürün kimlikleri: `cobi_paint_pro_monthly`, `cobi_paint_pro_lifetime`.
- **Fotoğraftan boyama sayfası (OpenCV)**: Yeni boyama motoru gelene kadar donduruldu. Daha önce içe aktarılmış sayfalar "İçe Aktar" kategorisinde görünmeye devam eder.

## Kurulum

### Gereksinimler

- Flutter 3.38+ (Dart 3.10+)
- iOS 15.0+ / Android (Flutter'ın varsayılan `minSdk` değeri)

### Adımlar

```bash
git clone https://github.com/muazcoban/cobi-paint-mobile.git
cd cobi-paint-mobile
flutter pub get
flutter run
```

### Kontroller

```bash
flutter analyze
flutter test
```

GitHub Actions her pull request'te ve `master`'a her push'ta bu iki komutu çalıştırır (`.github/workflows/ci.yml`).

## Proje yapısı

```
lib/
├── main.dart                     # Uygulama giriş noktası
├── data/
│   └── builtin_images.dart       # Uygulamayla gelen 76 boyama sayfası
├── models/                       # Category, ColoringImage, SavedArtwork, UserSettings
├── providers/
│   ├── app_provider.dart         # Ayarlar, kategoriler, eserler
│   ├── coloring_provider.dart    # Dolgu, kalem, silgi, geri al
│   └── locale_provider.dart      # Dil seçimi (TR/EN)
├── screens/                      # Splash, ana ekran, kategori, boyama, eserlerim, ayarlar
├── services/                     # Depolama, paylaşım, ses, küçük resim
├── theme/                        # Tema ve renkler
├── utils/                        # Boya dokuları
└── widgets/                      # Boyama tuvali, renk paleti
plan/                             # Yol haritası, ekran görüntüleri, ölçüm araçları
tool/                             # Geçici yer tutucu sayfa üreticisi
```

## Boyama sayfası ekleme

1. PNG dosyasını `assets/images/categories/{kategori}/` klasörüne koy.
2. Klasör yeniyse `pubspec.yaml` içindeki `assets` listesine ekle.
3. Sayfayı `lib/data/builtin_images.dart` listesine ekle.
4. `flutter test` çalıştır. `test/builtin_images_test.dart` dosyanın varlığını, açılabildiğini ve `pubspec.yaml` içinde tanımlı olduğunu kontrol eder.

Faz 3'te sayfalar SVG kaynaktan üretilecek ve sızıntı kontrolünden geçecek (plan raporunun 8. bölümü).

## Lisans

Bu proje özel lisans altındadır. Tüm hakları saklıdır.

## İletişim

- E-posta: muazcoban@icloud.com
