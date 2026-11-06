# Sesli yönlendirme kayıtları

Uygulama, okuma bilmeyen çocuk için kategori, renk ve kapı cümlesini sesle söyler. Ses dosyaları
bu klasördeki listeye göre insan sesiyle kaydedilir; cihazın konuşma motoru kullanılmaz (kurul
kararı: her cihazda aynı, sıcak ve lisansı temiz bir ses).

## Kurallar

- Biçim: MP3, mono, 44,1 kHz, 96 kbps; her klip 0,5–1,5 sn; başında ve sonunda 50 ms sessizlik.
- Ses seviyesi: tüm klipler aynı seviyeye normalize edilir (−16 LUFS hedef).
- Aynı seslendirmen iki dili de okur; sakin, sıcak, biraz yavaş. Çocuğa seslenir ("Kırmızı!").
- Dosya adı `<anahtar>.mp3`, klasör `assets/voice/tr/` ve `assets/voice/en/`.
- Klipler eklendikten sonra `pubspec.yaml`'a `- assets/voice/tr/` ve `- assets/voice/en/` satırları
  eklenir. Eksik klip sessizce atlanır; uygulama kayıtlar olmadan da çalışır.
- Kapı cümlesi rakamları asla okumaz; yalnız "bir büyüğüne sor" der.

## Kayıt listesi

| Anahtar | Türkçe | English |
|---|---|---|
| gate | Burayı bir büyüğün açması gerekiyor. | Ask a grown-up to open this. |
| draw | Çiz! | Draw! |
| artworks | Resimlerim | My pictures |
| category_animals | Hayvanlar | Animals |
| category_plants | Bitkiler | Plants |
| category_food | Yiyecekler | Food |
| category_vehicles | Araçlar | Vehicles |
| category_nature | Doğa | Nature |
| category_things | Eşyalar | Things |
| category_space | Uzay | Space |
| category_music | Müzik | Music |
| category_clothes | Giysiler | Clothes |
| color_0 | Kırmızı | Red |
| color_1 | Turuncu | Orange |
| color_2 | Sarı | Yellow |
| color_3 | Yeşil | Green |
| color_4 | Mavi | Blue |
| color_5 | Mor | Purple |
| color_6 | Pembe | Pink |
| color_7 | Kahverengi | Brown |
| color_8 | Siyah | Black |
| color_9 | Açık mavi | Light blue |
| color_10 | Açık yeşil | Light green |
| color_11 | Şeftali | Peach |
| color_12 | Açık sarı | Light yellow |
| color_13 | Lacivert | Navy |
| color_14 | Koyu yeşil | Dark green |
| color_15 | Gri | Grey |
| eraser | Silgi | Eraser |
| fill | Boya | Paint |
| brush | Fırça | Brush |
| mirror | Ayna | Mirror |
| sticker | Çıkartma | Sticker |
| rainbow | Gökkuşağı | Rainbow |
| crayon | Pastel | Crayon |
| spray | Sprey | Spray |
| glitter | Sim | Glitter |
| neon | Neon | Neon |
| undo | Geri al | Undo |

Renk sırası `lib/screens/coloring_screen.dart` içindeki `littlePalette` ve `bigPalette` sırasıdır;
`color_9`–`color_15` yalnız Büyük modda duyulur. Renk adları `lib/l10n/app_*.arb` dosyasındaki
`colorNames` listesiyle aynı olmalıdır.

Sayfa adları (323 sayfa × 2 dil) ikinci aşamadır: anahtar `page_<kod>` (ör. `page_1f34e`),
metin `tool/pages/catalog.json` içindeki `nameTr` ve `nameEn`.

## Manzara kelimeleri (kurul P7, yalnız Manzara modu)

Manzara modu, bu 20 klibin hepsi paketteyken görünür (`lib/data/scene_gate.dart`); bir test
listenin tamamını `gardenScene.clipPaths()` ile denetler. Anahtar İngilizce kelimedir: ileride
aynı kelimeyi kullanan iki parça (lale ve papatya, ikisi de flower) aynı klibi paylaşır.

- Türkçe uygulama çift çalar: Türkçe kelime, yaklaşık 0,5 sn ara, İngilizce kelime ("Çiçek…
  flower!"). İngilizce uygulama yalnız İngilizce kelimeyi çalar.
- İngilizce kelimeleri anadili İngilizce ya da o düzeyde konuşan bir ses, ABD İngilizcesiyle okur.
  Yukarıdaki "aynı seslendirmen iki dili okur" kuralının tek istisnası budur; Türkçe seslendirmen bu
  düzeydeyse istisna gerekmez. Telaffuzu bir İngilizce öğretmeni ya da anadili İngilizce biri dinler.
- Tek kelime, artikelsiz, çocuğa seslenerek okunur ("Sun!"). Seslendirmenlerden yazılı hak devri
  alınır.
- Kaba prototipte (gözlem turu 1) klip yoktur; kelimeyi gözlemci ya da ebeveyn söyler. Sahibin
  sesiyle yapılan geçici kayıt yalnız gözlem cihazında kalır, pakete girmez.

| Anahtar | Türkçe | English |
|---|---|---|
| scene | Manzara! | Scene! |
| word_sun | Güneş | sun |
| word_house | Ev | house |
| word_tree | Ağaç | tree |
| word_flower | Çiçek | flower |
| word_cloud | Bulut | cloud |
| word_bird | Kuş | bird |
| word_sky | Gökyüzü | sky |
| word_grass | Çimen | grass |
| word_river | Nehir | river |
