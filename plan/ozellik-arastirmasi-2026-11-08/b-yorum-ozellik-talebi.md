# B. Ebeveyn yorumlarında özellik talebi ve satın alma nedeni sinyalleri

Tarih: 8 Kasım 2026. Kapsam: 2–6 yaş çocuk boyama ve çizim uygulamaları, App Store (ABD + Türkiye) ve Google Play (ABD + Türkiye) yorumları. Para ve fiyat şikâyetleri bu çalışmanın dışında; yalnız özellik sinyalleri etiketlendi.

Etiketleme elle yapıldı: 6 kelime ve üzeri 6.098 yorumun tamamı okundu, özellik sinyali taşıyan 1.391 yorum etiketlendi. Anahtar kelime sayımı yalnız destek olarak kullanıldı; her tabloda hangisinin kullanıldığı yazılı.

## 0. Sonuç

Ebeveyn, bir özelliğe değil, çocuğun bağlandığı bir uygulamaya para veriyor. 95 açık satın alma cümlesinin ("tam sürümü aldım", "paketi satın aldık") 28'inde neden "çocuk ücretsiz kısmı çok sevdi"; 13'ünde "daha çok sayfa/çeşit açmak"; 9'unda "öğretici/eğitici". Canlanan resim yalnız 1, çıkartma 1, efekt 1 satın alma cümlesinde geçiyor. Satın almayı tetikleyen şey özellik seti değil, çocuğun ilgisi ve o ilginin ardından gelen içerik duvarı.

4–5 yıldızlı övgülerde en sık temalar: öğretme/anlatım (136), reklamsız ve güvenli (92), sakinleştirici ve meşgul edici (91), çok sayfa/çeşit (52), çok aktivite türü (49), ince motor gelişimi (47), basitlik (44), lisanslı karakter (38), canlanan resim (36), ücretsiz/tek seferlik fiyat (35). Canlanan resim övgüsü üç Bini Bambini uygulamasında (Todli, Pinksy, Drawing Academy) yoğunlaşıyor; bu uygulamalar çizim öğreten uygulamalar, salt boyama değil.

En çok istenen özellikler: daha çok sayfa (65; bunun 13'ü belirli lisanslı karakter isteği), boş sayfa / serbest çizim (21), daha çok renk (18), çevrimdışı çalışma (17), aile paylaşımı (14) ve çoklu profil (10), resmi tek dokunuşla sıfırlama (12), Türkçe veya başka dil (11, 9'u TR), büyük çocuklar için içerik (10).

1–3 yıldızda özellik kaynaklı şikâyetler: reklam (65), az sayfa (50), sıkıcı (41), yaşa uymuyor (22), kafa karıştıran arayüz (22), az renk (20), ses/müzik rahatsız edici (18), zor (16), ürkütücü içerik (16), hep aynı (10), çocuk bıraktı (9). "Bir günde bitirdi" tipi "içerik bitti" sinyali 12 yorumda var.

Cobi Paint'in durumu: 323 sayfa, reklamsız, çevrimdışı, çizgide kalan dolgu ve tek seferlik kilit, en çok övülen ve en çok istenen özelliklerin çoğunu karşılıyor (reklamsız 92 övgü, çevrimdışı 29 övgü + 17 istek, çeşit 52 övgü + 65 istek, çizgide kalma 13 övgü + 7 istek, tek seferlik tercih 25 yorum). Cobi'nin eksikleri arasında veride karşılığı olanlar: sesli anlatım/renk adı söyleme (öğretme teması 136 övgüyle birinci; ama bunun büyük bölümü çizim öğreten ve çok aktiviteli uygulamalardan geliyor), canlanan resim (36 övgü, satın alma cümlesinde 1), çoklu profil/aile paylaşımı (24 istek). Sayıyla boyama (6 övgü, hepsi RV), fotoğraftan sayfa (1 övgü + 1 istek), yazdırma (1 övgü), müzik (5 övgü, 18 "ses rahatsız edici" şikâyeti) için talep zayıf.

Sahibin tezi ("bu haliyle kimse almaz, özellik seti genişlemeli") veride yarı yarıya doğrulanıyor. Özellik genişletmesi tek başına satın alma getirmiyor; ebeveyn, çocuk uygulamaya bağlandıktan sonra ödüyor ve en sık "daha çok sayfa" için ödüyor. Cobi'nin içerik hacmi rakiplerin ücretsiz katmanından (çoğunda 1 kategori, 2–16 sayfa) kat kat fazla; bu yüzden çocuk bağlanmadan önce duvar görmeyecek, ama bağlandıktan sonra ödeme nedeni de kalmayabilir. Veri, kilidin "çocuk sevdi" anından sonra ve içeriğin bir bölümünün önünde durmasını destekliyor. Özellik tarafında veriye göre sıralama: (1) sesli yönlendirme ve renk adı söyleme, (2) boyama bitince kısa canlanma, (3) aile paylaşımı + çoklu profil, (4) boş sayfa ve tek dokunuşla sıfırlama, (5) renk sayısı (kahverengi, ten renkleri). Bu sıralama ebeveynlerin söyledikleriyle sınırlı; Cobi için ölçülmüş bir sonuç değil.

## 1. Yöntem ve örnek büyüklüğü

