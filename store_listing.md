# Cobi Paint - Store Listing

Bu dosya mağaza metinlerinin kaynağıdır. Gövde 2.3.0 metnidir; canlı 2.2.0'dan farklı satırlar
"2.2.0'da (canlı)" notuyla işaretlidir. Türkçe birincil, İngilizce (ABD) ikinci dil. Google Play kaydı yok.

> **Durum (9 Kasım 2026):** 2.2.0 yeni adıyla 8 Kasım 07:49'dan beri App Store'da. 2.3.0 `release/2.3.0`
> dalında hazırlandı (sürüm 2.3.0+10; PR #16 ile master'a giren Dalga 1 işi): bu dosyadaki 2.3.0 metinleri
> (tanıtım metni, açıklamadaki satırlar, What's New, Notes for Review) ve dört ekran görüntüsü seti
> (`build/store_screenshots/*_230_captioned`; iPhone 6,3" ve 13" iPad, TR ve EN, sekizer kare). Sıra: PR
> merge → `v2.3.0` etiketi (Xcode Cloud derler) → TestFlight → App Store Connect'te 2.3.0 sürümü (build,
> metinler, kareler, yayın elle) → "Add for Review" ve "Submit for Review" sahibin işi. Sesli adlar bu
> sürümde yok; kayıt bekliyor. Sürüm notunda puan istemeden söz edilmez (5.6.3).

> **Durum (7 Kasım 2026):** 2.1.0, 4 Kasım 20:07'den beri App Store'da. 2.2.0 sürümü App Store Connect'te
> açıldı ve bu dosyadaki 2.2.0 metinleriyle dolduruldu: build 9, tanıtım metni ve açıklamadaki iki satır (TR,
> EN), What's New (TR, EN), Notes for Review ve dört ekran görüntüsü seti (iPhone ve 13" iPad, TR ve EN,
> yedişer kare, `build/store_screenshots/*_220_secili_captioned`). Yayın elle. "Add for Review" ve
> "Submit for Review" sahibin işi. Notes for Review'a 2.1.0 notunun giriş paragrafı ve Tam Sürüm cümlesi de
> girdi; mağazadaki tam metin aşağıdaki maddelerden biraz uzun.

> **2.2.0 (5 Kasım 2026'da hazırlandı):** Repoda 9 kategoride 323 sayfa var. Yeni kategoriler Uzay (14),
> Müzik (17) ve Giysiler (26); Doğa 32, Bitkiler 26, Eşyalar 49, Araçlar 32 sayfaya çıktı. 2.1.0 (App
> Review) ve 2.1.1 (TestFlight) bu sayfaları içermez, bu yüzden aşağıdaki 201 / 6 kategori / "200'den fazla"
> sayıları o iki sürüm için doğrudur ve şimdi değişmez. Yeni sayılar bu içerikle çıkan sürümde App Store
> Connect'e yazılır; bu iş App Store Connect'i değiştirmedi. Sayı geçen her yerin altında o sürümün metni
> "2.2.0'da" notuyla duruyor. "Notes for Review" alanı da üç yeni kategoriyi ve 122 yeni
> sayfayı anlatmalı (App Review 2.3.1). Ayrıntı: `plan/icerik-genisletme-2026-11-05.html`.

## App Name (30 karakter)

2.2.0'dan itibaren (7 Kasım 2026'da App Store Connect'e yazıldı; gerekçe ve ölçüm
`plan/isim-arastirmasi-2026-11-07.html`):
- TR: **Cobi: Çocuk Boyama Oyunları** (27)
- EN: **Cobi: Coloring Games for Kids** (29)

2.1.0'da: "Cobi Paint: Çocuk Boyama" (24) ve "Cobi Paint: Kids Coloring" (25). Telefonun ana ekranındaki ad
"Cobi Paint" kalıyor.

## Subtitle (30 karakter)

2.2.0'dan itibaren:
- TR: İnternetsiz, reklamsız 3-5 yaş (30)
- EN: Toddler drawing book, no ads (28)

2.1.0'da: "Küçük eller için boyama kitabı" (30) ve "Coloring book for little hands" (30).

