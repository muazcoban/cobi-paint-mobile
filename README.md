# Cobi Paint 🎨

3 yaş ve üstü çocuklar için boyama uygulaması.

Uygulama yeniden yapılandırılıyor. Yol haritası ve gerekçeler `plan/cobi-paint-yeniden-dogus-plani.html` dosyasında. Her değişiklikte ilk ölçüt şudur: 3 yaşındaki bir çocuk bunu kullanabilir mi?

## Bugünkü özellikler

- 🎨 **Dokun ve boya**: Bölgeye dokununca seçili renkle dolar.
- ✏️ **Kalem ve silgi**: Keçeli kalemle bir alanın neredeyse tamamı tek renkle boyanınca kalan küçük beyaz köşeler kendiliğinden dolar (Ebeveynler alanında kapatılabilir). Büyük modda iPad'de Apple Pencil ile bastırdıkça keçeli kalem, pastel ve neon kalınlaşır.
- 🖼️ **Kategoriler**: Hayvanlar, Bitkiler, Yiyecekler, Araçlar, Doğa, Eşyalar, Uzay, Müzik, Giysiler (307 sayfa, 3 zorluk seviyesi) ve serbest çizim sayfası. Serbest sayfada ayna çizimi: Minik'te tek düğmeyle dört yönlü, Büyük'te iki, dört ya da altı yönlü simetri. Fırça düğmesi keçeli kalem, gökkuşağı, sprey ve simli fırça arasında döner; Büyük'te pastel ve neon kalem de var. Her sayfada 16 çıkartma: aynı döngünün sonunda, dokunuş basar, sürükleme iz bırakır.
- ↩️ **Geri al / ileri al**
- 💾 **Eserlerim**: Boyanan sayfalar kaydedilir ve sonra açılabilir. Ebeveyn kapısının arkasında bir sayfa baştan boyanabilir; eski resim yerinde kalır.
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
│   └── builtin_images.dart       # Üretilmiş: 307 boyama sayfası (tool/pages/build_pages.py)
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
3. `flutter test` çalıştır. `test/engine/region_builder_test.dart` her sayfanın denetimden geçtiğini ve seviyesinin doğru olduğunu kontrol eder. `test/builtin_images_test.dart` kataloğun ve paketlenen sayfaların birebir eşleştiğini ve her kategoride tam 8 ücretsiz sayfa olduğunu kontrol eder.
4. Elle çizilmiş bir sayfa için önce `dart run tool/page_report.dart <sayfa.png>` ile ölç.

Kurallar:

- Kaynakta olmayan ya da denetimden geçmeyen bir konu katalogda `"skip": "<neden>"` ile kalır; betik onu atlar, test nedenin yazılı olmasını ister.
- Sayfa kimliği `<kategori>_<kod>` biçimindedir ve kayıtlı resimler bu kimliği ve dosya yolunu saklar. Yayımlanmış bir sayfanın kategorisi bu yüzden değişmez.
- Yeni kategori için: `Category.getDefaultCategories()` listesinin sonuna ekle (çocuk kartları yerinden tanır, eski kartlar yer değiştirmez), ARB dosyalarına ve `lib/l10n/drafts/` taslaklarına adını yaz, `categoryName` içine ekle, `pubspec.yaml`'a klasörünü ekle, `tool/voice/README.md` kayıt listesine `category_<kimlik>` satırını yaz. Testler bunların hepsini denetler.

Kaynak çizimler Microsoft'un Fluent UI Emoji setinden (MIT); lisans metni `assets/licenses/` altında ve uygulamanın Ebeveynler alanında gösterilir.

## Lisans

Bu proje özel lisans altındadır. Tüm hakları saklıdır.

## İletişim

- E-posta: muazcoban@icloud.com

## TestFlight'a yükleme

App Store Connect, 28 Nisan 2026'dan beri yalnız Xcode 26 ve üstüyle (iOS 26 SDK) derlenmiş ikilileri
kabul ediyor. Bu Mac'teki Xcode 16.4 günlük işler için kalır; ikiliyi Xcode Cloud derler, yerel Xcode 26 yedek yoldur. Bu yol Nisan 2027'ye kadar geçerli: o tarihten sonra iOS 27 SDK (Xcode 27.1, macOS 26.6 ve
üstü) ve iPhone Duo ekran görüntüleri zorunlu olur; UIScene geçişi 2.1.1'de yapıldı. 2.1.0 iPhone Duo'da çalışır, ama
açık cihazda iç ekranın ortasında boşluklu görünür.

