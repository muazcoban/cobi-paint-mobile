# Sesli ad kayıt rehberi

Cobi Paint'in sesli adlarını kendi sesinizle ya da bir seslendirmenle kaydetmek için. 5. bölümdeki
tablolar `tool/voice/README.md` tablolarının kopyasıdır; `python3 tool/voice/build_guide.py` onları
README'den yeniden yazar, elle düzeltilmez (son kopya 8 Kasım 2026). Kaynak her zaman README'dir.

## 1. Ne kaydediyoruz, neden insan sesi

Uygulama okuma bilmeyen çocuğa dokunduğu şeyin adını söyler: ana ekranda kart adı ("Hayvanlar"),
boyama ekranında renk ve araç adı ("Kırmızı", "Silgi"), ebeveyn kapısında tek cümle. Kurul kararı:
cihazın konuşma motoru (TTS) kullanılmaz, ses insan sesiyle kaydedilir. Gerekçe: her cihazda aynı ses,
sıcak ton, lisansı temiz kayıt. Klip yoksa uygulama susar; kayıtlar olmadan da çalışır.

Bugünkü liste 54 anahtar: ana listede 44, Manzara modunda 10 (`scene` ve 9
kelime). `undo` şimdilik kaydedilmez (kodda çağrılmıyor); kalan 53 anahtar iki dilde okunur,
toplam 106 kayıt.

## 2. Ortam ve cihaz

- Sessiz, yumuşak eşyalı bir oda: perde, halı, koltuk, yatak. Yankılı mutfak ve banyo olmaz. Buzdolabı,
  klima ve bilgisayar fanı duyuluyorsa kapat; pencereyi kapat.
- Telefonla: iPhone Sesli Notlar, Ayarlar > Sesli Notlar > Ses Kalitesi > Kayıpsız. Bilgisayarla: USB
  mikrofon, 44,1 ya da 48 kHz, WAV. Kulaklık mikrofonu ve dizüstü mikrofonu olmaz.
- Mikrofona 15–20 cm; her klipte aynı mesafe ve aynı açı. P, B, T ile başlayan kelimelerde ("Pembe",
  "Boya", "Pastel") ağzı mikrofonun hafif yanına çevir; pop filtresi varsa kullan.
- Kayıt seviyesi: en yüksek sesli klipte gösterge kırmızıya çıkmasın; tepe −12 ile −6 dBFS arası iyi.
  Betik seviyeyi −16 LUFS'a eşitler ama kırpılmış (çatlayan) sesi düzeltemez.
- Önce 5 saniye oda sessizliği kaydedip kulaklıkla dinle: uğultu duyuluyorsa kaynağını bul, sonra başla.

## 3. Okuma tarzı

- Sakin, sıcak, biraz yavaş. Çocuğa seslenir: "Kırmızı!" Gülümseyerek oku; gülümseme sese geçer.
- Kısa ünlem; bağırma yok, soru tonu yok.
- Her klipte aynı enerji. Listenin ortasında ve sonunda `color_0`'ı yeniden okuyup ilk kayıtla
  karşılaştır; fark varsa o enerjiye dön.
- Her klibi arka arkaya 2–3 kez oku, en iyisini bırak. Takıldıysan dur, nefes al, baştan oku: kenar
  sessizliğini betik kırpar, kayıtta sessiz pay bırakmak sorun değil.
- Tek kelimeler tek nefeste. `gate` cümlesi doğal tempoda; kelimeler arasında kısa duraklama olabilir,
  betik klibin içindeki duraklamayı kesmez.
- Tüm listeyi tek oturumda bitirmeye çalış; ara verdiysen aynı yerde, aynı mesafede devam et.
- Çocuk sesi kaydedilmez; ses bir yetişkine aittir.

## 4. Adlandırma ve dosya düzeni

- Her klip ayrı dosya: `tool/voice/raw/tr/<anahtar>.m4a`, İngilizce için `tool/voice/raw/en/`.
  Anahtar aşağıdaki tablodaki addır, küçük harf, birebir: `category_animals`, `color_10`, `word_sun`.
  Uzantı m4a, wav, aiff, mp3, caf ya da flac olabilir; bir anahtar için tek dosya.