## Promotional Text (170 karakter)
- TR: Yepyeni Cobi Paint: 6 kategoride 201 boyama sayfası, taşmayan tek dokunuş dolgu, 6 fırça, 16 çıkartma ve aynalı serbest çizim. Reklam yok, internet yok, hesap yok. (163)
- EN: New Cobi Paint: 201 coloring pages in 6 categories, one-tap fill that stays in the lines, 6 brushes, 16 stickers and mirror drawing. No ads, no internet, no accounts. (166)

2.2.0'da (canlı) yalnız sayılar değişti:
- TR: Yepyeni Cobi Paint: 9 kategoride 323 boyama sayfası, taşmayan tek dokunuş dolgu, 6 fırça, 16 çıkartma ve aynalı serbest çizim. Reklam yok, internet yok, hesap yok. (163)
- EN: New Cobi Paint: 323 coloring pages in 9 categories, one-tap fill that stays in the lines, 6 brushes, 16 stickers and mirror drawing. No ads, no internet, no accounts. (166)

2.3.0 (App Store Connect'e yazılacak):
- TR: Yepyeni Cobi Paint: 10 kategoride 336 boyama sayfası, taşmayan tek dokunuş dolgu, 6 fırça, 16 çıkartma ve aynalı serbest çizim. Reklam yok, internet yok, hesap yok. (164)
- EN: New Cobi Paint: 336 coloring pages in 10 categories, one-tap fill that stays in the lines, 6 brushes, 16 stickers and mirror drawing. No ads, no internet, no accounts. (167)

---

## Short Description (80 characters max)

### Turkish
Küçük eller için boyama: dokun, boya. Boya çizgiden taşmaz, iş kaybolmaz.

### English
Coloring for little hands: tap to fill, no paint outside the lines.

---

## Full Description

### Turkish
🎨 **Cobi Paint – 3 yaş ve üstü için boyama**

Cobi Paint, okumayı henüz bilmeyen çocuklar düşünülerek tasarlandı. Kocaman düğmeler, tek dokunuşla
boyama ve otomatik kayıt sayesinde çocuğunuz yardım istemeden boyar.

**✨ Özellikler**

🖼️ **10 kategoride 300'den fazla boyama sayfası, 3 zorluk seviyesi**
- Hayvanlar, Bitkiler, Yiyecekler, Araçlar, Doğa, Eşyalar, Uzay, Müzik, Giysiler, Kutlamalar

> 2.2.0'da (canlı): "9 kategoride" ve liste Giysiler'de bitiyor.

🎨 **Taşmayan boya**
- Bir bölgeye dokunmak onu anında boyar; boya çizgilerden taşmaz, beyaz kenar kalmaz.
- Kovaya bir daha dokunun: benekli dolgu; Büyük modda çizgili ve gökkuşağı da.
- Keçeli kalem, başladığı bölgenin içinde kalır.
- Silgi ve her zaman görünen geri al düğmesi.
- 16 çıkartma: dokununca yapışır, sürükleyince iz bırakır; silgiyle çıkar.

✏️ **Serbest çizim**
- Fırçalar: keçeli kalem, gökkuşağı, sprey ve simli fırça; Büyük'te pastel ve neon kalem de var.
- Ayna: karalama simetrik bir desene dönüşür (Minik'te dört yönlü; Büyük'te iki, dört ya da altı yönlü).

👶 **Küçük eller için**
- Okuma gerektirmez; düğmeler kocaman ve resimli.
- Boyama kendiliğinden kaydedilir; çocuk sayfadan çıkınca da iş kaybolmaz.
- Kaldığı resme dokununca boyamaya kaldığı yerden devam eder.
- Biten resim kısa bir konfetiyle kutlanır ve çocuğun kendi resmi bir an kıpırdar.

🧒 **İki mod**
- Minik (3–5 yaş): 9 renk, yakınlaştırma yok.
- Büyük (6+ yaş): 18 renk, iki parmakla yakınlaştırma, fırça boyutları, ileri al.

> 2.2.0'da (canlı): kova satırı yok, kutlama satırı "Biten resim kısa bir konfetiyle kutlanır.", Büyük 16 renk.

👨‍👩‍👧 **Ebeveynler için**
- Reklam yok, internet bağlantısı yok, hesap yok, veri toplanmaz.
- Paylaşım, galeriye kaydetme, yazdırma, silme ve ayarlar ebeveyn kontrolünün arkasında.
- Rehberli Erişim (Guided Access) için uygulama içi rehber.

### English
🎨 **Cobi Paint – coloring for ages 3 and up**

Cobi Paint is made for children who cannot read yet. Huge buttons, one-tap filling and automatic
saving let your child color without asking for help.

**✨ Features**

🖼️ **300+ coloring pages in 10 categories, 3 difficulty levels**
- Animals, Plants, Food, Vehicles, Nature, Things, Space, Music, Clothes, Celebrations

> 2.2.0'da (canlı): "9 categories" ve liste Clothes'ta bitiyor.

🎨 **Paint that stays in place**
- Tap an area and it fills straight away; paint never leaks over the lines and leaves no white edges.
- Tap the bucket again for dots; Big mode adds stripes and a rainbow fill.
- The marker stays inside the area it started in.
- An eraser and an undo button that is always visible.
- 16 stickers: tap to stick one, drag for a trail; the eraser peels them off.

✏️ **Free drawing**
- Brushes: marker, rainbow, spray and glitter; Big mode adds the crayon and the neon pen.
- Mirror: a scribble turns into a symmetric pattern (four-way in Little mode; two, four or six-way in Big mode).

👶 **Made for little hands**
- No reading needed; big picture buttons.
- Drawings save themselves, so nothing is lost when the child leaves a page.
- Tapping a picture they started continues where they left off.
- A short confetti celebrates a finished picture and the child's own drawing gives a little wiggle.

🧒 **Two modes**
- Little (ages 3–5): 9 colours, no zoom.
- Big (ages 6+): 18 colours, pinch to zoom, brush sizes, redo.

> 2.2.0'da (canlı): kova satırı yok, kutlama satırı "A short confetti celebrates a finished picture.", Big 16 colours.

👨‍👩‍👧 **For parents**
- No ads, no internet connection, no accounts, no data collection.
- Sharing, saving to the gallery, printing, deleting and settings sit behind a grown-up check.
- An in-app guide to Guided Access.

---

## What's New (2.3.0)

Puan isteme yazılmaz (5.6.3); sesli adlar bu sürümde olmadığı için yazılmaz. Yasak sözcükler (kurul 8 Kasım):
"canlanır", "comes alive", "animated", "hareketli karakter", "doku kütüphanesi", "yüzlerce desen".

### Turkish
- Yeni "Kutlamalar" kategorisi: kış ve yılbaşı sayfaları (kutup ayısı, çaydanlık, sıcak çikolata, mum, kayak, teleferik, çorba, tencere, turta, pasta dilimi, kalp, fiyonklu kalp, havai fişek) ve kardan adam, hediye, balon gibi sevilen sayfalar artık bir arada. Toplam 336 boyama sayfası.
- Kovaya ikinci kez dokunun: benekli dolgu; Büyük modda çizgili ve gökkuşağı dolgu.
- Biten resim artık iki kez nefes alıp hafifçe kıpırdıyor; Hareketi Azalt açıkken yalnız sessiz bir vurgu gösterilir.
- Büyük modda iki yeni renk: karamel ve kakao.

### English
- New "Celebrations" category: winter and New Year pages (polar bear, teapot, hot cocoa, candle, skis, cable car, soup, cooking pot, pie, cake slice, heart, heart with bow, fireworks) together with favourites like the snowman, the gift and the balloon. 336 coloring pages in all.
- Tap the bucket again for dotted fills; Big mode adds striped and rainbow fills.
- A finished picture now takes two little breaths and wiggles; with Reduce Motion on, only a quiet highlight shows.
- Two new colours in Big mode: caramel and cocoa.

---

## What's New (2.2.0, canlı)

2.1.0 ve 2.1.1 bu özellikleri içermez; metin yalnız 2.2.0'a yazıldı (App Review 2.3.12).

### Turkish
- 3 yeni kategori: Uzay, Müzik ve Giysiler. Toplam 323 boyama sayfası.
- Bir resmi baştan boyamak için Eserlerim'de resmi basılı tutun, ebeveyn sorusunu yanıtlayın ve "Bu sayfayı baştan boya"ya dokunun. Eski resim yerinde kalır.
- Keçeli kalemle bir alanın neredeyse tamamı boyanınca kalan küçük beyaz köşeler kendiliğinden dolar. Ebeveyn alanından kapatabilirsiniz.
- Büyük modda iPad'de Apple Pencil ile bastırdıkça keçeli kalem, pastel ve neon çizgisi kalınlaşır.

### English
- 3 new categories: Space, Music and Clothes. 323 coloring pages in all.
- To color a picture again, press and hold it in My Artworks, answer the grown-up question and tap "Colour this page again". The old picture stays.
- When the marker has covered nearly all of an area, the last small white corners fill in by themselves. You can turn this off in the Parents area.
- In Big mode on iPad, marker, pastel and neon lines get thicker as you press harder with Apple Pencil.

---

## Notes for Review (2.3.0)

App Review bu alanı İngilizce okur. Kapı bilgisi `lib/widgets/parental_gate.dart` ile doğrulandı. 2.2.0
notunun ilk üç maddesi aynen kalır; "New in this version" paragrafı değişir, puan isteme paragrafı eklenir.

- No sign-in. The app makes no network requests and collects no data.
- The Parents area opens from the grey gear at the top right of the home screen. The parental gate asks
  for the product of two numbers from 2 to 9 (always a two-digit answer); from the third wrong answer it
  locks for 30, 60 and then 120 seconds, and it closes itself after 20 seconds without a tap.
- Share, "Share blank page", "Colour this page again" and Delete are behind the same gate: press and hold
  a picture in My Artworks.
- New in this version: a Celebrations category with 13 new coloring pages, 336 in all, made from
  Microsoft's Fluent UI Emoji (MIT licence, shown in the Parents area). The bucket's second tap changes
  the fill pattern (dots; Big mode adds stripes and a rainbow); the pattern is the child's choice, nothing
  is pre-coloured. When a page is finished the child's own picture scales by 3% and tilts 1.5° for two
  seconds; no ready-made animation; skipped with Reduce Motion; any touch stops it. Two new colours in Big
  mode. No new permissions and no network use.
- Rating request: the app only calls the system's review sheet (SKStoreReviewController, through the
  in_app_review plugin, the only new third-party code) after a grown-up has passed the parental gate and
  finished sharing or saving a picture, at least three days after the first launch and with at least three
  saved pictures; never on the child's screens. The Parents area has a "Rate the app" row that opens the
  App Store page (behind the gate).