Veri kaynağı:
- App Store: Apple'ın `userReviewsRow` uç noktası, `sort=4` (en yeni), uygulama ve mağaza başına en çok 300 yorum. Mevcut `reviews2` verisi 200 ile sınırlıydı; tüm uygulamalar 300'e tamamlandı ve eksik uygulamalar eklendi.
- Google Play: `google-play-scraper` (venv), `lang=en/country=us` ve `lang=tr/country=tr`, en yeni 300. Paket adları Play aramasıyla ve iOS bundle kimliğiyle doğrulandı.
- Toplam 10.268 yorum çekildi; kapsam dışı bir uygulama (6475648610 = Wonjo Kids Learning Games, boyama değil) çıkarılınca 10.198 yorum kaldı: App Store 4.096, Play 6.102; Türkiye 3.408, ABD 6.790; 4–5 yıldız 7.227, 1–3 yıldız 2.971.
- 6 kelime ve üzeri 6.098 yorum okundu. Özellik sinyali taşıyan 1.391 yorum etiketlendi (ABD 1.000, TR 340, 51'i "seri/şablon" görünümlü). Etiket listesi ve sözlük `b-data/labels/` altında.

Etiketleme kuralları:
- Övgü etiketleri (P_) yalnız özelliği açıkça öven cümleye verildi; "çok güzel oyun" gibi genel övgüler etiketlenmedi.
- Satın alma (BUY) yalnız açık ifadeye verildi: "aldım", "satın aldık", "abone olduk", "worth the money", "paid for". Para şikâyetleri etiketlenmedi.
- İstek (W_) kalıpları: keşke, eklenmeli, eksik, wish, please add, would be nice, needs, should have.
- Şikâyet (C_) yalnız 1–3 yıldızda ve yalnız özellik kaynaklıysa sayıldı; çökme ve ödeme sorunları dışarıda.
- Seri görünümlü yorumlar (SEED): Bimi Boo'nun 2017 Eylül TR yorumları (makine çevirisi izleri), Sago Mini'nin 2025 Nisan TR ve 2026 Nisan–Ağustos Play yorumları (pazarlama metni gibi), Tiny Minies'in 6–15 Haziran 2021 yorumları (aynı hafta, cilalı dil). Bunlar sayımlardan çıkarıldı; etkisi bölüm 8'de.

Örnek büyüklüğü (yorum sayısı; tarih aralığı en eski–en yeni):

| Uygulama | App Store ABD | App Store TR | Play ABD | Play TR | Toplam | Tarih aralığı |
|---|---|---|---|---|---|---|
| Bimi Boo Drawing for Kids | 300 | 145 | 300 | 168 | 913 | 2016-09 – 2026-10 |
| Bimi Boo Baby Coloring | 300 | 81 | 300 | 221 | 902 | 2016-09 – 2026-11 |
| Bimi Boo Kids Coloring | 66 | 5 | 263 | 19 | 353 | 2023-02 – 2026-11 |
| KidloLand Coloring (Coloring Club) | 300 | 145 | 94 | 21 | 560 | 2011-12 – 2026-11 |
| KidloLand / IDZ "Coloring Games for Kids: Color" (yalnız Play) | – | – | 300 | 300 | 600 | 2021-01 – 2026-11 |
| Todli | 300 | 33 | 300 | 300 | 933 | 2018-01 – 2026-10 |
| Pinksy | 300 | 131 | 300 | 300 | 1.031 | 2019-05 – 2026-11 |
| Drawing Academy | 260 | 93 | 300 | 300 | 953 | 2018-12 – 2026-10 |
| RV Coloring Games | 92 | 26 | 300 | 300 | 718 | 2020-03 – 2026-11 |
| Kakadoo (Drawing and coloring) | 25 | 2 | 135 | 24 | 186 | 2022-01 – 2026-10 |
| Kakadoo (Easy coloring pages, yalnız Play) | – | – | 300 | 35 | 335 | 2021-02 – 2026-09 |
| Crayola Create and Play | 300 | 2 | 300 | 12 | 614 | 2023-02 – 2026-11 |
| Sago Mini Crayon Club | 25 | 10 | 115 | 2 | 152 | 2025-04 – 2026-11 |
| Disney Coloring World | 300 | 44 | 300 | 300 | 944 | 2020-11 – 2026-11 |
| Toya | 20 | 0 | 300 | 56 | 376 | 2020-09 – 2026-11 |
| 22LEARN Toddler Coloring | 5 | 0 | yok | yok | 5 | 2024-09 – 2025-05 |
| Amaya Coloring Book | 38 | 0 | 125 | 3 | 166 | 2019-09 – 2026-09 |
| Budge Kids Coloring | 19 | 0 | 56 | 4 | 79 | 2024-12 – 2026-10 |
| Kalemo | 0 | 0 | yok | yok | 0 | – |
| Minik Palet | 0 | 2 | yok | yok | 2 | 2026-10 |
| Kid Doodle | 0 | 20 | yok | yok | 20 | 2020-03 – 2026-07 |
| Tiny Minies | 40 | 300 | bulunamadı | bulunamadı | 340 | 2020-11 – 2026-10 |
| JMH Coloring Book 2+ (ek) | 12 | 3 | – | – | 15 | 2023-07 – 2026-08 |
| BoyaBoo (ek) | 0 | 1 | – | – | 1 | 2026-11 |

Notlar: Todli ve Pinksy iOS'ta Bini Bambini markası; Play eşlenikleri `com.binibambini.MiniLite` ve `com.binibambini.drawingforgirls`. Toya'nın Play eşleniği `com.toddler.coloring` (Toy Tap). 22LEARN'ün boyama uygulaması ve Kalemo/Minik Palet/Kid Doodle Play'de yok. Tiny Minies'in Play paketi arama sonucunda kimliksiz döndü, bulunamadı.

## 2. Satın alma nedenleri

### 2a. 4–5 yıldızlı yorumlarda övülen özellikler (elle etiket, seri görünümlüler hariç)

Sayılar yorum sayısıdır; bir yorum birden çok tema taşıyabilir. 4–5 yıldızda en az bir övgü etiketi taşıyan yorum sayısı 638 (ABD 469, TR 169).

| Tema | Toplam | TR | ABD | En çok geçtiği uygulamalar | Açık satın alma cümlesinde |
|---|---|---|---|---|---|
| Öğretme, anlatım, renk/harf öğrenme | 136 | 53 | 83 | Todli 23, Drawing Academy 22, Pinksy 20, Tiny Minies 12, Crayola 10 | 9 |
| Reklamsız, güvenli | 92 | 25 | 67 | RV 29, Disney 12, Bimi Boo Drawing 9, Bimi Boo Baby Coloring 8 | 5 |
| Sakinleştirici, meşgul ediyor, sessiz tutuyor | 91 | 8 | 83 | Pinksy 14, Bimi Boo Baby Coloring 13, Disney 9 | 1 |
| Çok sayfa, çeşit | 52 | 12 | 40 | Bimi Boo Baby Coloring 10, Bimi Boo Drawing 7, Disney 7, RV 6 | 13 |
| Çok aktivite türü (boyama + oyun + yapboz) | 49 | 8 | 41 | Crayola 11, KidloLand 10, RV 7, IDZ 7, Toya 5 | 3 |
| İnce motor, çizim becerisi gelişti | 47 | 29 | 18 | Pinksy 17, Drawing Academy 12, Todli 7 | 0 |
| Basit, çocuk tek başına kullanıyor | 44 | 5 | 39 | Bimi Boo Drawing 7, Bimi Boo Baby Coloring 5, Toya 4, Pinksy 4 | 6 |
| Lisanslı karakter (Disney, PAW Patrol) | 38 | 8 | 30 | Disney 27, Sago 10 | 0 |
| Canlanan/animasyonlu resim | 36 | 5 | 31 | Todli 12, Pinksy 11, Drawing Academy 9 | 1 |
| Ücretsiz / tek seferlik / fiyatı makul | 35 | 11 | 24 | RV 24 | 4 |
| Efekt: sim, parıltı, gökkuşağı kalem, fırçalar | 31 | 4 | 27 | Bimi Boo Drawing 5, Toya 5, Bimi Boo Baby Coloring 5, Pinksy 4 | 1 |
| Çevrimdışı; araba, uçak, restoran, bekleme | 29 | 3 | 26 | Disney 6, RV 5, KidloLand 4 | 2 |
| Kardeşler / her yaş birlikte | 24 | 7 | 17 | Bimi Boo Baby Coloring 5, Todli 4 | 3 |
| Çıkartma, sahne, oyun seti | 21 | 4 | 17 | Disney 14, Pinksy 3 | 1 |
| Çocuk ücretsiz kısmı çok sevdi (o yüzden aldım) | 18 | 4 | 14 | Bimi Boo Baby Coloring 5, Kakadoo 3, Bimi Boo Drawing 3 | 28 |
| Çizgide kalma, dokunarak dolgu | 13 | 1 | 12 | Bimi Boo Baby Coloring 3, Toya 2, Bimi Boo Drawing 2, Amaya 2, Disney 2 | 0 |
| Düzenli yeni içerik | 12 | 3 | 9 | Sago 2, Pinksy 2, Disney 2, Crayola 2 | 0 |
| Karakter sesi, sesli yönlendirme | 9 | 4 | 5 | Pinksy 5 | 0 |
| Apple Pencil / S Pen | 7 | 4 | 3 | Disney 2 | 0 |
| Dil seçeneği (Türkçe, İngilizce) | 7 | 6 | 1 | Todli 2, Tiny Minies 2 | 0 |
| Sayıyla / pikselle boyama | 6 | 4 | 2 | RV 6 | 0 |
| Müzik | 5 | 2 | 3 | IDZ 2 | 0 |
| Serbest çizim | 4 | 2 | 2 | – | 0 |
| Kaydetme, paylaşma, çerçeve | 4 | 0 | 4 | Pinksy 2 | 1 |
| Otomatik renk ("Disney color" düğmesi) | 4 | 0 | 4 | Disney 4 | 1 |
| Yazdırma | 1 | 0 | 1 | Disney | 0 |
| Fotoğraftan karakter | 1 | 0 | 1 | Budge | 0 |

Kısa alıntılar (en çok 12 kelime):
- Canlanma: "Çizimlerin animasyona dönüştürülmesi çok güzel ve başarılı." (Todli, TR Play). "animated features made it totally worth it" (Pinksy, ABD Play). "I love making my drawings move and walk around" (Todli, ABD).
- Anlatım: "renkleri seçerken onlarin isimlerinide söylüyoar" [sic] (Todli, TR Play). "Lucas tells her good job" (RV, ABD Play). "kızım bu oyun sayesinde renkleri öğrendi" (Pinksy, TR Play).
- Reklamsız, tek seferlik: "No ads. No subscription. Clean UI. One-time purchase." (Bimi Boo Drawing, ABD). "free, no ads, no nonsense" (RV, ABD).
- Sakin/meşgul: "Keeps her happy for hours" (Bimi Boo Drawing, ABD Play). "Saved our evening!" (Bimi Boo Baby Coloring, ABD; restoranda).
- Çevrimdışı: "The offline play is a huge plus" (Sago Mini, ABD). "Best game ever for 4 hour car rides" (Disney, ABD).
- Çizgide kalma: "She likes it because you can't get out of the lines" (Bimi Boo Baby Coloring, ABD Play).

### 2b. Açık satın alma cümlelerinde geçen nedenler

95 yorumda açık satın alma ifadesi var (ABD 81, TR 14; 49'u 4–5 yıldız, 46'sı 1–3 yıldız; düşük puanlılar çoğunlukla "aldım ama kilit geri geldi" tipi). Satın alma cümlesinin yanında geçen neden:

| Neden | Yorum | Uygulamalar |
|---|---|---|
| Çocuk ücretsiz kısmı çok sevdi | 28 | Bimi Boo Drawing 7, Bimi Boo Baby Coloring 7, Pinksy 3, Drawing Academy 3, Crayola 2 |
| Daha çok sayfa/kategori açmak | 13 | Bimi Boo Drawing 7, Bimi Boo Baby Coloring 2 |
| Öğretici, eğitici | 9 | Kid Doodle 2, Todli 2, Crayola 2, Tiny Minies 1 |
| Basit, kolay | 6 | Bimi Boo Drawing 3 |
| Reklamsız | 5 | Bimi Boo Drawing 2 |
| Fiyat makul / tek seferlik | 4 | Toya, Bimi Boo Drawing, Bimi Boo Baby Coloring, Disney |
| Çok aktivite | 3 | Crayola 2, Toya |
| Kardeşler birlikte | 3 | Bimi Boo Baby Coloring 2 |
| Çevrimdışı / bekleme | 2 | Bimi Boo Drawing, Pinksy |
| Canlanma | 1 | Pinksy |
| Çıkartma / efekt / otomatik renk / kaydetme | 1'er | Disney, Pinksy |

Alıntılar: "my daughter loved the free demo so we purchased the full version" (Bimi Boo Baby Coloring, ABD). "she always forces me to buy more of the categories" (Bimi Boo Drawing, ABD). "Total worth unlocking all the coloring pages!" (Kakadoo, ABD). "Uzun süredir kullanınca full sürümü satın aldım." (Bimi Boo Drawing, TR). "AB harflerini öğrendiğini görünce ücretli aldım" (Tiny Minies, TR). "paid to access the additional pages for when he has to wait" (Bimi Boo Drawing, ABD Play).

Ek sinyal: 25 yorum abonelik yerine tek seferlik ödeme istiyor (ABD 24, TR 1): Disney 9, Bimi Boo Kids 4, Pinksy 4, Drawing Academy 2, Crayola 2, KidloLand 2. "I would gladly pay a one-time fee to 'own' the app" (Disney, ABD). "Tek seferlik 3-4 usd olsa tamam" (Drawing Academy, TR).

Anahtar kelime desteği (regex, tüm yorumlar, 4–5 yıldız / 1–3 yıldız): öğretme-anlatım 318/49, reklamsız-güvenli 80/12, sakin-meşgul 107/31, canlanma 38/6, çeşit 38/27, efekt 26/13, çevrimdışı 29/13, çizgide kalma 17/10, çıkartma-sahne 30/8, sayıyla boyama 5/5, kalem 19/29, müzik 14/18, yazdırma 3/3, fotoğraf 1/1. Sıralama elle etiketle uyumlu; "öğretme" kelime sayımında şişiyor çünkü "eğitici" genel övgü olarak da yazılıyor.

## 3. İstenen özellikler

Elle etiket, tüm yıldızlar, seri görünümlüler hariç; 241 yorumda en az bir istek (ABD 180, TR 61).

| İstek | Yorum | TR | ABD | Uygulamalar | Örnek (en çok 12 kelime) |
|---|---|---|---|---|---|
| Daha çok sayfa / yeni resim (13'ü belirli lisanslı karakter: Bluey, Stitch, K-Pop Demon Hunters) | 65 | 17 | 48 | Disney 19, Bimi Boo Baby Coloring 7, Todli 7, Pinksy 6 | "please add more pages to color, perhaps other holidays" (Bimi Boo Baby Coloring, ABD); "Lütfen daha çok resim ekleyin :)" (Minik Palet, TR) |
| Boş sayfa / serbest çizim | 21 | 3 | 18 | Drawing Academy 6, Pinksy 4, Bimi Boo Drawing 3, Todli 3 | "Boş sayfa bırakın ben dinozor çizcem" (Bimi Boo Drawing, TR Play); "WHY ARE THERE NO BLANK PAGES!" (Pinksy, ABD) |
| Daha çok renk; kahverengi, ten rengi, kovada başka renk | 18 (+2 ten rengi) | 6 | 12 | Bimi Boo Drawing 6, Bimi Boo Baby Coloring 4, Toya 2 | "would be nice if you guys would add the color Brown" (Bimi Boo Baby Coloring, ABD Play); "keşke kovada diğer renkler de olsa" (Bimi Boo Drawing, TR) |
| Çevrimdışı çalışsın | 17 | 4 | 13 | Drawing Academy 4, Disney 3, Sago 2 | "on a car trip … all the pictures were locked again" (Drawing Academy, ABD); "Game won't work without an internet connection" (Sago, ABD Play) |
| Aile paylaşımı (satın alma ikinci cihaza/çocuğa geçsin) | 14 | 2 | 12 | Bimi Boo Drawing 2, Bimi Boo Baby Coloring 2, Todli 2, Crayola 2 | "not eligible for family sharing, which is the only reason I purchased" (Todli, ABD) |
| Çoklu profil / Google Family Link ile çalışsın | 10 | 2 | 8 | Tiny Minies 2 | "I have two nephews and two tablets" (Crayola, ABD) |
| Resmi tek dokunuşla sıfırla / temizle | 12 | 3 | 9 | Amaya 4, Tiny Minies 3 | "Please add a setting to reset/erase/clear all the drawings" (Bimi Boo Baby Coloring, ABD) |
| Dil: Türkçe, Almanca, Kürtçe, iki dil | 11 | 9 | 2 | Tiny Minies 5, RV 2, Todli 2 | "Oyun çok güzel tek eksiği Türkçe olmaması." (RV, TR Play) |
| Büyük çocuklar için içerik / zorluk | 10 | 1 | 9 | Bimi Boo Drawing 4, Todli 2, Drawing Academy 2 | "make a older kid game for like 9-15" (Bimi Boo Drawing, ABD) |
| Boyama modu (çizim öğreten uygulamada) / çizgide kalan dolgu | 7 | 3 | 4 | Todli 4 | "kendi çizimlerini yapıyorsun ama boyayamıyoruz" (Todli, TR Play) |
| Sesi/müziği ayrı kapatma | 6 | 0 | 6 | RV 2 | "can turn off the music but not the rest of the sounds" (Disney, ABD) |
| Fırça kalınlığı seçimi | 6 | 1 | 5 | RV 2 | "kalem boyutunu seçmiyoruz" (IDZ, TR Play) |
| Başka araçlar / daha iyi kalem ucu | 5 | 1 | 4 | Bimi Boo Drawing 2 | "wish that there were a couple of more tools" (Bimi Boo Drawing, ABD) |
| Müzik seçeneği / farklı müzik | 4 | 0 | 4 | Bimi Boo Drawing 2, IDZ 2 | "Would it be so hard to have some different music options?" (Bimi Boo Drawing, ABD) |
| Silgi | 4 | 3 | 1 | Bimi Boo Baby Coloring 3 | "silgi yok o yüzden 1 puan kırdım" (Bimi Boo Baby Coloring, TR Play) |
| Kaydetme / galeri | 3 | 0 | 3 | Kakadoo, Bimi Boo Baby Coloring, Crayola | "I can't find how to save the art my kid makes" (Kakadoo, ABD Play) |
| Yakınlaştırma | 3 | 0 | 3 | Toya, Bimi Boo Baby Coloring, Disney | "Wish I was able to zoom in" (Bimi Boo Baby Coloring, ABD) |
| Geri al | 3 | 1 | 2 | Toya, Pinksy, Tiny Minies | "Geri al özelliği yok, sıfırlama özelliği yok" (Tiny Minies, TR) |
| Desenli fırça | 3 | 1 | 2 | Disney 2 | "There aren't any pattern brushes" (Disney, ABD) |
| Canlanma eklensin / geri gelsin | 3 | 2 | 1 | Todli 2, Disney | "keşke çizdiğimiz resimler canlanınca oyun oynamaya devam etse" (Todli, TR Play) |
| Öğrenme oyunu (ABC, kelime) | 3 | 0 | 3 | – | "wish there were even more vocabulary games" (Tiny Minies, ABD) |
| Çizgi dışına çıkabilme | 2 | 0 | 2 | Bimi Boo Drawing, Kakadoo | "offer an option to color OUTSIDE the lines" (Bimi Boo Drawing, ABD Play) |
| Çıkartma / resmi kitaba çıkartma olarak ekleme | 2 | 1 | 1 | Bimi Boo Drawing, Pinksy | "image stamps be good to add eg like stickers" (Bimi Boo Drawing, ABD Play) |
| Renk karıştırma | 2 | 0 | 2 | Kakadoo, RV | "I would like to be able to mix colors" (Kakadoo, ABD) |
| Fotoğraf içe aktarma | 1 | 0 | 1 | RV | "could you make it so you can import your own pictures?" (RV, ABD) |
| Ebeveyn kapısı (yanlışlıkla satın almaya karşı) | 1 | 0 | 1 | Bimi Boo Baby Coloring | – |
| Diğer (karakter oluşturucu, VoiceOver erişilebilirliği, ekran kilidi, çocuğa yönelik yönerge) | 24 | 8 | 16 | dağınık | "Görme engelliler için erişilebilir olsun … VoiceOver" (Tiny Minies, TR) |

Anahtar kelime desteği ("keşke/wish/please add/would be nice/needs" kalıpları): 200 yorum (4–5 yıldız 113, 1–3 yıldız 87; TR 40, ABD 160). Bu kalıbın yakaladığı yorumların yaklaşık yarısı "keşke bedava olsa" tipi para isteği; bu yüzden tabloda elle etiket kullanıldı.

## 4. Özellik kaynaklı şikâyetler (1–3 yıldız)

Elle etiket; para, ödeme ve çökme şikâyetleri hariç. 1–3 yıldızda en az bir özellik şikâyeti taşıyan yorum 262 (ABD 217, TR 45).

| Şikâyet | Yorum | TR | ABD | Uygulamalar | Örnek |
|---|---|---|---|---|---|
| Reklam oyunu kullanılmaz yapıyor (çocuk reklama basıyor) | 65 | 11 | 54 | Todli 28 (Play), IDZ 14, Drawing Academy 13, Toya 4 | "he keeps pressing the top ads bar all the time" (Toya, ABD Play) |
| Az sayfa / az seçenek (ücretsiz katman dar) | 50 | 6 | 44 | Drawing Academy 11, Disney 10, Todli 5 | "Only 2 free pictures to colour per category" (Bimi Boo Kids, ABD Play) |
| Sıkıcı, çocuk sıkıldı | 41 | 7 | 34 | Disney 7, Crayola 6, Bimi Boo Drawing 5, Pinksy 5 | "my 4yr old literary said boring after 6min" (Kakadoo, ABD Play) |
| Yaşa uymuyor (bebeksi ya da küçüğe zor) | 22 | 9 | 13 | Tiny Minies 5, Bimi Boo Drawing 3, Todli 3 | "3 [y]aş ve üstü için basit kalıyor sıkılıyorlar" (Tiny Minies, TR) |
| Arayüz kafa karıştırıyor; çıkış düğmesi, nag ekranı, otomatik bitirme | 22 | 0 | 22 | Crayola 4, Todli 3, Disney 3 | "Elini bırakırsan hemen bitiriyor insanı sıkıyor" (Todli, TR, 4 yıldız) |
| Az renk (ücretsizde 3 renk; güncellemeyle 56'dan 24'e düşürüldü) | 20 | 1 | 19 | Bimi Boo Drawing 9, Bimi Boo Baby Coloring 4 | "they took away over half of the colors" (Bimi Boo Drawing, ABD) |
| Ses/müzik rahatsız edici; sessiz modu dinlemiyor; ses çalışmıyor | 18 | 2 | 16 | RV 4 | "it overrides silent mode with its sounds!" (RV, ABD) |
| Zor; küçük alanlar; kalın parmakla boyanmıyor | 16 | 6 | 10 | Todli 5, Disney 3 | "ben bile zor boyuyorum çok küçük nesneler" (Bimi Boo Drawing, TR) |
| Ürkütücü ya da uygunsuz içerik (kafatası, ağlayan kilitli hayvan, Cadılar Bayramı sesi) | 16 | 4 | 12 | KidloLand 4, Todli 3 | "Ürkütücü sesler, böcekli pizza yapımı" (KidloLand, TR) |
| Hep aynı resimler, tekrar | 10 | 4 | 6 | Bimi Boo Baby Coloring 2, Todli 2, Disney 2, Tiny Minies 2 | "stuck coloring the same Animals category over and over" (Bimi Boo Baby Coloring, ABD) |
| Çocuk bıraktı / ilgisini kaybetti | 9 | 5 | 4 | Tiny Minies 4 | "oğlum daha ilk dakikalarda bile sevmedi" (Tiny Minies, TR) |
| Ebeveyn kapısı (toplama sorusu) çocuğu engelliyor | 5 | 0 | 5 | Kakadoo 2 | "Needs a calculation to open every step. Difficult for kids." (Kakadoo, ABD Play) |
| Çizim kaydedilmiyor / silindi | 3 | 0 | 3 | – | "They can't save their creations anymore" (Bimi Boo Drawing, ABD Play) |
| İçerik bitti (1–3 yıldız) | 3 | 0 | 3 | Pinksy 2 | "unlocked all of the drawings and now she is so bored" (Pinksy, ABD) |
| Dolgu yanlış yeri boyuyor | 2 | 0 | 2 | Kakadoo, Toya | – |

4–5 yıldızlı yorumlarda da geçen özellik şikâyetleri: "içerik bitti" 9 ("Kardeşim için indirdim, neredeyse 1 günde bitirdi" Bimi Boo Drawing, TR Play; "oyunu bir günde bitirdim" Disney, TR Play), ses 8, arayüz 9, az sayfa 7. Toplamda "bitirdi/bitti" sinyali 12 yorum.

Anahtar kelime desteği (tüm yorumlar, 4–5 / 1–3): sıkıcı-aynı 68/98, az sayfa-az seçenek 25/77, yaşa uymuyor 22/18. Elle etiketten yüksek çıkıyor çünkü "sıkılınca oynuyorum" gibi olumlu kullanımlar da yakalanıyor.

## 5. Tek seferlik modeldeki uygulamalar

Kapsam: Bimi Boo Drawing for Kids (tam sürüm + paketler), Kakadoo (iki uygulama), Toya, 22LEARN, Kalemo, Minik Palet. Kalemo'da yorum yok, Minik Palet 2, 22LEARN 5; tablo fiilen Bimi Boo Drawing, Kakadoo ve Toya'yı anlatıyor. (Not: Bimi Boo Drawing'in ABD yorumlarında 2023 sonundan itibaren yıllık ödemeden söz ediliyor; model karışık olabilir.)

4–5 yıldızlı övgüler (elle etiket):

| Tema | Toplam | Bimi Boo Drawing | Kakadoo (ikisi) | Toya | Diğer |
|---|---|---|---|---|---|
| Basit, tek başına kullanıyor | 15 | 7 | 3 | 4 | Minik Palet 1 |
| Reklamsız | 12 | 9 | 1 | 2 | |
| Çok sayfa / çeşit | 11 | 7 | 3 | 1 | |
| Efekt (sim, parıltı, karanlık oda, mandala) | 11 | 5 | 1 | 5 | |
| Öğretici (renk, hayvan adı) | 10 | 8 | 0 | 2 | |
| Sakinleştirici / meşgul | 9 | 7 | 1 | 1 | |
| Çocuk çok sevdi | 7 | 3 | 3 | 1 | |
| Fiyat makul | 5 | 2 | 1 | 2 | |
| Çevrimdışı / bekleme | 5 | 3 | 0 | 2 | |
| Çok aktivite türü | 5 | 0 | 0 | 5 | |
| Çizgide kalma | 4 | 2 | 0 | 2 | |
| Kardeşler | 3 | 0 | 1 | 1 | 22LEARN 1 |
| İnce motor | 2 | 1 | 0 | 1 | |
| Canlanma (seri görünümlü 2017 TR yorumları hariç) | 1 | 0 | 0 | 1 | |

Açık satın alma cümleleri: 24 (Bimi Boo Drawing 18, Kakadoo 4, Toya 2). Yanında geçen neden: çocuk sevdi 9, daha çok sayfa 8, basit 5, fiyat 2, reklamsız 2, çevrimdışı 1, uzun süre kullanınca 1, öğretici 1, çok aktivite 1.

Okuma: tek seferlik modelde ebeveyn "deneme → çocuk sevdi → paket aç" yolunu anlatıyor; satın alma neredeyse hep içerik hacmine bağlanıyor. Bimi Boo Drawing'de öfke yaratan şey ücretsiz katmanın darlığı (yalnız hayvanlar, 3 renk) ve paket aldıktan sonra renklerin de ayrı kilitli olması. Toya'nın ABD App Store yorumları özellik övgüsü açısından en zengin olanı: karanlık odada boyama, mandala, efektler, "a good number of options for the price".

## 6. Uzun süreli ilgi sinyalleri

Elle etiket: "aylardır/yıllardır oynuyor", "her gün istiyor", "3 yaşından beri" gibi ifadeler 138 yorumda (ABD 98, TR 40); "bir günde/haftada bıraktı" 22 yorumda (ABD 16, TR 6).

| Uygulama | Uzun ilgi | Hızlı bırakma | Uzun ilginin bağlandığı şey (yorumların kendi ifadesi) |
|---|---|---|---|
| Pinksy | 19 | 4 | çizim becerisi gelişti, her gün çizmek istiyor; "3 aydır bu oyunu sıkılmadan her gün oynuyor" (TR Play) |
| Crayola Create and Play | 18 | 2 | çok aktivite, evcil hayvan, düzenli yeni içerik; "members to Crayola for over 4 years" (ABD Play) |
| Todli | 17 | 1 | canlanma, öğrenme; "Its been long time and I've never stopped playing this" (ABD Play) |
| Disney Coloring World | 16 | 1 | karakterler, kale/sahne oyunu, yeni sayfalar; "I've had this game since I was 3. I'm now 6yrs older" (ABD) |
| Bimi Boo Drawing | 13 | 2 | sim efekti, basitlik; "coloring in this app since I was 4" (ABD) |
| RV Coloring Games | 11 | 0 | çok mod, sayıyla boyama, ücretsiz; "has loved playing these games since he was 2" (ABD Play) |
| Drawing Academy | 10 | 4 | çizim öğretme, canlanma; "Improved my 3 yr old's drawing so much!" (ABD) |
| KidloLand (ikisi) | 11 | 1 | çok aktivite; "I had this app sense I was 3 now I'm 7" (ABD) |
| Tiny Minies | 6 | 1 | öğretici içerik; ama "fakat hep aynı o yüzden sıkılmaya başladı" (TR) |
| Kakadoo (ikisi) | 5 | 4 | kolaylık; "She can sit and color for hours" (ABD) |
| Bimi Boo Baby Coloring | 5 | 1 | "kardeşim her gün boyama yapıyor" (TR Play) |
| Toya | 4 | 0 | efektler; "since I was one and I'm now Seven years old" (ABD Play) |
| Sago Mini Crayon Club | 3 | 0 | "colored the same paw patrol page like 15 times" (ABD Play) |

Uzun ilgi yorumlarında birlikte övülen özellikler: öğretme 6, çok aktivite 5, reklamsız 4, çeşit 4, efekt 4, çocuk sevdi 3. Hızlı bırakma yorumlarında birlikte geçen şikâyet: sıkıcı 5, içerik bitti 5, az sayfa 4; "child lost interest so we cancelled" (Crayola, ABD Play), "After 5 months we have made all the images and are deleting" (Pinksy, ABD; bu ebeveyn ödemiş ve memnun ayrılmış).

Anahtar kelime desteği: uzun ilgi kalıpları 166 yorum (4–5 yıldız 125, 1–3 yıldız 41; ABD 134, TR 32); hızlı bırakma kalıpları 12 yorum. Sıralama elle etiketle uyumlu (Crayola 31, Pinksy 20, Todli 19, Bimi Boo Drawing 18).

Yorum: Uzun ilgi anlatan ebeveynlerin büyük bölümü çocuğun yaşının ilerlemesine rağmen uygulamaya döndüğünü yazıyor; bunu en çok yeni içerik akışına (Crayola, Disney, Sago) ve "yapabildiğini görme" hissine (Pinksy, Drawing Academy, Todli'de çizim becerisi) bağlıyorlar. Salt boyama uygulamalarında (Bimi Boo, Kakadoo) uzun ilgi daha çok basitlik ve "hep elinin altında" olmaya bağlanıyor; hızlı bırakma ise içerik bitince geliyor.

## 7. Türkiye ile ABD farkı

Yorum tabanı farklı: TR yorumlarının önemli bölümü çocuk yazımı ("kardeşim için indirdim", "10 yaşındayım ama oynuyorum") ve kısa; ABD yorumlarında ebeveyn anlatısı daha uzun. TR'de 4–5 yıldızda en az bir övgü etiketi 169 yorumda, ABD'de 469; oranlar bu tabanlara göre.

Övgü payları (tema / o ülkedeki tüm övgü etiketleri):

| Tema | TR | ABD | Fark |
|---|---|---|---|
| Öğretme, eğitici | %24,9 (53) | %13,7 (83) | TR'de iki kat; "eğitici" TR'de satın almayı meşrulaştıran kelime |
| İnce motor, çizim gelişti | %13,6 (29) | %3,0 (18) | TR'de dört kat; "resim yeteneği gelişti", "el becerisi" |
| Dil seçeneği (Türkçe) | %2,8 (6) | %0,2 (1) | TR'ye özgü; RV için "tek eksiği Türkçe olmaması" |
| Reklamsız | %11,7 (25) | %11,1 (67) | eşit |
| Sakinleştirici, meşgul | %3,8 (8) | %13,7 (83) | ABD'de belirgin: restoran, araba, "quiet time" |
| Basit, tek başına | %2,3 (5) | %6,4 (39) | ABD |
| Çevrimdışı / yolculuk | %1,4 (3) | %4,3 (26) | ABD |
| Canlanma | %2,3 (5) | %5,1 (31) | ABD (Bini Bambini ABD tabanı büyük) |
| Lisanslı karakter | %3,8 (8) | %5,0 (30) | ABD; TR'de yalnız Sago'nun seri görünümlü yorumları |

Şikâyet payları (1–3 yıldız): "yaşa uymuyor" TR %16,4 (9) – ABD %5,3 (13); "çocuk bıraktı" TR %9,1 (5) – ABD %1,6 (4); "hep aynı" TR %7,3 – ABD %2,4; "arayüz" TR %0 – ABD %8,9 (22); "az renk" TR %1,8 – ABD %7,7. Reklam, az sayfa ve sıkıcı iki ülkede de ilk üç.

İstek farkları: dil TR 9 – ABD 2; boş sayfa TR 3 – ABD 18; aile paylaşımı TR 2 – ABD 12; büyük çocuk içeriği TR 1 – ABD 9; daha çok sayfa TR 17 – ABD 48 (TR tabanı küçük olduğu için oran yakın).

Satın alma cümleleri: ABD 81, TR 14. TR'de tek seferlik tercih ifadesi 1, ABD'de 24. TR yorumlarında ödeme sözü daha çok "abonelik iptal edemiyorum" ve "deneme süresinde para çekildi" olarak geçiyor (bu çalışma dışında; Tiny Minies ve KidloLand TR App Store yorumlarının çoğunluğu bu).

Okuma: Türkiye'de ebeveyn "eğitici mi, çocuğumu geliştiriyor mu, Türkçe mi" diye bakıyor; ABD'de "beni rahatlatıyor mu, araba/restoranda işe yarıyor mu, çocuk tek başına kullanabiliyor mu". Cobi'nin Türkçe-yerli olması TR'de doğrudan bir övgü temasına karşılık geliyor; "öğretici" iddiasını taşıyacak somut bir öğe (renk adı söyleme, hayvan adı) TR'de daha çok iş görür.

## 8. Doğrulanamayanlar ve sınırlar

- Cobi Paint'in kendi yorumu yok (0 puan); tüm bulgular rakiplerin ebeveynlerinden. "Bu haliyle alır mı" sorusu bu veriyle ancak dolaylı yanıtlanır.
- Kalemo'da hiç yorum yok, Minik Palet 2, 22LEARN 5, BoyaBoo 1; "Türk tek seferlik uygulamalar" için anlamlı veri yok.
- Örnekleme "en yeni 300" ile sınırlı; yıllar boyunca değişen modeller (Disney'in paketten aboneliğe geçişi, Crayola'nın anahtar/süre sınırı, Bimi Boo'nun abonelik denemesi) yorumları etkiliyor. Tarih aralıkları bölüm 1'de.
- Seri görünümlü yorumlar: Bimi Boo'nun Eylül 2017 TR App Store yorumları (10 etiketli; canlanma övgüsünün TR payı bunlar dahil edilirse 5'ten 12'ye çıkar), Sago Mini'nin Nisan 2025 TR ve Nisan–Ağustos 2026 Play ABD yorumları (17 etiketli; PAW Patrol ve "no ads" övgülerinin çoğu burada), Tiny Minies'in 6–15 Haziran 2021 TR yorumları (16 etiketli). Bunlar sayımlardan çıkarıldı; şüphe nitel bir gözlem, kanıtlanmış değil.
- Etiketleme tek kişi tarafından yapıldı; güvenilirlik ölçümü yok. Sınır vakalar: "sıkılınca oynuyorum" (olumlu) ile "sıkıldı" (olumsuz) ayrımı elle yapıldı; "eğitici" genel övgüsü yalnız somut bir öğrenme öğesi (renk adı, harf, hayvan) yazıldığında öğretme etiketi aldı.
- Anahtar kelime sayımı destek amaçlı; "kardeş" kelimesi TR'de çoklu profil anlamına gelmediği için "kardeş/çoklu profil" regex'i (176 eşleşme) raporda kullanılmadı.
- Play yorumlarında reklam şikâyeti ağır basıyor çünkü Play sürümleri reklamlı; App Store sürümleri reklamsız. Reklam şikâyeti Cobi için doğrudan ölçüt değil, ama "reklamsız" övgüsünün değerini gösteriyor.
- Çocuk yazımı yorumlar (özellikle TR Play ve ABD App Store'da 7–12 yaş) ebeveyn kararını değil çocuk isteğini yansıtıyor; "büyük çocuk içeriği" isteğinin çoğu bu gruptan.
- 6475648610 (Wonjo) ve 1635552708 (JMH) listede yoktu; Wonjo boyama değil, kapsam dışı bırakıldı; JMH 15 yorumla eklendi, etkisi yok.
- Tiny Minies'in Play sürümü bulunamadı; Kid Doodle ve Türk uygulamalarının Play sürümü yok.

## 9. Kaynaklar ve ham veri yolları

Kök: `/private/tmp/claude-501/-Users-muazcobanos-Work-Workspace-Cobi-Paint-Mobile/ed955974-f6d6-4880-9d51-962c5cb4a230/scratchpad/ozellik/`

- `b-data/appstore/<cc>_<id>.json`: App Store yorumları, uygulama ve mağaza başına en çok 300 (`fetch_appstore.py`; `X-Apple-Store-Front: 143441-1,29` ABD, `143480,29` TR; `sort=4`).
- `b-data/play/<cc>_<paket>.json`: Google Play yorumları (`fetch_play.py`, `google-play-scraper`, `Sort.NEWEST`, 300). `b-data/play/search_results.json`: paket adı arama çıktısı.
- `b-data/all_reviews.jsonl`: 10.268 yorumun normalize birleşimi (`build_dataset.py`).
- `b-data/dump2/<uygulama>.txt`: okuma dökümleri, 6 kelime ve üzeri yorumlar, anahtar kelime bayraklarıyla (`make_dumps.py`).
- `b-data/labels/labels.txt`: 1.391 elle etiket (satır: uygulama, kaynak-ülke, yıldız, yorum kimliği son 6 hane, etiketler). `labels/README.txt`: etiket sözlüğü. `labels/labels_joined.json`, `labels/examples.json`: birleşik çıktı ve örnekler.
- `b-data/scripts/tally.py`, `tally_extra.py`: bölüm 2–7 tabloları. `scripts/keywords.py` ve `b-data/keyword_support.json`: anahtar kelime destek sayımları.
- `b-data/appstore_fetch.log`, `b-data/play_fetch.log`: çekim günlükleri (sayı ve tarih aralıkları).
- Önceki çalışmanın ham verisi: `../pazar/data/reviews2/` (8 Kasım, 200 ile sınırlı; bu çalışmada yeniden çekilip 300'e tamamlandı).
- Uygulama kimlikleri ve bundle eşleşmeleri: `raw/lookup_<cc>_<id>.json` (iTunes lookup).
