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

Sayfa adları (201 sayfa × 2 dil) ikinci aşamadır: anahtar `page_<kod>` (ör. `page_1f34e`),
metin `tool/pages/catalog.json` içindeki `nameTr` ve `nameEn`.