### Notes for Review (2.2.0, canlı)

- New in this version: three categories (Space, Music, Clothes) with 122 new coloring pages, 323 in all,
  made from Microsoft's Fluent UI Emoji (MIT licence, shown in the Parents area). "Colour this page again"
  opens a blank copy and keeps the old picture. When the marker has covered nearly all of an area, the
  last small white corners fill in by themselves; parents can turn this off in the Parents area. In Big
  mode on iPad, Apple Pencil pressure sets the width of the marker, pastel and neon lines.

---

## Keywords / Tags

App Store anahtar kelime alanı 100 karakter, virgülle, boşluksuz; ad ve altyazıdaki kelimeler tekrar
edilmez (pazarlama incelemesi, 3 Kasım 2026).

### Turkish (96, 2.2.0'dan itibaren)
oyunu,oyun,oyunlar,çocuklar,için,kitabı,okul öncesi,bebek,resim,çizim,eğitici,anaokulu,kız,erkek

2.1.0'da (100): okul öncesi,bebek,oyunu,oyunları,oyunlar,çizim,3 yaş,eğitici,reklamsız,anaokulu,hayvan,çıkartma,renk

### English (U.S.) (97, 2.2.0'dan itibaren)
preschool,offline,painting,baby,learning,toddlers,girls,boys,art,pages,kindergarten,stickers,draw

