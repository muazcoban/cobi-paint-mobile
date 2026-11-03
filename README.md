# Cobi Paint 🎨

3 yaş ve üstü çocuklar için boyama uygulaması.

Uygulama yeniden yapılandırılıyor. Yol haritası ve gerekçeler `plan/cobi-paint-yeniden-dogus-plani.html` dosyasında. Her değişiklikte ilk ölçüt şudur: 3 yaşındaki bir çocuk bunu kullanabilir mi?

## Bugünkü özellikler

- 🎨 **Dokun ve boya**: Bölgeye dokununca seçili renkle dolar.
- ✏️ **Kalem ve silgi**
- 🖼️ **Kategoriler**: Hayvanlar, Bitkiler, Yiyecekler, Araçlar, Doğa, Eşyalar (201 sayfa, 3 zorluk seviyesi) ve serbest çizim sayfası. Serbest sayfada ayna çizimi: Minik'te tek düğmeyle dört yönlü, Büyük'te iki, dört ya da altı yönlü simetri. Fırça düğmesi keçeli kalem, gökkuşağı, sprey ve simli fırça arasında döner; Büyük'te pastel ve neon kalem de var. Her sayfada 16 çıkartma: aynı döngünün sonunda, dokunuş basar, sürükleme iz bırakır.
- ↩️ **Geri al / ileri al**
- 💾 **Eserlerim**: Boyanan sayfalar kaydedilir ve sonra açılabilir.
- 📤 **Paylaşım**: Sistem paylaşım menüsü; Android'de ayrıca galeriye kaydetme ve yazdırma. Hepsi ebeveyn kapısının arkasında.
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
│   └── builtin_images.dart       # Üretilmiş: 201 boyama sayfası (tool/pages/build_pages.py)
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

Sayfalar `tool/pages/catalog.json` kataloğundan üretilir; dosyalar elle eklenmez.

1. Konuyu `tool/pages/catalog.json` listesine ekle (Unicode kodu, Türkçe ve İngilizce ad, kategori).
2. `python3 tool/pages/build_pages.py --work /tmp/cobi-pages --dart ~/flutter/sdk/flutter/bin/dart` çalıştır. Betik kaynağı indirir, 1024 px'e çevirir, konturu çıkarır, sayfa denetiminden geçirir, seviyeyi hesaplar ve `assets/pages/` ile `lib/data/builtin_images.dart` dosyasını yazar.
3. `flutter test` çalıştır. `test/engine/region_builder_test.dart` her sayfanın denetimden geçtiğini ve seviyesinin doğru olduğunu kontrol eder.
4. Elle çizilmiş bir sayfa için önce `dart run tool/page_report.dart <sayfa.png>` ile ölç.

Kaynak çizimler Microsoft'un Fluent UI Emoji setinden (MIT); lisans metni `assets/licenses/` altında ve uygulamanın Ebeveynler alanında gösterilir.

## Lisans

Bu proje özel lisans altındadır. Tüm hakları saklıdır.

## İletişim

- E-posta: muazcoban@icloud.com

## Xcode Cloud ile TestFlight

App Store ve TestFlight yüklemeleri Xcode 26 ister; geliştirme Mac'inde Xcode 16.4 varsa ikiliyi
Xcode Cloud derler. Repo tarafı hazır: `ios/ci_scripts/ci_post_clone.sh` bulut makinesine Flutter
3.38.3'ü kurar, `flutter pub get` ve `pod install` çalıştırır. İlk iş akışı yalnız Xcode'dan açılır:

1. Xcode'da `ios/Runner.xcworkspace` dosyasını aç; Xcode > Settings > Accounts'ta kişisel takım
   (MUAZ COBAN) oturumu açık olsun.
2. Product > Xcode Cloud > Create Workflow. Ürün olarak Runner'ı seç, Next.
3. İş akışı özeti: Archive eylemi, Xcode sürümü "Latest Release" (26.x), dal `master`; Post-Actions'a
   "TestFlight Internal Testing" ekle. Next.
4. Kaynak erişimi: GitHub hesabına Xcode Cloud için izin ver (tarayıcıda "Authorize Xcode Cloud"),
   `muazcoban/cobi-paint-mobile` deposunu seç. Complete.
5. İlk derleme otomatik başlar (yaklaşık 25-35 dakika). Sonuç App Store Connect > Xcode Cloud ve
   TestFlight sekmelerinde görünür; iç test grubuna kendini ekle.
6. Sürüm numarası `pubspec.yaml`'dan gelir (2.1.0+5); her yeni yüklemede derleme numarasını artır.
