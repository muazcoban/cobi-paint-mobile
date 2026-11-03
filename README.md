# Cobi Paint 🎨

3 yaş ve üstü çocuklar için boyama uygulaması.

Uygulama yeniden yapılandırılıyor. Yol haritası ve gerekçeler `plan/cobi-paint-yeniden-dogus-plani.html` dosyasında. Her değişiklikte ilk ölçüt şudur: 3 yaşındaki bir çocuk bunu kullanabilir mi?

## Bugünkü özellikler

- 🎨 **Dokun ve boya**: Bölgeye dokununca seçili renkle dolar.
- ✏️ **Kalem ve silgi**
- 🖼️ **Kategoriler**: Hayvanlar, Bitkiler, Yiyecekler, Araçlar, Doğa, Eşyalar (201 sayfa, 3 zorluk seviyesi) ve serbest çizim sayfası. Serbest sayfada ayna çizimi: Minik'te tek düğmeyle dört yönlü, Büyük'te iki, dört ya da altı yönlü simetri.
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