2.1.0'da (97): toddler,preschool,drawing,games,baby,animals,stickers,no ads,learning,kindergarten,offline,colors

### English (U.K.) (99, ileride üçüncü yerelleştirme)
toddler,preschool,coloring,book,drawing,games,baby,animals,stickers,no ads,learning,nursery,offline

---

## Category and age band
- **App Store:** Birincil kategori Education, ikincil Games > Family (3 Kasım 2026'da ASC'de ayarlandı).
  Kids kategorisi: canlı kayıt "Made for Kids, 6–8 yaş" bandında; açıklama "3 yaş ve üstü" dediği için
  çelişki var. Band onaydan sonra kilitli; "5 yaş ve altı"na geçiş için App Review'a yazılı istek
  (hazır metin: plan/pazarlama-incelemesi-2026-11-03.html, 4.5).
- **Google Play:** Families (Ailelere Yönelik) programı, hedef yaş grubu 5 yaş ve altı.

---

## Age rating questionnaire notes

- **Violence, sexual content, profanity, drugs:** Hayır
- **User generated content:** Hayır. Çizimler cihazda kalır; paylaşım yalnız ebeveyn kontrolünden
  sonra, sistem paylaşım menüsüyle yapılır.
- **Messaging, social features, web access:** Hayır
- **Advertising:** Hayır
- **In-app purchases:** Hayır (bu sürümde)
- **Personal information collection:** Hayır
- Apple'ın 2025 yaş anketi ve Eylül 2026'da eklenen social media sorusu App Store Connect'te
  yanıtlanmalı.