### Xcode Cloud ile (seçilen yol)

Apple Developer Program üyeliği ayda 25 bilgi işlem saati içerir; bir arşiv 25-35 dakika sürer. Saatler
takıma aittir: uygulama MUAZ COBAN takımında olduğu için o takımın kotası kullanılır. Repo tarafı hazır:
`ios/ci_scripts/ci_post_clone.sh` bulut makinesine Flutter 3.38.3'ü kurar, `flutter pub get` ve
`pod install` çalıştırır. İlk iş akışı yalnız Xcode'dan açılır; Xcode 16.4 yeter, bulut Xcode 26 ile derler.

1. Xcode > Settings > Accounts'ta MUAZ COBAN takımının Apple hesabı olmalı (App Store Connect'e girilen
   hesap). Sihirbazın karşılama sayfası takımı adıyla yazar; "FIMPLE..." yazıyorsa iptal et, hesabı ekle.
2. `ios/Runner.xcworkspace` açıkken Report navigator (Cmd-9) > Cloud sekmesi > Get Started (menü yolu:
   Integrate > Create Workflow). Birden çok takım varsa MUAZ COBAN'ı seç.
3. Grant Access: tarayıcıda GitHub'da "Authorize Xcode Cloud", `muazcoban/cobi-paint-mobile` deposunu seç.
4. İş akışı özeti: Archive eylemi (iOS), Xcode sürümü "Latest Release", dal `master`; Post-Actions'a
   "TestFlight Internal Testing" ekle. Edit Workflow'da sonraki derleme numarasını 6 yap: Xcode Cloud
   arşivin derleme numarasını kendi sayacından verir, pubspec'teki numara kullanılmaz. Complete; ilk
   derleme 25-35 dakika sürer, sonuç App Store Connect > Xcode Cloud ve TestFlight sekmelerinde görünür.
5. Sonraki yüklemeler: iş akışı (Xcode 26.6) yalnız etiket değişikliğinde derler, `master`'a push
   derleme başlatmaz. Sürüm çıkarken `pubspec.yaml`'daki sürüm adını artır, PR'ı merge et, sonra
   `git tag v2.2.0 && git push origin v2.2.0`. Sürüm adı `pubspec.yaml`'dan gelir, derleme numarasını
   Xcode Cloud artırır (2.1.1 derleme 8 ile çıktı). Derleme bitince TestFlight'taki "Tester" grubuna düşer.

### Yerel Xcode 26 ile (yedek yol)

Tek seferlik kurulum:

1. macOS en az 15.6 olmalı (Xcode 26.3'ün şartı; 26.4 ve sonrası macOS 26.2 ister). Sistem Ayarları >
   Genel > Yazılım Güncelleme'den macOS Sequoia 15.8.2'yi kur (3 GB, yeniden başlatma).
2. developer.apple.com/download/all adresinden `Xcode_26.3_Apple_silicon.xip` dosyasını indir (Apple
   hesabıyla giriş, yaklaşık 3 GB). Çift tıklayınca açılan `Xcode.app`'i `/Applications/Xcode-26.3.app`
   adıyla taşı; `xcode-select` 16.4'te kalır, betik 26.3'ü `DEVELOPER_DIR` ile seçer.
3. `/Applications/Xcode-26.3.app`'i bir kez aç ve ek bileşenleri kur. Xcode > Settings > Accounts'a
   MUAZ COBAN takımının (5MY44SLWZU) Apple hesabını ekle; Fimple takımındaki hesap yetmez.

Her yüklemede:

1. `pubspec.yaml` içindeki derleme numarasını artır (2.1.0+5 → 2.1.0+6 gibi); aynı sürümde aynı numara
   ikinci kez yüklenemez.
2. `tool/release/ios_testflight.sh` IPA'yı üretir (`build/ios/ipa/`); sorun yoksa
   `tool/release/ios_testflight.sh --upload` App Store Connect'e gönderir. İmza otomatik
   (`ios/ExportOptions.plist`, `ios/ExportOptionsUpload.plist`).
3. İşleme 10-30 dakika sürer; derleme App Store Connect > TestFlight'ta görünür. İç test grubuna kendini
   ekle, sonra sürüm sayfasında "Build" bölümüne bu derlemeyi seç.