- Sesli Notlar'da her kaydı anahtar adıyla yeniden adlandır; AirDrop ya da Dosyalar ile Mac'e aktar.
- Tek uzun kayıt aldıysan: Audacity'de aç, Analyze > Label Sounds ile parçaları işaretle, etiketleri
  anahtar adıyla değiştir, File > Export > Export Multiple ile WAV olarak `raw/tr/` içine yaz. Kesimi
  geniş bırak; kenar sessizliğini betik kırpar.
- `tool/voice/raw/` depoya girmez (`.gitignore`); ham kayıtları ayrıca yedekle.

## 5. Kayıt sırası

Tablo README'nin iki tablosudur; numara kayıt sırasıdır. "Türkçe" sütunu `raw/tr/`, "English" sütunu
`raw/en/` kaydının metnidir; metin tablodaki gibi okunur, kelime eklenmez.

- `gate` cümlesinde rakam yoktur ve rakam okunmaz: kapı ekranı çarpım sorar, ses asla sayı söylemez.
- (*) işaretli anahtar (`undo`) tabloda kalır ama şimdilik kaydedilmez: kodda çağrılmıyor.
- `color_9`–`color_15` yalnız Büyük modda duyulur; yine de kaydedilir.
- Manzara kelimelerinde (`word_*`) Türkçe uygulama önce Türkçe kelimeyi, yarım saniye sonra İngilizce
  kelimeyi çalar; ikisi ayrı dosyadır. Türkçe klipte yalnız Türkçe kelime okunur ("Çiçek!").

### 5a. Ana liste

<!-- BEGIN README TABLE main -->
| # | Anahtar | Türkçe | English |
|---|---|---|---|
| 1 | `gate` | Burayı bir büyüğün açması gerekiyor. | Ask a grown-up to open this. |
| 2 | `draw` | Çiz! | Draw! |
| 3 | `artworks` | Resimlerim | My pictures |
| 4 | `category_animals` | Hayvanlar | Animals |
| 5 | `category_plants` | Bitkiler | Plants |
| 6 | `category_food` | Yiyecekler | Food |
| 7 | `category_vehicles` | Araçlar | Vehicles |
| 8 | `category_nature` | Doğa | Nature |
| 9 | `category_things` | Eşyalar | Things |
| 10 | `category_space` | Uzay | Space |
| 11 | `category_music` | Müzik | Music |
| 12 | `category_clothes` | Giysiler | Clothes |
| 13 | `category_celebrations` | Kutlamalar | Celebrations |
| 14 | `color_0` | Kırmızı | Red |
| 15 | `color_1` | Turuncu | Orange |
| 16 | `color_2` | Sarı | Yellow |
| 17 | `color_3` | Yeşil | Green |
| 18 | `color_4` | Mavi | Blue |
| 19 | `color_5` | Mor | Purple |
| 20 | `color_6` | Pembe | Pink |
| 21 | `color_7` | Kahverengi | Brown |
| 22 | `color_8` | Siyah | Black |
| 23 | `color_9` | Açık mavi | Light blue |
| 24 | `color_10` | Açık yeşil | Light green |
| 25 | `color_11` | Şeftali | Peach |
| 26 | `color_12` | Açık sarı | Light yellow |
| 27 | `color_13` | Lacivert | Navy |
| 28 | `color_14` | Koyu yeşil | Dark green |
| 29 | `color_15` | Gri | Grey |
| 30 | `color_16` | Karamel | Caramel |
| 31 | `color_17` | Kakao | Cocoa |
| 32 | `eraser` | Silgi | Eraser |
| 33 | `fill` | Boya | Paint |
| 34 | `fill_dots` | Benekli | Dots |
| 35 | `fill_stripes` | Çizgili | Stripes |
| 36 | `brush` | Fırça | Brush |
| 37 | `mirror` | Ayna | Mirror |
| 38 | `sticker` | Çıkartma | Sticker |
| 39 | `rainbow` | Gökkuşağı | Rainbow |
| 40 | `crayon` | Pastel | Crayon |
| 41 | `spray` | Sprey | Spray |
| 42 | `glitter` | Sim | Glitter |
| 43 | `neon` | Neon | Neon |
| 44 | `undo` (*) | Geri al | Undo |
<!-- END README TABLE main -->

### 5b. Manzara kelimeleri