---

## Screenshots

3 Kasım 2026: simülatörden Minik modda çekildi ve 2.1.0 taslağına yüklendi. Dosyalar `build/store_screenshots/`
altında (iphone61_tr ve iphone61_en 1206×2622, iphone69_* 1320×2868 ham, ipad13_tr 2064×2752). ASC'nin
zorunlu iPhone boyutu 6,1"/6,3" (1206×2622); 13" iPad zorunlu. Gerçek cihaz boyutlarında, uygulama
kullanılırken çekilmeli (App Review 2.3.3). Çekilen kareler:

1. Ana ekran: Eserlerim kartı ve kategoriler (2.2.0'da 9 kategori var; telefonda son
   satırlar kaydırınca görünür, yeni kare çekilecekse yeni kategoriler de görünsün)
2. Boyama: bir bölge tek dokunuşla doluyor
3. Boyama: keçeli kalem çizginin içinde kalıyor
4. Eserlerim: çocuğun boyadığı resimler
5. Ebeveyn kontrolü
6. 13" iPad yatay (2064×2752 ya da 2752×2064)

8 Kasım 2026: yürüyüşe (`integration_test/store_shots_test.dart`) Büyük modda bir desen karesi eklendi:
`08_patterns`, çaydanlık sayfasında benekli, çizgili ve gökkuşağı bölgeler, 18 renkli palet.
`tool/store/caption_screenshots.py` onu yükleme sırasında 5. kare yapar; konfeti karesinin alt yazısı
"Biten resim kıpırdar ve kutlanır", ana ekran karesi "336 boyama sayfası · 10 kategori" oldu. Yürüyüş
modu artık kendisi ayarlar (desen karesi dışında Minik). Kareler 2.3.0 yayınından önce yeniden çekilir.

9 Kasım 2026 (2.3.0): dört set yeniden çekildi: `build/store_screenshots/iphone63_tr_230`, `iphone63_en_230`
(1206×2622, CobiPaint iPhone 16 Pro simülatörü) ve `ipad13_tr_230`, `ipad13_en_230` (2064×2752, 13" iPad
Pro M4 simülatörü), her biri dokuz ham kare; `*_230_captioned` klasörlerinde sekiz alt yazılı kare yükleme
sırasında (dolgu, çizgi, kutlama, çizim, desen, ana ekran, Eserlerim, kapı) ve `_contact.png`; hepsi
`surum-230-gorseller.zip` içinde. `01b_home_end` yalnız kontrol içindir, alt yazı betiği onu atlar. App
Preview yok. Dil simülatörün ayarından geldi (`AppleLanguages`, `AppleLocale`), durum çubuğu 9:41.

---

## App icon

- 1024×1024 PNG, opak (saydam alan yok). Mevcut ikon opak; ek işlem gerekmez.

---

## Privacy Policy URL
https://muazcoban.github.io/cobi-paint-mobile/privacy_policy.html (GitHub Pages, `docs/` klasörü;
yayında olduğunu doğrula)

## Support URL
https://muazcoban.github.io/cobi-paint-mobile/ (`docs/index.html`)

## Support Email
cobipaint@gmail.com