<!-- BEGIN README TABLE scene -->
| # | Anahtar | Türkçe | English |
|---|---|---|---|
| 45 | `scene` | Manzara! | Scene! |
| 46 | `word_sun` | Güneş | sun |
| 47 | `word_house` | Ev | house |
| 48 | `word_tree` | Ağaç | tree |
| 49 | `word_flower` | Çiçek | flower |
| 50 | `word_cloud` | Bulut | cloud |
| 51 | `word_bird` | Kuş | bird |
| 52 | `word_sky` | Gökyüzü | sky |
| 53 | `word_grass` | Çimen | grass |
| 54 | `word_river` | Nehir | river |
<!-- END README TABLE scene -->

## 6. İngilizce klipler

- Kural: iki dili de aynı seslendirmen okur. Bu kişi İngilizceyi anadili düzeyinde ya da ona yakın
  konuşmalı; ABD İngilizcesi.
- Türkçe seslendirmen bu düzeyde değilse README'nin tek istisnası uygulanır: Manzara kelimelerini
  (`word_*`) anadili İngilizce ya da o düzeyde biri okur.
- Tek kelime, artikelsiz: "Sun!", "Red!"; "the sun" ya da "a red" değil. Çocuğa seslenir, aynı sıcak ton.
- Manzara kelimelerinin telaffuzunu bir İngilizce öğretmeni ya da anadili İngilizce biri dinleyip onaylar;
  onay olmadan klip pakete girmez.

## 7. Yazılı hak devri

Seslendirmen sizden başka biriyse kayıttan önce tek paragraflık yazılı devir alın; e-posta yeter, imzalı
PDF daha iyidir. Örnek paragraf:

> Ben [ad soyad], [tarih] tarihinde Cobi Paint uygulaması için yaptığım Türkçe ve İngilizce ses
> kayıtlarının tüm kullanım haklarını, süre ve ülke sınırı olmaksızın, uygulamanın bugünkü ve gelecek
> sürümlerinde, mağaza tanıtımlarında ve bunlardan türetilen işlerde kullanılmak üzere [sahibin adı]
> adına [bedelsiz / ... TL karşılığında] devrettiğimi; kayıtların kırpılmasına, seviyesinin
> eşitlenmesine ve biçim dönüştürülmesine itirazım olmadığını; bunun için ayrıca ücret ya da isim
> belirtilmesi istemeyeceğimi kabul ederim.

Bu metin hukuki görüş değildir. Ücretli seslendirmen ya da şirketleşme durumunda bir avukata gösterin.
Kendi sesinizle kaydediyorsanız devir gerekmez; kayıt tarihini bu dosyaya not düşmek yeter.

## 8. İşleme

Komutlar depo kökünden çalışır. ffmpeg yoksa `brew install ffmpeg`.

1. Ham dosyalar yerinde: `tool/voice/raw/tr/*.m4a` ve `tool/voice/raw/en/*.m4a`.
2. `python3 tool/voice/process_clips.py`: kenar sessizliğini kırpar, −16 LUFS'a eşitler, başa ve sona
   50 ms sessizlik koyar, `assets/voice/<dil>/<anahtar>.mp3` yazar. `WARNING` satırlarını oku: 0,5–1,5 sn
   dışı süre (`gate` ve `scene` için 3 sn) hata değildir ama yeniden kayıt gerektirebilir. Tek klip için
   `--only fill,draw --lang tr`.
3. `python3 tool/voice/process_clips.py --check`: eksik ve fazla klip, biçim, süre. Eksik varsa çıkış
   kodu 1.
4. `python3 tool/voice/process_clips.py --pubspec`: `pubspec.yaml` dosyasına `- assets/voice/tr/` ve
   `- assets/voice/en/` satırlarını ekler, yalnız dolu klasörler için; ikinci çalıştırma bir şey değiştirmez.
5. `flutter test test/voice_clips_test.dart` yeşil olmalı: kod, README ve klipler aynı listeyi anlatıyor.
6. `flutter run` ile cihazda dene. Ebeveyn alanındaki "Sesli adlar" anahtarı yalnız klipler paketteyken
   görünür; açıkken ana ekranda bir karta, boyama ekranında bir renge ve silgiye dokun, kapıyı aç.
   VoiceOver açıkken uygulama susmalı. Ses seviyesini bir efekt sesiyle (dokunma tıkı) karşılaştır.

## 9. İkinci aşama: sayfa adları

323 sayfa × 2 dil, anahtar `page_<kod>` (ör. `page_1f34e`), metin `tool/pages/catalog.json` içindeki
`nameTr` ve `nameEn`. Şimdi kaydedilmez; o aşamada bu rehbere ayrı bir tablo eklenir ve aynı betik işler.
