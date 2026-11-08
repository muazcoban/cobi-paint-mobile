# Türkiye'de özellik beklentileri: Play vitrini, ebeveynler, öğretmenler (Cobi Paint için)

Tarih: 8 Kasım 2026. Kapsam: yalnız özellik ve kullanım deneyimi. Fiyat, ödeme, kurulum ve puan karşılaştırması `plan/pazar-arastirmasi-2026-11-08/b-turkiye-android.md` dosyasında (bölüm 3.4, 4.3, 4.4, 5.2); burada tekrar edilmedi.

Yöntem: (a) Google Play Türkiye'de dört aramanın (`hl=tr&gl=TR`) ilk 20 sonucu ve bu sonuçların ayrıntı sayfaları `curl` ile indirildi; başlık, geliştirici, puan sayısı, "Öğretmen Onaylı" rozeti, "Reklam içerir" ve "Çevrimdışı" etiketleri, açıklama ve "Yenilikler" metni ayrıştırıldı (56 sayfa, 37'si ilk 20'lerdeki çocuk uygulaması). Ekran görüntüsü alt yazıları okunmadı: görseller indirilmedi (bölüm 8). (b) Dört alt araştırma: ebeveyn kaynakları (57 sayfa, 343 Türkçe mağaza yorumu), öğretmen ve MEB kaynakları (program PDF'leri, okuloncesi.net, Diyanet, MEB takvimi), yerli markalar ve Türkçe içerik (83 Play sayfası, 70 arama, marka siteleri, D&R), Android ve tablet pazarı (akakçe, epey, StatCounter, Google ve Samsung belgeleri). Alt araştırmaların karar taşıyan iddialarını kendim doğruladım: Diyanet 2027 bayram tarihleri, MEB 2026-27 ara tatili, Play API 36 ve 16 KB tarihleri, altı ebeveyn alıntısının indirilen HTML'de varlığı, Minik Fırça ve TRT Piksel Boyama metinleri. Alıntılar en çok 12 kelime, kaynaktaki yazımla.

Kısaltmalar: TA = Teacher Approved ("Öğretmen Onaylı" rozeti); IAP = uygulama içi satın alma; B = bin, Mn = milyon (Play gösterimi); "puan sayısı" = Play'in "yorum" saydığı değerlendirme sayısı.

---

## 0. Sonuç

1. Play Türkiye'de çocuk boyama vitrini yabancı stüdyoların Türkçeye çevrilmiş metinlerinden oluşuyor; dört aramanın ilk 20'sindeki 37 çocuk uygulamasının hiçbirinde Türkiye'ye özgü içerik (bayrak, 23 Nisan, bayram, Atatürk, yerel nesne, Türk masalı) yok, hiçbiri Türkçe seslendirme vaat etmiyor.
2. Vitrinde ortak vaatler: yaş aralığı ("2–5 yaş", "bebek") 26/37, fırça ve kalem çeşidi 19/37, ince motor ve el-göz koordinasyonu 19/37, çıkartma 15/37, paylaşım 15/37, kaydetme 12/37; Play "Çevrimdışı" etiketi 33/37'de var.
3. TA rozeti 37 uygulamanın 29'unda var; Türkiye'de ayırt edici değil, yokluğu eksik.
4. Sezonluk içerik var ama yalnız Batı takvimiyle: 8/37 uygulama Noel, Cadılar Bayramı ya da Paskalya seti anıyor; Ramazan, Kurban, 23 Nisan hiçbirinde yok.
5. Türk ebeveynlerin en sık şikâyeti reklam (16 kaynak), Türkçe yokluğu (11), yaşa uygunsuzluk (12) ve çocuğun uygulamadan çıkması ya da ayarları bozması (6). Pil ve ısınma şikâyeti hiçbir kaynakta çıkmadı; yazdırma isteği hiçbir ebeveyn yorumunda yok.
6. Türkçe seslendirme ebeveynin en net özellik isteği; TRT Anaokulum yorumlarında bile "rakam, şekil, renk adları seslendirilsin" en sık istek. Bunu vaat eden boyama uygulamaları yeni ve küçük: Minik Fırça (1 B+ kurulum, 30 Ekim 2026), DoDe Digital (100+ kurulum).
7. Yerli markalarda boyama uygulaması yok denecek kadar az: TRT Piksel Boyama (1 Mn+, "6 yaş ve üzeri", sayıyla piksel) ve Kral Şakir Boyama Kitabı (10 B+, 3,6 puan, reklamlı). Niloya, Pırıl, Kukuli, Rafadan Tayfa, Pepee için ekran içi boyama uygulaması bulunamadı. Ebeveyn forumlarında bu karakterlerle boyama talebi de bulunamadı; TRT karakteri talebi yalnız TRT Piksel yorumlarında var.
8. MEB Maarif Modeli (2024 ve 2026 baskısı) boyamayı sanat değil küçük kas çıktısı sayıyor (HSAB.2); renk kavram listesinde, 36–48 ay planlarında yalnız kırmızı-sarı-mavi; sayma 36–48 ayda 1–5 (MAB.1.a). Devlet anasınıflarında etkileşimli tahta FATİH kapsamı dışında; sınıfta TV ve bilgisayar var, tablet ve tahta standart değil.
9. Öğretmenlerin en çok etkinlik ürettiği günler (okuloncesi.net arşivi): Anneler Günü 258 konu, Yeni Yıl 133, Öğretmenler Günü 132, 10 Kasım 104, Orman Haftası 75, Kurban Bayramı yaklaşık 68. 2027 için kritik tarihler: 23 Nisan (Cuma), Ramazan Bayramı 9–11 Mart (ara tatil 8–12 Mart ile çakışıyor), Anneler Günü 9 Mayıs, Kurban Bayramı 16–19 Mayıs (19 Mayıs ile çakışıyor), 29 Ekim–10 Kasım–24 Kasım kümesi, Yerli Malı Haftası 12–18 Aralık.
10. Android tarafında Türkiye tablet tabanı Samsung ağırlıklı (StatCounter Ekim 2026: %51,2); ucuz segment 7" 1024×600 / 2 GB / Android 10 Go (Hometech, Everest) ile 8,7" 1340×800 / 4 GB (Galaxy Tab A9/A11, Lenovo Tab One, Redmi Pad SE 8.7) arasında. Rakiplerin yalnız 2'si tableti anıyor; hiçbiri düşük cihaz ya da yön desteği yazmıyor.
11. Play zorunlulukları (doğrulandı): 31 Ağustos 2026'dan beri yeni uygulama API 36 hedeflemeli (uzatma 1 Kasım 2026'da doldu); 16 KB sayfa desteği olmayan güncellemeler 1 Şubat 2027'den sonra yayımlanamaz; API 36 ile tabletlerde yön kilidi yok sayılıyor.
12. Cobi için Türkiye'de fark yaratacak özellikler: Türkçe sesli nesne ve renk adları (isteğe bağlı İngilizce), Türkiye takvimine bağlı sezon setleri, yerel nesne ve kamu malı masal kahramanı sayfaları, çocuğun çıkamayacağı kilit (ebeveyn kapısı, avuç reddi, Samsung Kids ve ekran sabitleme uyumu) ve düşük donanımlı tablette akıcılık.
13. Tek başına fark yaratmayacaklar: reklamsız ve çevrimdışı olmak (TRT'nin 42 uygulaması ve RV AppStudios aynı vaadi veriyor; yine de ilk cümlede yazılmalı), TA rozeti, yazdırma, çıkartma ve fırça çeşidi, sayıyla piksel boyama.

---

## 1. Play Türkiye vitrin özellikleri

### 1.1 Aramalar ve kapsam

| Arama | İlk 20'de çocuk uygulaması | Yetişkin uygulaması | TA rozeti | Play "Reklam içerir" | Play "Çevrimdışı" etiketi | Başlığı Türkçeleştirilmiş |
|---|---|---|---|---|---|---|
| "çocuk boyama" | 18 | 2 (Happy Color, Color by Number) | 16/18 | 9/18 | 18/18 | 10/18 |
| "boyama oyunları" | 12 | 8 (piksel ve mandala uygulamaları, ibis Paint, Colorfy) | 9/12 | 6/12 | 12/12 | 8/12 |
| "boyama kitabı çocuk" | 17 | 3 (Mandala boyama, Happy Color, Crayola Yetişkin) | 13/17 | 13/17 | 13/17 | 13/17 |
| "okul öncesi boyama" | 19 | 1 (Color by Number) | 18/19 | 6/19 | 19/19 | 17/19 |
| Birleşim | 37 | 10 | 29/37 | 18/37 | 33/37 | — |

Okuma: "boyama oyunları" araması yetişkin piksel uygulamalarına kayıyor; çocuk uygulaması arayan ebeveyn için "çocuk boyama" ve "okul öncesi boyama" asıl vitrin. "Okul öncesi boyama" ilk 20'sinde reklamlı uygulama oranı en düşük (6/19) ve TA oranı en yüksek (18/19): bu arama Cobi'nin konumuna en yakın küme.

Dört aramanın hepsinde ilk 20'ye giren dört uygulama: Boyama ve öğren (Orange Studios; dört aramanın üçünde 1. sıra), Çocuklar için Boyama Oyunları (IDZ/Kidlo), Prensesler - Boyama Kitabı (Orange), Coloring Games: Color & Paint (RV AppStudios). Üç aramada: Bebi Family, IDZ ikinci uygulama, Bini Games, Bimi Boo çizim. İki aramada: Game Tunes "Binky", Mini Muffin, Mini Pixel, Toy Tap "Çocuklar Boyama Kitabı", Kakadoo, Play and Learn, Sunny, Disney, BabyBus Prenses. Kalan 20 uygulama yalnız bir aramanın ilk 20'sinde.

### 1.2 Vitrinde ortak vaatler (37 çocuk uygulamasının açıklama ve "Yenilikler" metni)

| Vaat | Kaç uygulama | Örnek ifade |
|---|---|---|
| Yaş aralığı vurgusu ("2–5 yaş", "1 yaş ve üzeri", "bebek", "yürümeye başlayan") | 26/37 | Bebi "2-6 yaş arası"; Mini Muffin "1 yaş ve üzeri"; Kakadoo "2,3,4 veya 5 yaşındaki" |
| Fırça ve kalem çeşidi | 19/37 | Yamo "9 fırça"; Bimi Boo "kurşun kalem, fırça, sprey, pastel boya, keçeli kalem ve tebeşir" |
| İnce motor, el-göz koordinasyonu (eğitici vaat) | 19/37 | Budge "ince motor becerilerini, renk tanımayı"; Toy Tap "El-Göz koordinasyonunu" |
| Çıkartma, damga | 15/37 | Orange "100'den fazla pul"; Jogni "günlük çıkartma ödülü" |
| Paylaşım (galeri, e-posta, sosyal) | 15/37 | Orange albüm ve paylaşım; Toy Tap "kreasyonlarınızı paylaşın" |
| Kaydetme, galeri | 12/37 | Fat Tuna "ilerleme otomatik olarak kaydedilir" |
| Çevrimdışı, internetsiz (metinde) | 12/37 (Play etiketi 33/37) | Editale "WiFi olmadan çalışan"; Fat Tuna "Hesap, kayıt veya internet bağlantısı gerekmez" |
| Parıltı, sim, neon, "parlak boya" | 12/37 | Midwin "YENİ PARLAK BOYAMA MODU"; Fat Tuna "Simli, neon ve gökkuşağı fırçaları" |
| Animasyon, çizimin canlanması | 11/37 | Bebi "Sesli ve animasyonlu 400'den fazla boyama sayfası"; Play and Learn "çizimlerinizin canlandığını" |
| Taşmayan dolgu, tek dokunuşla doldurma, sihirli boya | 10/37 | Kakadoo "konturun sınırlarının ötesine geçmez"; Fat Tuna "Çizgilerin içinde kal"; Disney "Sihirli Boya" |
| Reklamsız vaadi (metinde) | 10/37 | RV "Reklam yok, uygulama içi satın alma yok"; Bebi "Tamamen Reklamsız" |
| Batı bayramları (Noel, Cadılar Bayramı, Paskalya) | 8/37 | IDZ "Noel ve Paskalya'yı kutlayın"; Meemu "Halloween & Christmas coloring sets" |
| Sayıyla boyama | 7/37 | RV "sayılara göre boyama"; Bini "Sayılarla boyama oyunları" |
| Tablet vurgusu | 6/37 | Orange "Hem Tabletlerde hem de Telefonlarda mükemmel çalışır"; Bebi tablet kavramasına "Dokunmatik Koruma" |
| Harf ve sayı öğretimi | 5/37 | Orange "Alfabe ve sayıları yazmayı öğrenecekler"; Sunny "Alfabe harflerini ve telaffuzlarını" |
| Ebeveyn kapısı, ebeveyn kontrolü, dokunma koruması | 4/37 | Bebi "Ayarlar penceresi, harici bağlantılar ve satın alımlar 'Ebeveyn Kontrolü' ile korunmaktadır"; Fat Tuna "ebeveynler kutlama efektlerini kapatabilir" |
| Seslendirme (dil belirtilmemiş) | 3/37 | Bebi "Sesli ve animasyonlu"; Toy Tap "Animasyonlar ve Seslendirmeler"; Sunny "telaffuzlarını öğrenin" |
| Çocuk başına profil | 2/37 | RV Coloring Games; Mini Pixel ikinci uygulama |
| Türkçe'ye özgü bir şey (Türkçe ses, Türk bayramı, yerel nesne, Türk karakteri) | 1/37 (yalnız çok dilli renk adı) | Mini Pixel "renkleri farklı dillerde öğrenebilir: İngilizce ... Türkçe" |
| Yazdırma | 0/37 | — (TRT Piksel Boyama vitrin dışında: "İstersen yazdırıp duvarına asabilirsin") |

Sayım sınırı: yalnız metin arandı; bir özellik açıklamada geçmiyorsa uygulamada yok anlamına gelmez. Ekran görüntüsü alt yazıları okunmadı.

### 1.3 Uygulama tablosu (dört aramanın ilk 20'sindeki 37 çocuk uygulaması)

Sıra sütunu: s1 "çocuk boyama", s2 "boyama oyunları", s3 "boyama kitabı çocuk", s4 "okul öncesi boyama". Öne çıkan özellikler açıklama metninin ilk bölümünden; "TR'ye özgü" = Türkçe seslendirme, Türk bayramı, yerel nesne ya da Türk karakteri vaadi.

| Uygulama (geliştirici) | Paket | Sıra | Puan sayısı | TA | Öne çıkan 3 özellik | TR'ye özgü |
|---|---|---|---|---|---|---|
| Boyama ve öğren (Orange Studios Games) | com.orange.coloring.learn.kids | s1:1 s2:1 s3:1 s4:4 | 292 B | 8 yaşa kadar | 200+ sayfa ve serbest mod; alfabe-sayı yazma, 100+ pul; albüm ve paylaşım, "tabletlerde mükemmel" | yok (Noel, Halloween içerik) |
| Çocuklar için Boyama Oyunları (IDZ Digital / Kidlo) | com.iz.coloring.games.kids.drawing.book.color.by.number | s1:2 s2:8 s3:5 s4:7 | 31,3 B | 12 yaşa kadar | 14 kategoride 700+ oyun; sihirli kalemler, sürpriz ve canavar boyama; Noel-Paskalya festival oyunları | yok |
| Prensesler - Boyama Kitabı (Orange Studios Games) | com.orange.gamesforkids.coloring.princess | s1:14 s2:11 s3:3 s4:16 | 45,9 B | 8 yaşa kadar | 200+ prenses sayfası; 100+ çıkartma; piyano, hafıza ve tırnak salonu mini oyunları | yok |
| Coloring Games: Color & Paint (RV AppStudios) | com.rvappstudios.kids.coloring.book.color.painting | s1:3 s2:4 s3:6 s4:9 | 124 B | 12 yaşa kadar | reklam yok, IAP yok, ödeme duvarı yok (metin); sayıyla boyama ve karalama modları; çocuk başına profil ve zorluk | yok |
| Coloring games for kids: 2-5 y (Bebi Family) | com.bebi.family.baby.coloring | s1:4 s2:13 s3:9 s4:27 | 34,8 B | 5 yaşa kadar | 400+ sesli ve animasyonlu sayfa; Dokunmatik Koruma (başparmak kenarda); Ebeveyn Kontrolü (ayar, satın alma, dış bağlantı) | yok (ses dili belirtilmemiş) |
| Çocuk Boyama Oyunlar & Kitabı (IDZ Digital) | com.iz.coloring.games.kids.drawing.color.book.painting.learning.baby.toddlers | s1:16 s3:2 s4:2 | 5,7 B | 8 yaşa kadar | 50+ sayfa, 1–5 yaş; WiFi olmadan çalışır; "Button Art" (Yenilikler İngilizce) | yok |
| Çocuk çizim ve boyama oyunları (Bini Games) | com.binibambini.acad.drawing | s1:10 s2:14 s4:3 | 16,6 B | 8 yaşa kadar | adım adım çizim akademisi; sayıyla boyama; canlanan karakterler ve çıkartma | yok |
| Bebek çizim - boyama oyunları (Bimi Boo) | com.bimiboo.kids.drawing | s1:15 s2:19 s4:5 | 25,5 B | 5 yaşa kadar | noktalı çizgi izleme; resimlerin canlanması; "okul öncesi eğitim uzmanları" ve reklamsız vurgusu | yok |
| 1+ yaş için boyama oyunu (Mini Muffin) | com.minimuffin.coloringstories | s1:28 s2:18 s4:10 | 1,47 B | 5 yaşa kadar | 1 yaş ve üzeri; "stres-free" basit arayüz; fırça, kalem, silgi, parıltı | yok |
| Çizim Oyunları: Çizim ve Renk (RV AppStudios) | com.rvappstudios.kids.drawing.games.coloring.book.paint | s1:25 s2:20 s4:24 | 27,9 B | yok | noktaları birleştirme; parıldayan boya; rakamlara göre boyama, ücretsiz | yok |
| Çocuk Resim Boyama Oyunları 2+ "Binky" (Game Tunes) | com.GameChangers.Coloringforkids | s1:12 s4:1 | — | 5 yaşa kadar | 150+ sayfa; pastel, fırça, çıkartma, sayıyla boyama; çevrimdışı | yok |
| Çocuklar Boyama Kitabı (Toy Tap) | com.toddler.coloring | s1:17 s3:4 | 14 B | yok | el-göz koordinasyonu vaadi; animasyon ve seslendirme (dil yok); fırça, kalem, silgi, galeri | yok |
| Easy coloring book for kids (Kakadoo) | com.joongly.coloring.kids | s1:6 s3:11 | 8,23 B | 8 yaşa kadar | 2–5 yaş; hayvan, araba, dinozor, uzay; "konturun sınırlarının ötesine geçmez" (taşmayan) | yok |
| Çocuk çizim - boyama oyunları (Mini Pixel) | minipixel.easy.coloring.pages.draw.kids.painting | s1:7 s4:13 | 229 | 12 yaşa kadar | parlak boya; sihirli fırça; çevrimdışı ve paylaşım | yok |
| Coloring & Drawing for Kids (Play and Learn Games) | com.pages.kids.toddlers.painting | s1:11 s4:8 | 30 | 8 yaşa kadar | çizimlerin canlanması; kalem-fırça-çıkartma; galeri; Noel | yok |
| Çocuklar için Boyama Oyunları (Budge Studios) | com.budgestudios.googleplay.BabyColoringBook | s1:9 s3:26 | 4,26 B | 5 yaşa kadar | 2–6 yaş; ince motor ve renk tanıma vaadi; fırçalar; abonelik | yok |
| Coloring Book - Kids Paint (Sunny Kid Games) | com.sunny.coloring.book.kids.paint | s1:13 s3:12 | 13 B | 8 yaşa kadar | hepsi bir arada eğitim paketi; çıkartmalı manzara; enstrüman ve alfabe telaffuzu (dil yok) | yok |
| Prenses Oyunu: Fantezi Boyama (BabyBus) | com.sinyee.babybus.princess_coloring_fantasy_magic_girls_games | s2:17 s3:14 | 38,5 B | yok | prenses çerçeveleri; farklı kültürlerden prensesler (Arabistan, Çin, Mısır); kaydet-paylaş | yok |
| Boyama Oyunları, Boyama Oyunu (Mini Pixel) | minipixel.kids.color.games.paint.coloring.drawing.painting.book.preschool | s2:22 s4:14 | 511 | 12 yaşa kadar | sayıya ve resme göre renklendirme; karalama; profil | renk adları çok dilli (Türkçe dahil) |
| Disney Coloring World (StoryToys) | com.storytoys.disney.pixar.coloring.princess.googleplay | s1:19 s2:15 | 60 B | 6-8 yaş | 2.000+ Disney sayfası; Sihirli Boya (taşmaz); giydirme ve 3D oyun setleri; çevrimdışı | yok |
| Çocuk Boyama ve Boyama Oyunu (kidsplaylearninggames.com) | com.kplg.colorbook | s3:16 s4:28 | — | 12 yaşa kadar | 1–6 yaş; fırça ve kova, simli-sprey, damga, geri al, kaydet; hayvan, dinozor, meyve-sebze | yok |
| çocuklar Boyama kitabı App (Riafy) | coloring.book.apps.kids | s3:17 s4:26 | 667 | yok | yüzlerce boyama fikri; sayıyla boyama; paylaşım | yok |
| Little Panda's Kids Coloring (BabyBus) | com.sinyee.babybus.paintingIII | s1:5 | 5,39 B | yok | 2 yaşın kullanabileceği arayüz; boyama ve karalama modları; sihirli kalemler, 4 tema | yok |
| Okul Öncesi Resim Boyama (HunGames) | com.hungames.paint | s4:6 | — | 12 yaşa kadar | Türkçe yazılmış (çeviri değil) kategori listesi: safari, orman, çiftlik; kova ve basit mekanikler; çevrimdışı, reklamsız | yok (metin özgün Türkçe; geliştirici ülkesi doğrulanmadı) |
| Bebek Boyama Kitabı Çocuklar (Midwin Games) | com.midwin.kids.drawing.book.toddlers.coloring.games.preschool.painting | s3:8 | 375 | 12 yaşa kadar | "parlak boyama modu" (neon fırça); küçük eller için; piksel sanat | yok |
| Çocuklar için Boyama ve Çizim (Toy Tap) | com.tt.coloring.drawing | s3:10 | 6,5 B | 12 yaşa kadar | yeni karakter kilidi açma; paylaşım; animasyon; abonelik | yok |
| Çocuk ve Okul Öncesi Oyunları (RV AppStudios) | com.rvappstudios.toddler.preschool.kids.learning.games | s4:11 | 10 B | 5 yaşa kadar | eğitim oyunu paketi (boyama bir modül); reklamsız, ücretsiz; sayı sıralama modu (Yenilikler) | yok |
| Bebek oyunları - boyama kitabı (Yamo Game) | com.yamo.paint | s4:12 | — | 8 yaşa kadar | 9 fırça (kurşun kalem, sprey, kum, gradyan); şablonlar; çevrimdışı, kaydet-paylaş | yok |
| Pixel Art Coloring - Art Games (HDuo) | happy.pixel.coloring.art.color.games | s2:12 | 137 B | yok | 6–12 yaş etiketli sayıyla piksel boyama; günlük yeni resim; Noel-Cadılar Bayramı | yok |
| Eğlenceli Boyama Kitabı Çizimi (Y-Group / Yovo) | com.YovoGames.paintinganimals | s3:13 | 12,5 B | yok | yüzlerce sayfa, haftalık yeni; başarımlar ve ödüller (çıkartma, renk bombası); animasyon ve sayıyla boyama | yok |
| Çocuklar için Boyama Oyunları (Jogni Apps Studio) | com.basi.kidscoloring | s4:15 | — | 12 yaşa kadar | glitter ve desen fırçaları; "büyük, sevimli düğmeler"; günlük çıkartma ödülü, ebeveyn kapısı, çevrimdışı | yok |
| Prenses Boyama Kitabı Oyunu (kidsplaylearninggames.com) | com.kidsplaylearninggames.coloring.book.girls | s3:15 | — | 12 yaşa kadar | 50+ sayfa; fırça, kova, silgi, geri al; parıltı ve canlandırma | yok |
| Çocuklar renkler ve şekiller (RV AppStudios) | com.rvappstudios.shapes.colors.toddler | s4:17 | 21,5 B | 12 yaşa kadar | renk-şekil eşleştirme mini oyunları; boyama bir modül; "aynı renkteki nesneleri toplayın" | yok |
| Kız oyunlar çocuk boyama oyunu (Bini Games) | com.binibambini.drawingforgirls | s4:18 | 22,4 B | yok | 3–8 yaş kız odaklı çizim; karakter boyama; eğitim vaadi | yok |
| Busy Kids! Çocuk boyama kitabı (Editale) | com.editale.kidsdraw | s3:18 | 1,21 B | 8 yaşa kadar | WiFi'siz ve reklamsız; Panda rehber; 500+ sayfa, galeri | yok ("Yenilikler" metni Türkmence; yerelleştirme hatası) |
| Super Kids Coloring Book (Fat Tuna) | com.fattuna.superkidscoloring | s1:20 | — | 8 yaşa kadar | hesap, kayıt, internet yok; tek dokunuşla doldurma + "Çizgilerin içinde kal" ayarı; 36 kalem (6 ten rengi), otomatik kayıt, kapatılabilir kutlama | yok (Halloween seti) |
| Renklendirme Çocuklar Çizim (Meemu) | com.meemu.coloring | s4:20 | — | 5 yaşa kadar | 2–6 yaş; boyama + öğrenme oyunları; Halloween ve Noel setleri (Yenilikler) | yok |

### 1.4 Vitrin dışı ama ilgili Türkçe odaklı uygulamalar (aynı gün Play TR)

| Uygulama (geliştirici) | Paket | Kurulum, puan sayısı | TA | Reklam | Özellik | Not |
|---|---|---|---|---|---|---|
| Minik Fırça: Sesli Boyama (VIPGO TECH LTD) | com.vipgotech.minikfirca | 1 B+, puan yok | yok | yok | "Türkçe sesli rehber": renk önerir, nesne bilgisi verir, bitince tebrik eder; çocuğun adıyla konuşur; 100 resim (15 ücretsiz, 85 tek seferlik IAP); reklamsız | 30 Ekim 2026'da güncel; Türkçe seslendirme vaat eden tek boyama uygulaması |
| Çocuklar İçin Boyama Oyunu (DoDe Digital Studio) | com.dodedigital.boyama | 100+, 5 puan | yok | var | "Türkçe Seslendirmeli Boyama Oyunu"; harf ve rakam; dokunma sesleri | son güncelleme 16 Haziran 2023 |
| Sevimli Dostlar Çocuk Oyunları (Adisebaba) | com.gamester.sevimliDostlar | 100 B+, 187 | yok | yok | "Türkçe ve İngilizce içerik ve seslendirme"; boyama bir modül; abonelik | 2,9 puan |
| Penki Color: Çocuk Boyama (VFX Tricks) | com.penki.color.app | 10 B+, 213 | yok | yok | fırça ve kova dolgusu; basılı tutunca renk ipucu; "asla abonelik yok"; Noel ve Cadılar Bayramı temaları | Türkçe ses vaadi yok |
| Kral Şakir - Boyama Kitabı (Bretzel Games) | com.bretzelgames.kralsakir.boyamakitabi | 10 B+, 57 | yok | var | onlarca sayfa; renk seç, parçaya dokun; silgi; iki parmakla yakınlaştırma; 90+ renk | yerli lisanslı tek boyama kitabı; 3,6 puan |
| TRT Piksel Boyama (TRT) | com.trtcocuk.pikselboyama | 1 Mn+, 2,99 B | 5 yaşa kadar | yok | TRT Çocuk kahramanlarını sayıyla piksel boyama; yakınlaştırma; kaldığın yerden devam; bitince telefona otomatik kayıt; "yazdırıp duvarına asabilirsin" | açıklama "6 yaş ve üzeri" diyor, rozet "5 yaşa kadar" |
| TRT Çocuk Anaokulum (TRT) | com.trtcocuk.anaokulum | 5 Mn+, 7,06 B | 8 yaşa kadar | yok | Montessori tipi bölümler; "resim, müzik" bölümünde boyama | son güncelleme 27 Ekim 2025 |

### 1.5 Türkçe'ye özgü özellik var mı?

- İlk 20'lerdeki 37 çocuk uygulamasının hiçbirinde Türkçe seslendirme, Türk bayramı, bayrak, Atatürk, yerel nesne ya da Türk masal kahramanı vaadi yok. Yabancı lisanslı karakter var (Disney Coloring World ilk 20'de; My Little Pony ilk 30'da), yerli lisanslı karakter ilk 30'da yok.
- Türkçeleştirme düzeyi "mağaza metni çevirisi": başlıklar Türkçe ("Çocuklar için Boyama Oyunları", "Bebek çizim - boyama oyunları"), açıklamalar çeviri. Çeviri kalitesi düşük örnekler var: Orange "Başvurumuzdan memnun musunuz?" (application = başvuru), Editale'nin "Yenilikler" metni Türkmence.
- Seslendirme vaat eden 3 uygulama (Bebi, Toy Tap, Sunny) dil belirtmiyor. Mini Pixel'in ikinci uygulaması renk adlarını Türkçe dahil 10+ dilde söylüyor; nesne adı vaadi genel.
- Sezonluk içerik 8/37'de var, hepsi Batı takvimi (Noel 7, Cadılar Bayramı 5, Paskalya 1). Ramazan, Kurban, 23 Nisan, 29 Ekim hiçbirinde yok.
- Türkçe seslendirmeyi açıkça vaat eden boyama uygulamaları vitrin dışında ve küçük: Minik Fırça (1 B+), DoDe Digital (100+). Sevimli Dostlar abonelikli paket.

### 1.6 Teacher Approved

- 37 uygulamanın 29'unda rozet var. Rozetsiz 8: BabyBus'ın iki uygulaması, Toy Tap "Çocuklar Boyama Kitabı", RV "Çizim Oyunları", Riafy, HDuo Pixel Art, Y-Group, Bini "Kız oyunlar". Rozetsizlerin 7'sinde reklam var (tek istisna RV "Çizim Oyunları").
- Rozet yaş etiketi 37 uygulamada: "5 yaşa kadar" 7, "8 yaşa kadar" 10, "12 yaşa kadar" 11, "6-8 yaş" 1, rozetsiz 8. Cobi'nin hedefi "5 yaşa kadar" etiketi; bu etiketi taşıyan 7 uygulamanın 6'sı reklamsız (Bebi, Bimi Boo, Mini Muffin, Game Tunes, RV okul öncesi, Meemu; Budge reklamlı).
- Program Türkçe metni destekliyor; inceleme otomatik; "yetişkinle birlikte kullanılmak üzere tasarlanmış" ya da "sınıf içi kullanım" diye konumlanan uygulamalar program dışı kalıyor (Google program sayfası, bölüm 9). Mağaza metninde bu ifadelerden kaçınılmalı.

---

## 2. Yerli markalar

Kaynak: Play TR sayfaları (hl=tr&gl=TR, 8 Kasım 2026), marka siteleri. Lisans alınması önerilmiyor; tablo rekabetteki beklentiyi gösteriyor.

| Marka | Boyama uygulaması ya da modülü | Geliştirici | Kurulum, puan, sayı | Ücret, reklam, IAP | TA | Boyama özellikleri |
|---|---|---|---|---|---|---|
| TRT Çocuk | TRT Piksel Boyama (`com.trtcocuk.pikselboyama`) | TRT | 1 Mn+, 3,7, 2,99 B | ücretsiz, reklam yok, IAP yok | var | sayıyla piksel boyama; yakınlaştırma; kaldığın yerden devam; otomatik kayıt; yazdırma ifadesi; "6 yaş ve üzeri"; Türkçe ses vaadi yok |
| TRT Çocuk | TRT Çocuk Anaokulum (`com.trtcocuk.anaokulum`) | TRT | 5 Mn+, 4,0, 7,06 B | ücretsiz, reklamsız | var | "Resim & Müzik" bölümünde boyama modülü |
| TRT Çocuk | TRT Çocuk Oyun Dünyası (`com.trtcocuk.gameworldapp`) | TRT | 1 Mn+, 4,6, 8,81 B | ücretsiz, reklamsız, IAP ₺72,99–₺609,99 görünüyor | var | 36 oyun içinde "Çizme Boyama Oyunu"; 3–8 yaş |
| TRT Çocuk | Kanal uygulaması, Kuzucuk, Kitaplık, ÇizBul, Sürpriz Kutusu, Yapboz, Kare, Bilgi Adası | TRT | 500 B+ – 5 Mn+ | ücretsiz, reklamsız | çoğunda var | boyama yok (Sürpriz Kutusu'nda araç olarak boya kutusu) |
| Niloya | Niloya resmî uygulaması (`com.Sentries.Niloya`) | Sentries | 100 B+, 3,9, 175 | ücretsiz, **reklam var** | var | Play metninde boyama yok; niloya.com "fark bulma ve boyama gibi farklı oyunlar" diyor. "Niloya Boyama" adlı uygulama yok |
| Pırıl | Pırıl Boyama (`com.piril.boyaar`) | ATF Play | 50 B+, 2,9, 152 | ücretsiz, reklam var | yok | ekran içi boyama değil; basılı kitabın AR tamamlayıcısı ("Kamerayı boyadığınız sayfaya tutun") |
| Kukuli | — | — | — | — | — | resmî uygulama bulunamadı; 3. parti şarkı-video uygulamaları (Emeli apps), boyama yok |
| Rafadan Tayfa | TRT Tornet, Mahalle, Hayri Uzayda; 3. parti Hayri ve patenci oyunları | TRT; Duru-Çağ; HorizonEdge | 1 Mn+ (TRT) | TRT: reklamsız; 3. parti: reklamlı | karışık | boyama yok; yerel içerik var (İstanbul sokakları, bayrak, simit, baklava) |
| Pepee / Düşyeri | Uppy (`com.dusyeri.uppy`) | Düşyeri | 100 B+, 3,8, 1,37 B | abonelik ₺49,99–₺999,99 | yok | açıklamada boyama ve Pepee geçmiyor; 5 dil |
| Kral Şakir | Kral Şakir - Boyama Kitabı (`com.bretzelgames.kralsakir.boyamakitabi`) | Bretzel Games | 10 B+, 3,6, 57 | ücretsiz, reklam var | yok | alan doldurma, silgi, yakınlaştırma, 90+ renk; kayıt, ses, yazdırma vaadi yok |
| Harika Kanatlar | Harika Kanatlar Bebek oyunları (`com.edujoy.superwings`) | AppQuiz | 1 Mn+, 3,9, 4,36 B | reklam var, IAP var | var | "Resim müzesi" boyama mini oyunu; oyunlar İngilizce |
| Canım Kardeşim, Akıllı Tavşan Momo, Elif'in Düşleri, Keloğlan, İbi, Ege ile Gaga, Maysa ve Bulut | TRT oyunları | TRT | 1 Mn+ – 5 Mn+ | ücretsiz, reklamsız | çoğunda var | boyama yok; Maysa ve Bulut'ta "yöresel kıyafetler", "Anadolu kültürü"; Elif'te Türkçe karakter sesi |
| Nasreddin Hoca | Nasreddin Hoca ile Çarpma (`com.virwa.hocaoyunu`) | Virwa | 100+ | ücretsiz | yok | çarpım tablosu; TRT uygulaması yok |
| Limon ile Zeytin, Doru, Aslan | — | — | — | — | — | uygulama bulunamadı |

Web: trtcocuk.net.tr'de boyama bölümü yok (`/boyama` 404; menü Video, Oyun, Canlı TV); niloya.com ve rafadantayfa.com'da yazdırılabilir boyama yok; kralsakir.com ve kukuli.com açılamadı.

Okuma: Yerli markalar boyamayı ya hiç sunmuyor ya da TRT gibi ücretsiz-reklamsız ama Türkçe sessiz ve 6 yaş üstü piksel biçiminde sunuyor. Yerli lisanslı tek boyama kitabı (Kral Şakir) 10 B+ kurulum ve 3,6 puanla küçük kalmış; lisans tek başına Türkiye'de boyama uygulamasını büyütmüyor. Rekabetteki beklenti "TRT gibi güvenli ve ücretsiz" olmak; TRT'nin boşluğu 3–5 yaş için taşmayan dolgu ve Türkçe seslendirme.

---

## 3. Ebeveyn istekleri

Kaynak kümesi (8 Kasım 2026): Ekşi Sözlük 11 başlık, Kadınlar Kulübü 4 konu, DonanımHaber 5 konu, YouTube 13 video, 4 anne blogu ve derleme, Play TR 14 uygulama sayfası (240 Türkçe yorum), App Store TR 3 RSS akışı ve 5 mağaza sayfası (103 yorum). Reddit ve Instagram/TikTok açılamadı (bölüm 8). "Kaynak sayısı" = temanın geçtiği ayrı sayfa sayısı. Yorumların bir bölümünün yazarı çocuk; ebeveyn sesi öne alındı.

| Tema | Kaynak sayısı | Yön | Kısa alıntı (≤12 kelime) ve kaynak |
|---|---|---|---|
| Reklam: sıklık, çocuğun reklama tıklayıp çıkması, uygunsuz reklam | 16 | şikâyet; reklamsızlar övgü | "reklam çıkınca çocuk sürekli oyundan çıkıyor" (Play, Boyama ve öğren, 10.08.2026); "3 yaşındaki çocuk ya yanlışlıkla alım yapacak ya da reklamlarda kaybolacak" (Play, Çocuklar Boyama Kitabı, 19.10.2023); "güvenli, reklamsız ve öğretici uygulamalar bulmak gerçekten mesele" (Ekşi, "çocuklar için uygulamalar", 05.06.2025) |
| Yaşa uygunluk: küçük simgeler, çok ince seçim, içerik çabuk bitiyor | 12 | şikâyet | "Simgeler2 buçuk yaşındaki çocuğumuz için zorlayıcı" (Play, TRT Çocuk Anaokulum, 21.03.2021); "5 yaş altı çocukların profosyenel renk seçim yapması beklenilmemeli" (Play, TRT Piksel Boyama, 26.01.2020); "15 20 dk da oyunu çözdü, bitti" (Play, TRT Çocuk Anaokulum, 20.12.2020) |
| Türkçe yok, Türkçe seslendirme isteği | 11 | şikâyet; Türkçe ses övgü; 2 karşı görüş | "Türkçe dil seçeneğini bekliyoruz" (Play, Boyama ve öğren, 23.01.2024); "'A' dediğim harfe bilgisayar 'ey' deyince çocuğun kafası karışıyor" (DonanımHaber, 3 yaş konusu, 2013); "Türkçe seslendirmesi çok güzel olmuş" (Play, DoDe Digital, 19.06.2023); karşı görüş "şimdi iyki türkçe değil diyorum" (Ekşi, "khan academy kids", 2023) |
| Sesli renk, rakam, şekil adları; eğitici katkı | 10 | istek; el becerisi övgü | "rakamlarda, şekillerde ve renklerde özellikle isimleri seslendirilebilirdi" (Play, TRT Çocuk Anaokulum, 03.04.2020); "çocukların sessiz şeylerden sıkıldığını söyleyebilirim" (App Store, TRT Çocuk Anaokulum, 23.03.2020); "boyama yapıp elbecerisini geliştirir" (Play, Boyama ve öğren, 14.04.2021) |
| Ebeveyn kontrolü, ekran süresi, veli paneli | 10 | beklenti | "yaş*10 dakika olması gerekiyor süre olarak da" (Kadınlar Kulübü, "6yaş ekran süresi", 2023); "anneanne dedenin de kullanabileceği yönlendirici bir uygulama" (Kadınlar Kulübü, 2022) |
| Yerli karakter ve TRT güveni | 7 | TRT = güven; karakter eksikliği şikâyet | "Sonuçta güvenilir bir site TRT nin oyunu" (Play, TRT Çocuk Anaokulum, 09.02.2021); "Oyunda az karekter var bazıları yok mert yok kamil yok tosi yok" (Play, TRT Piksel Boyama, 17.04.2021). Niloya, Pırıl, Rafadan Tayfa, Kukuli boyama talebi **bulunamadı** |
| Çocuğun uygulamadan çıkması, ayarları bozması, yanlışlıkla satın alma | 6 | şikâyet; dokunma kilidi isteği | "telefonun ayarlarını kurcalayıp bozuyor" (DonanımHaber, 2012); "ekran kitleme özelliği de olsa mükemmel olur" (Play, Coloring Games, 16.08.2026); "bebek için verdiğimizde ekranda düzgün oynayamıyo birden çok parmağıyla oynasa" (Play, Coloring Games, 16.08.2026) |
| Boyama mekaniği: taşma, yanlış dokunuşun bozması, kayıt kaybı, cihaz değiştirme | 6 | şikâyet | "boyama yaparken çizgiden dışarı taşımaması daha iyi olurdu" (Play, Boyama ve öğren, 23.01.2024); "her dokunduğumuz yeri boyuyor" (Play, TRT Piksel Boyama, 2020); "bi resim yaptıktan sonra kayıt olmuyor yine beyaza dönüyor" (Play, IDZ, 29.01.2023); "resimleri başka telefona tasiyamiyoruz" (Play, TRT Piksel Boyama, 2023) |
| Donma, çökme, eski cihazda açılmama | 6 | şikâyet | "Oyun sürekli kasma donma yapıyor" (Play, Bebi, 24.05.2026); "dili türkçe yapınca donuyor ingilizceye çevirince çalışmaya başladı" (Play, Bebi, 05.05.2025); "Eski tabletlerde destek yok! Alt tarafı 2 yıllık tablet!" (App Store, TRT Anaokulum, 2020). **Pil ve ısınma: 0 kaynak** |
| Kaydetme, paylaşma, yazdırma | 6 | galeri kaydı övgü; yazdırma yalnız blog derlemelerinde | "yaptımız resmi galeriye aktarıyor" (Play, TRT Piksel Boyama, 2020); "çıktısını alıp asabilirsiniz" (Hürriyet Aile derlemesi). **Hiçbir ebeveyn yorumu yazdırma istemiyor** |
| Korkutucu ya da uygunsuz içerik | 5 | şikâyet | pasta bölümünde "kuru kafalar ve korkutucu yüzler" (App Store, KidloLand, 12.08.2024; WebFetch özeti); "Bazen çok renklerden dolayı mide bulandırıyor" (Play, TRT Piksel Boyama, 2021) |
| İçerik çabuk tükeniyor, yenilik isteği | 4 | şikâyet | "sıkıldım, hep aynı, ben zaten yaptım, istemiyorum" (Play, TRT Çocuk Anaokulum, 2020); "neredeyse 1 günde bitirdi" (Play, Bimi Boo Çizim, 2022) |
| İnternet zorunluluğu, çevrimdışı | 4 | çevrimdışı övgü; interneti kapatmak reklam çözümü | "internetsiz oynayamioz tek sorun bu" (Play, Boyama ve öğren, 2020); "interneti kapattığınızda reklam çıkmıyor" (Play, IDZ, 2022); "Uçak modunda veriyorum telefonu" (Kadınlar Kulübü, 2024) |
| Pasif izleme yerine aktif uğraş | 3 | övgü | "sadece video izleyip pasif halde kalmaması için çok güzel bir uygulama" (Play, Boyama ve öğren, 26.10.2022) |
| Birlikte oynama (büyükanne, abla) | 3 | övgü | "Torunumla sürekli boyama yapıyoruz" (Play, DoDe Digital, 2023) |
| Ses ve müzik eksikliği, kulaklıksız ses | 1 kaynak, 3 yorum | şikâyet | "Kulaklıksız sesleri duyamıyor çocuk" (App Store, TRT Anaokulum, 24.03.2020) |

Kaynak notları:
- Ekşi Sözlük'te boyama uygulamasına özel başlık yok; tartışma "çocuklar için uygulamalar", "khan academy kids", "youtube kids" başlıklarında. Ölçüt üçlüsü açıkça yazılı: "güvenli, reklamsız ve öğretici". Khan Academy Kids'te en küçük yaşın ilk kullanımı boyama ("boyamasini yapiyor sadece", 25.10.2026).
- Kadınlar Kulübü'nde tek doğrudan 3 yaş konusu (Kasım 2024, 20 mesaj): öneriler TRT Çocuk Anaokulum, Lingokids, MentalUP; yanıtların çoğu ekran karşıtı; bir anne bilinçli olarak sıkıcı ve tekdüze içerik istiyor.
- DonanımHaber'de eğitimci yanıtı: 3 yaş için harf oyunu değil "basit puzzle ve boyama uygulamaları" (2013). Türkçe harf-rakam isteği 2013 ve 2014 konularında.
- YouTube'da ebeveynin kendi sesiyle boyama uygulaması değerlendirdiği video bulunamadı; geliştirici tanıtımları, TRT'nin kendi incelemesi (257.877 görüntüleme) ve öğretmen serileri var.
- Play yorumlarında reklamsız RV uygulaması 9 yorumda "reklamsız" diye övülüyor; TRT uygulamalarında en sık istek seslendirme ve yeni etkinlik.

---

## 4. Öğretmenler ve takvim

### 4.1 MEB programında boyama, renk, şekil, sayı

Üç belge: Okul Öncesi Eğitim Programı (Şubat 2024; kazanım-gösterge; PDF 12 MB açılamadı, iki hakemli makaleden okundu), Türkiye Yüzyılı Maarif Modeli Okul Öncesi Eğitim Programı (2024, 349 sayfa; okundu) ve aynı programın 2026 baskısı (219 sayfa, dosya 23 Ekim 2026; okundu). Maarif'te "kazanım" yerine "öğrenme çıktısı" ve "alt öğrenme çıktısı" var.

| Alan | Kod ve metin | Boyama ile ilişki |
|---|---|---|
| Küçük kas (Hareket ve Sağlık) | HSAB.2 "Farklı ebat ve özellikteki nesneleri etkin bir şekilde kullanabilme" (2024, s. 73); alt çıktı b "Nesneleri şekillendirir." Açıklama "kopartma, yırtmak, katlama, boyama, resim çizme" (s. 73). 2026 baskısı 36–48 ay: "kalın boya kalemleri, parmak boyası" ile "kontrollü karalamalar"; "kusursuz bir ürün ortaya koymak değil" (s. 59) | Boyama bu çıktının içinde. Mağaza ve öğretmen metninde "küçük kas, el-göz koordinasyonu" demek programla uyumlu |
| Yazma öncesi (Türkçe) | 2024: TAEOB.6.a "Boyama ve çizgi çalışmaları yapar." (s. 28, 142). 2026: TAEOB.5 yalnız 60–72 ay için "kalemi üç parmağını işlevsel biçimde kullanarak doğru tutması" | 2026 baskısı 3–5 yaşta boyamayı yazma hazırlığı saymıyor |
| Renk | Hiçbir baskıda öğrenme çıktısı değil; Kavram Listesi'nde (2024 EK.9 s. 314; 2026 EK-7 s. 185). 36–48 ay aylık plan: "Renk (Kırmızı-Sarı-Mavi)" (s. 152; 2026 s. 121) | 3 yaş paletinde ana renkleri öne almak programla örtüşür |
| Şekil (Matematik) | MAB.9 "Farklı matematiksel temsillerden yararlanabilme": "İsmi söylenen şekli / rakamı gösterir"; açıklama çocukların şekli "göstermeleri, boyamaları, kutucuk içine almaları" (2024, s. 39) | Boyama, şekil tanımanın kabul edilen yanıt biçimi; daire, üçgen, kare, çember |
| Sayı (Matematik) | MAB.1 "Ritmik ve algısal sayabilme": 36–48 ay "1 ile 5 arasında birer ritmik sayar." (s. 142); 48–60 ay 1–10; 60–72 ay 1–20. Açıklama: "çalışma kağıtlarıyla boyamalar yaparak çalışmalar yürütülebilir" (s. 36) | "Say ve boya" sayfası 36–48 ay için 5'i geçmemeli |
| Sanat | SNAB.4 "Sanat etkinliği uygulayabilme" (2024, s. 88): tür ve materyali çocuk seçer, özgün ürün. Program boyamaya eleştirel: etkinlikler "sadece kesip, yapıştırdığı, hamurla oynadığı ve boyama yaptıkları" olarak düşünülmemeli (s. 89) | MEB'e göre boyama sayfası sanat eğitimi değil motor beceri aracı |
| Dijital | 2026 baskısı yeni bölüm 13.3 "Dijital Öğrenme Ortamları" (s. 108): "ekran süresi kontrollü biçimde planlanmalıdır"; "pekiştirme amaçlı eğitsel dijital oyunlar planlanabilir" | Dijital oyun yalnız pekiştirme rolünde kabul ediliyor |

### 4.2 Sınıfta tablet mi, akıllı tahta mı?

- MEB FATİH kılavuzu (Siverek İlçe MEM kopyası, 2022) kurulum alanlarını "Derslikler (Anasınıfları hariç)" diye tanımlıyor; anaokulları "FATİH Projesi kapsamı dışındaki" kurum sayılıyor. Devlet anaokulunda etkileşimli tahta ve tablet standart değil.
- Sınıf araştırmaları il bazlı ve küçük: 97 öğretmenlik ankette en yaygın araçlar internet (%83,5) ve televizyon (%75,3); 167 öğretmenlik çalışmada TV, DVD, bilgisayar ve akıllı telefon. Ulusal tablet/tahta oranı bulunamadı.
- Öğretmen topluluğunda dijital marjinal: okuloncesi.net'te "Teknoloji" 16 konu, "Boyama Sayfaları" 1.500, "Sanat Etkinlikleri" 2.700 konu.
- YouTube ve Instagram'da "okul öncesi akıllı tahta boyama" paylaşımı araçlarla bulunamadı (araç sınırı olabilir).
- Çıkarım: "sınıf kipi" düşünülürse hedef dokunmatik tahta değil TV'ye yansıtma (Chromecast, AirPlay) ve öğretmenin kendi telefonu ya da tableti. Android tabanlı etkileşimli tahta panellerinde uygulama test edilmedi.

### 4.3 Yazdırılabilir içerik talebi

- Öğretmen ve ebeveyn boyama sayfasını ücretsiz kaynaklardan alıyor: okuloncesi.net Boyama Sayfaları (1.500 konu; alt forumlar Mandala 768, Meslekler 178, Hayvan 103, Mevsimler 79, Rakamlar 40), Pinterest "Okul Öncesi Boyama" fikir sayfaları, Canva Türkçe "Boyama Sayfası Şablonları" kategorisi, Sorubak belirli gün dokümanları. TRT Çocuk sitesinde boyama bölümü yok.
- Google Trends "boyama sayfası" ile "boyama oyunu" karşılaştırması alınamadı (HTTP 429, üç deneme). Hacim oranı bilinmiyor.
- Yazdırma vaat eden çocuk boyama uygulamaları (Coloring Pages for Zane, Colorific, Kids Color Pages, ColorPrint, Pintora) mağazada küçük; yazdırma hiçbirinde büyüme kaldıracı değil. TRT Piksel Boyama'nın Play TR açıklamasında yazdırma ifadesi var ("İstersen yazdırıp duvarına asabilirsin"), ikincil özellik. Play ilk 20'lerinde 0/37.
- Ebeveyn tarafı: yazdırma isteği hiçbir yorumda yok; yalnız 2016 ve 2021 tarihli iki blog derlemesinde özellik olarak sayılmış (bölüm 3).
- Karar: yazdırma mağaza sıralaması ve indirme için fark yaratmaz. Fark yaratabileceği iki yer: Anneler Günü ve bayram kartı (ebeveyn, elde tutma) ve öğretmen "sınıf paketi" PDF'i (uygulama dışında, web'de tanıtım aracı). Düşük maliyetli "PDF paylaş / yazdır" eklenip ölçülebilir; ayrı yazdırılabilir kütüphane kurulmamalı.

### 4.4 2027 sezon takvimi: okul öncesinde boyama etkinliğiyle işlenen günler

Tarih kaynakları: Diyanet 2027 Dini Günler Listesi (kendim doğruladım), MEB 2026-27 çalışma takvimi (kendim doğruladım: dersler 14 Eylül 2026–25 Haziran 2027; 1. ara tatil 16–20 Kasım 2026; yarıyıl 25 Ocak–5 Şubat 2027; 2. ara tatil 8–12 Mart 2027), MEB Sosyal Etkinlikler Yönetmeliği EK-8 (RG 18.01.2023 değişikliği), Maarif 2024 EK.10 ve 2026 EK-8. "Forum" = okuloncesi.net ilgili alt forumundaki toplam konu sayısı (2011–2016 ağırlıklı arşiv; yıllık değil). "Resmî" = Y Yönetmelik, M Maarif (2024 ve 2026).

| Gün / hafta | 2027 tarihi | Resmî liste | Forum | Boyama kanıtı | Tipik motifler (3 yaş için basitten zora) |
|---|---|---|---|---|---|
| Yılbaşı ve kış | 31 Ara 2026–1 Oca 2027; 31 Ara 2027 | M | 133 (+39 kış) | kardan adam kesme-yapıştırma | kar tanesi, kardan adam, çam ağacı, atkı-bere, hediye |
| Enerji Tasarrufu Haftası | 11–17 Oca | Y, M | 49 | sanat var, boyama başlığı görülmedi | ampul, güneş, musluk |
| Yarıyıl tatili | 25 Oca–5 Şub | MEB takvimi | — | ev kullanımı | — |
| Ramazan başlangıcı | 8 Şub (Pzt) | Diyanet | — | ay boyunca tema | hilal, kandil, mahya, pide, davul |
| Yeşilay Haftası | 1–7 Mar | Y | 31 | görülmedi | yeşil hilal, su, meyve |
| **Ramazan Bayramı** | arefe 8 Mar; **9–11 Mar (Sal–Per)**; ara tatil 8–12 Mar | M | 10 (Ramazan alt forumu) | "ŞEKERLER BOYAMA" (9 B görüntüleme), "ŞEKER BAYRAMI KARTI" | şeker, şekerlik, hilal, kandil, bayramlık, el öpme, kart |
| İstiklâl Marşı'nın Kabulü | 12 Mar | Y, M26 | 7 | görülmedi | bayrak |
| Çanakkale / Şehitler Günü | 18 Mar | Y | 63 | forumda yoğun; boyama örneği doğrulanmadı | bayrak (asker figürü 3 yaş için uygun değil) |
| **Orman Haftası** (+ Dünya Su Günü 22 Mar, Nevruz 21 Mar) | 21–26 Mar | Y, M | 75 | "orman haftası afiş çalışmamız" | ağaç, fidan, yaprak, sincap, orman hayvanları |
| Kütüphaneler Haftası | 29 Mar–4 Nis | Y, M | 25 | "Kitap Ağacı" | kitap, kitap kurdu |
| Sağlık Haftası | 7–13 Nis | Y | 63 | Beslenme boyamaları (36 konu) | diş fırçası, sabun, sebze-meyve, doktor |
| **23 Nisan Ulusal Egemenlik ve Çocuk Bayramı** | **23 Nis (Cum)** | Y, M | 43 (+ Gösteriler 270) | "23 Nisan Kutlu Olsun (Pankartlı Çocuklar Boyama)"; Sorubak "23 Nisan Dünya Çocukları Boyama Resmi" | bayrak, balon, dünya çocukları, pankart, Atatürk, TBMM |
| Trafik ve İlk Yardım Haftası | 3–9 May | Y, M | 41 | görülmedi | trafik lambası, araba, yaya geçidi |
| **Anneler Günü** | **9 May (Paz)**; sınıf etkinliği 3–7 May | Y, M | **258** (en kalabalık alt forum) | "Canım Annem Boyama Sayfası", "Annemiz İçin Kahve Fincanı Boyalım" | kalp, çiçek, lale, kart, fincan, anne figürü |
| Engelliler Haftası | 10–16 May | Y, M | 7 | "Engelliler Boyama Sayfaları" | el ele çocuklar, kalp |
| **Kurban Bayramı** | arefe 15 May; **16–19 May (Paz–Çar)**; 19 Mayıs ile çakışır; sınıf etkinliği 10–14 May | M | ≈68 (Dinî Bayramlar 78) | "Koyun Kalıpları ve Boyama Sayfaları" (29 B görüntüleme), "Sevimli İnek Kurban Bayramı Kartı" (40 B) | koyun, kuzu, inek, kart, el öpme |
| 19 Mayıs | 19 May (Çar; Kurban 4. gün) | Y | 24 | görülmedi | bayrak, sporcu |
| Çevre Günü / Haftası | 5 Haz; 7–13 Haz | Y, M | 18 | görülmedi | dünya, geri dönüşüm, ağaç |
| Babalar Günü | 20 Haz (Paz); sınıf etkinliği 14–18 Haz | Y, M | 55 | "KEÇEDEN KESME-YAPIŞTIRMA BABA FİGÜRÜ" | kravat, kalp, araba, baba figürü |
| Mezuniyet / yıl sonu | 25 Haz (Cum) | MEB takvimi | 40 (Yaz) + 24 (Okul) | "Mezuniyet Boyamaları" | kep, diploma, balon, güneş, deniz |
| 15 Temmuz, 30 Ağustos | okul kapalı | Y, M / Y | — | bulunamadı | bayrak |
| Okula uyum / İlköğretim Haftası | Eylül 2027 (2027-28 takvimi açıklanmadı; 2026'da uyum 7–11 Eylül) | Y, M | 46 (uyum) + 46 (sonbahar) | "OKULUN İLK GÜNÜ", "İtfaiyeci (boyama sayfası)" | okul çantası, kalem, servis, sonbahar yaprağı |
| **Hayvanları Koruma Günü** | **4 Eki (Pzt)** | Y, M | 44 | 1. sayfada 4 boyama başlığı ("HAYVAN SEVGİSİ BOYAMA") | köpek, kedi, kuş, yuva, mama kabı |
| Dünya Çocuk Günü | 4 Eki | hiçbir güncel listede yok | — | bulunamadı | — |
| **29 Ekim Cumhuriyet Bayramı** (+ Kızılay Haftası 29 Eki–4 Kas) | **29 Eki (Cum)** | Y, M | 52 (+27) | "Cumhuriyet Bayramı İçin Boyama Sayfası" (18 B), "Türk Bayrağı" | bayrak, balon, Türkiye haritası, Atatürk |
| **10 Kasım / Atatürk Haftası** | **10 Kas (Çar)**; hafta 10–16 Kas | Y, M | 104 | "10 Kasım İçin Atatürk Boyama Sayfası" (öğretmen notu: çizgiler ince), "Anıtkabir Boyama Sayfası" | bayrak, kalp, Anıtkabir, silüet, sonbahar yaprağı; portre 3 yaş için ayrıntılı |
| Dünya Çocuk Hakları Günü | 20 Kas | Y, M | 6 | görülmedi | el ele çocuklar, dünya |
| **24 Kasım Öğretmenler Günü** | **24 Kas (Çar)** | Y, M | 132 | 1. sayfada 3 boyama başlığı | çiçek, kalp, güneş, el baskısı, kart |
| **Yerli Malı (Tutum, Yatırım ve Türk Malları) Haftası** | **12–18 Ara** | Y, M | 47 | "yerli malı haftası boyama etkinlikleri"; MEB Erken Çocukluk 2025 çalışma sayfası | meyve-sebze, kuru yemiş, kumbara, pazar tezgâhı |
| Mevsimler | sonbahar Eyl–Kas, kış Ara–Şub, ilkbahar Mar–May, yaz Haz | — | 46 / 39 / 11 / 40 | "Sonbahar Yaprakları Boyama Sayfaları (Yaprak Kalıbı)", kardan adam | yaprak, kestane, şemsiye; kar tanesi; kelebek, uğur böceği, leylek; dondurma, karpuz |

Aylık toplam (okuloncesi.net belirli gün konuları): Mayıs 333 > Mart 283 > Kasım 267 > Aralık 255 > Nisan 151 > Ekim 143 > Haziran 137 > Eylül 130 > Ocak 70 > Şubat 22. 23 Nisan içeriği "Gösteriler" (270) ve "Sanat Etkinlikleri" bölümlerine dağıldığı için 43 sayısı düşük görünüyor.

Öncelik sırası (ölçütler: üç resmî listede varlık, öğretmen üretimi, tatil ve evde kullanım, 3 yaş için motif basitliği, Cobi'nin mevcut içeriğiyle örtüşme, tarih çakışması):

| Sıra | Tarih (2027) | İçerik yayında olmalı | Gerekçe |
|---|---|---|---|
| 1 | 23 Nisan (Cum) | 9 Nisan | her listede var; çocuk bayramı ebeveyn ve öğretmeni aynı anda yakalar; bayrak ve balon 3 yaş için basit; mağaza vitrini için en güçlü Türkiye'ye özgü tema |
| 2 | Ramazan Bayramı 9–11 Mart (Ramazan 8 Şubat'tan itibaren) | 1 Şubat | ara tatile (8–12 Mart) denk, çocuk evde; hilal, kandil, şeker basit; her yıl tarih kayar, takvim güncellemesi gerekir |
| 3 | Anneler Günü 9 Mayıs | 26 Nisan | öğretmen üretiminde açık ara birinci (258); satın alma kararını veren kişiye hediye; yazdırma ya da kart paylaşımının en anlamlı olduğu gün |
| 4 | Yılbaşı ve kış (Aralık) + Yerli Malı Haftası 12–18 Aralık | 1 Aralık | Yeni Yıl 133; kar tanesi ve kardan adam 3 yaş için ideal; meyve-sebze motifleri mevcut Yiyecekler setiyle örtüşür |
| 5 | 29 Ekim → 10 Kasım → 24 Kasım kümesi | 15 Ekim | üçü de her listede; toplam 288 konu; bayrak tek motifle üçünü taşır; Atatürk portresi yerine silüet, Anıtkabir, kalp, çiçek |
| 6 | Kurban Bayramı 16–19 Mayıs | 3 Mayıs | koyun, kuzu, inek Hayvanlar setiyle örtüşür; 19 Mayıs ile çakıştığı için sınıf etkinliği 10–14 Mayıs; Mayıs tek paket planlanmalı |
| 7 | Hayvanları Koruma Günü 4 Ekim + sonbahar | 20 Eylül | okul açılışıyla ilk tema; mevcut hayvan sayfaları yeniden etiketlenerek düşük maliyet |
| 8 | Orman Haftası 21–26 Mart | 8 Mart | 75 konu; ağaç ve orman hayvanı mevcut içerikle örtüşür; Ramazan Bayramı tatilinin hemen ardından |
| 9 | Babalar Günü 20 Haziran + mezuniyet 25 Haziran | 7 Haziran | 55 konu; yıl kapanışı |
| 10 | Sağlık Haftası 7–13 Nisan, Trafik Haftası 3–9 Mayıs | ikinci yıl | trafik lambası ve araba Araçlar setine uyar; diş ve doktor mevcut sette yok |

---

## 5. Türkçeye özgü içerik fırsatları

### 5.1 Rakipte yerel içerik var mı?

- Play "çocuk boyama" ilk 20'si ve dört aramanın birleşimi (37 çocuk uygulaması): bayrak, Atatürk, İstiklal Marşı, 23 Nisan, Ramazan, Kurban, nazar, simit, çay, lahmacun, dolmuş, lale, Van/İstanbul kedisi, leylek, Kapadokya, Boğaz Köprüsü, Truva atı, Keloğlan, Nasreddin Hoca, Karagöz-Hacivat, Türk çocuk şarkısı terimlerinin hiçbiri açıklama ve "Yenilikler" metinlerinde geçmiyor (0/37). "Bayram" eşleşmeleri yalnız Cadılar Bayramı ve Noel.
- Yerel içerik yalnız TRT oyunlarında ve 3. parti Rafadan Tayfa oyununda var: İstanbul sokakları (Tornet), yöresel kıyafet ve Anadolu kültürü (Maysa ve Bulut), bayrak (Hayri Uzayda), simit ve baklava (Hayri - Rafadan Tayfa). Hiçbiri boyama uygulaması değil.
- Basılı pazar (D&R okul öncesi boyama kategorisi, varsayılan sıralama, ilk 80 başlık): kavram ve yaş serileri 15, yabancı lisanslı karakter 14 (Bluey, Harry Potter, Peppa Pig), yerli lisanslı karakter 11 (Maysa ve Bulut, Kral Şakir, Momo), hayvanlar 6, sayı-harf 6, meyve-sebze-mevsim 6, taşıtlar 4, meslekler 3, dinî ve değerler 3 (Diyanet Vakfı), yerel şehir 1 ("Şeker Ankarayı Geziyor"), Atatürk ve millî bayram 0. Timaş Çocuk'un 27 boyama başlığında da bayram ve Atatürk yok. Okuma: millî gün içeriği ticari kitapta değil, öğretmenin ücretsiz çıktısında yaşıyor (10 Kasım 104 konu). Fırsat bu içeriği satmak değil, uygulama içi sezon seti olarak sunmak.

### 5.2 Türkçe nesne adı seslendirmesi

- Vitrindeki 37 uygulamanın hiçbiri Türkçe seslendirme vaat etmiyor; "sesli" diyen 3'ü dil belirtmiyor. Türkçe ses vaat edenler küçük: Minik Fırça (1 B+, yeni), DoDe Digital (100+, 2023'te kalmış), Sevimli Dostlar (abonelik, boyama modül, Türkçe + İngilizce). Mini Pixel renk adlarını çok dilde söylüyor.
- Ebeveyn talebi net (bölüm 3: Türkçe 11 kaynak, sesli ad 10 kaynak). TRT Anaokulum yorumları seslendirme eksikliğini en sık istek yapmış.
- İkinci dil: "Türkçe İngilizce kelime öğrenme çocuk boyama" aramasının ilk 20'si yalnız İngilizce öğretme uygulamaları; boyama ile birleşik ürün yok. Cobi'nin Manzara prototipindeki "adını Türkçe + İngilizce duy" yaklaşımının Play'de karşılığı yok.

### 5.3 Yerel nesne ve kahraman sayfaları

- Aday nesneler (rakipte yok): simit, çay bardağı, nazar boncuğu, lahmacun, dolmuş, lale, İstanbul kedisi ve Van kedisi, leylek, Kapadokya balonu, Boğaz Köprüsü, Truva atı, Galata Kulesi. Mevcut setlerle örtüşme: Yiyecekler (simit, çay, lahmacun), Araçlar (dolmuş, balon), Hayvanlar (kedi, leylek), Bitkiler (lale).
- Masal kahramanları: Keloğlan (folklor, en geç 17. yüzyıl), Nasreddin Hoca (1208–1284; fıkra anlatma geleneği UNESCO 2022), Karagöz-Hacivat (UNESCO 2009), Dede Korkut (UNESCO 2018) kamu malı. TRT'nin Keloğlan çizgi dizisi tasarımı (2009, ANIMAX) FSEK md. 4 kapsamında korunan tipleme; kendi çizimle kullanım gerekir. Karagöz tasvirlerinin belirli bir sanatçı çizimi ayrıca korunabilir.
- Türk çocuk şarkıları: FSEK md. 27 koruma süresi ölüm + 70 yıl; md. 6 düzenleme ayrıca korunur; md. 80 kayıt ve icra bağlantılı hak. Ali Babanın Çiftliği ve Dandini Dandini Dastana kaynaklarda geleneksel; Kırmızı Balık, Küçük Kurbağa, Mini Mini Bir Kuş için sahiplik kaynağı bulunamadı. Not: ezgi anonim olsa bile kayıt ve düzenleme kendi üretimi olmalı; yayından önce doğrulanmalı. Yalnız not, hukuki görüş değil.

### 5.4 Türkçe harf ve sayı

- Ebeveyn forumlarında Türkçe harf-rakam isteği 2013'ten beri var ("'A' dediğim harfe bilgisayar 'ey' deyince"); İngilizce alfabeli uygulamalar 3 yaşı karıştırıyor.
- MEB 2026 baskısı 36–60 ayda yazma öncesi çıktı istemiyor (TAEOB.5 yalnız 60–72 ay); sayma 36–48 ayda 1–5. Türkçe harf izleme 3 yaş için programla uyumlu değil, 5 yaş için uyumlu; sayıyla boyama 1–5 ile sınırlı tutulursa 3 yaşla uyumlu.
- Eğitimci yanıtı (DonanımHaber 2013): 3 yaş için harf oyunu değil basit boyama ve puzzle.

---

## 6. Android beklentileri

### 6.1 Türkiye'de yaygın tabletler

Kaynak: akakçe popülerlik sıralaması, epey ürün sayfaları, MediaMarkt ve N11 "çocuk tablet" aramaları (8 Kasım 2026). Trendyol, Hepsiburada, Vatan ve cimri listeleri açılamadı; satış adedi yok, listeleme ve ilgi sıralaması.

| Küme | Modeller | Ekran | RAM | Android | Fiyat bandı |
|---|---|---|---|---|---|
| Ucuz "çocuk tableti" | Hometech Alfa 7LM, Everest Everpad DC-M700, Torima T16 | 7" 1024×600 | 2–4 GB | 10 Go (Torima 13) | 2.844–4.714 ₺ |
| 8 inç giriş | Hometech Alfa 8TX, Casper VIA S48, Lenovo Tab M8 HD | 8" 1280×800 | 2–3 GB | 12 | 4.000–4.900 ₺ |
| Ana akım 8,7" | Samsung Galaxy Tab A11 / A9, Lenovo Tab One, Redmi Pad SE 8.7 | 8,7" 1340×800 | 4–8 GB | 14–16 | 5.400–7.999 ₺ |
| 9–10 inç | Lenovo Tab M9 (9" 1340×800), TCL Tab 10L Gen 4 (10,1" 1280×800), General Mobile E-Tab 20 (10,1" 1920×1200, Android 10) | 9–10,1" | 3–4 GB | 10–15 | 6.174–9.391 ₺ |
| 11 inç | Galaxy Tab A11+ / A9+, Redmi Pad SE, Lenovo Tab M11, Honor Pad X9a | 11–11,5" 1920×1200 ve üstü | 4–8 GB | 13–16 | 8.428–13.919 ₺ |

StatCounter Türkiye tablet (Ekim 2026): satıcı payı Samsung %51,2, Apple %25,5, Lenovo %6,8, Huawei %4,5, Xiaomi %3,6, Honor %2,9. Android sürümü: 16 %37,8; 14 %14,4; 13 %9,4; 12 %9,3; 15 %6,7; 11 %6,6; listelenmeyen kalan (10 ve altı dahil) %15,9. Ekran çözünürlüğü (CSS px): 1280×800 %15,3; 601×1007 %7,7 (8,7" sınıfı dikey); 800×1280 %7,6; 768×1024 %3,9 (iPad); 1007×601 %3,4 (8,7" yatay). Samsung 8,7" sınıfında dikey kullanım yatayın iki katından fazla.

### 6.2 Rakipte tablet, performans ve boyut vurgusu

- 37 vitrin uygulamasının 6'sı "tablet" kelimesini kullanıyor; açık tablet vaadi yalnız Orange ("Hem Tabletlerde hem de Telefonlarda mükemmel çalışır") ve Bebi'de (tablet kavramasına karşı "Dokunmatik Koruma"). Hiçbiri "yatay ve dikey", "düşük cihazlarda akıcı" ya da "küçük boyut" yazmıyor.
- Kurulum boyutları (APKPure sayfalarından okundu, indirilmedi): TRT Piksel 51 MB, Kakadoo 53 MB, TRT Anaokulum 76 MB, Orange 105 MB, RV 105 MB, BabyBus 105 MB; istisnalar IDZ 211 MB ve Bebi 929 MB (XAPK). Rakip bandı 51–105 MB.
- Türkçe yorumlarda performans şikâyeti "kasma, donma, geç açılma" diliyle; pil ve ısınma 0. Somut sinyaller: Türkçe yerelde donma (Bebi, 2025), çoklu dokunma ve avuç sorunu (RV, 2026), kayıt kaybı (IDZ, 2023), eski cihazda açılmama (TRT Anaokulum iOS, 2020).

### 6.3 Play zorunlulukları ve politikalar (2026; tarihler kaynağından doğrulandı)

- Hedef API: 31 Ağustos 2026'dan itibaren yeni uygulama ve güncellemeler Android 16 (API 36) hedeflemeli; uzatma başvurusu 1 Kasım 2026'da kapandı. Cobi'nin ilk Play yüklemesi API 36 ile yapılmalı.
- 16 KB sayfa boyutu: Android 15+ hedefleyen tüm uygulamalar 64 bit cihazlarda 16 KB sayfa desteği vermeli; 1 Şubat 2027'den itibaren desteklemeyen güncellemeler yayımlanamaz. Flutter motoru ve her eklentinin .so dosyası ayrı doğrulanmalı (`zipalign -c -P 16 -v 4`, APK Analyzer); AGP 8.5.1+ ve NDK r28+ varsayılan hizalı.
- Android 16 davranışı: API 36 hedefleyen uygulamalarda 600 dp ve üstü ekranlarda yön kilidi, en-boy oranı kısıtı ve `resizeableActivity` yok sayılır; uygulama pencereyi doldurur. Cobi tablette hem dikey hem yatay çalışmalı, döndürmede tuvali korumalı.
- Uyarlanabilir uygulama kalitesi: "Large screen app quality" rehberi 21 Ocak 2026'da arşivlendi, yerini "Adaptive app quality" kademeleri aldı (Tier 3 hazır: tam ekran, durum korunur, çoklu pencere; Tier 2 optimize: tüm boyutlar için düzen). Mağaza görselleri: 7" ve 10" tablet için en az 4'er ekran görüntüsü. Tablet puanı Play'de ayrı görünür.
- Families politikası: hedef kitle "Ages 5 & Under"; AD_ID izni istenmemeli; kimlik toplanmamalı; konum izni yok; reklam gösterilecekse yalnız Families onaylı SDK; paylaşım ve yetişkin özelliklerinden önce "adult action" (ebeveyn kapısı). Teacher Approved: uygun uygulama otomatik incelemeye girer, Türkçe desteklenir, "yetişkinle birlikte kullanım" ve "sınıf içi kullanım" program dışı.

### 6.4 Erişilebilirlik

- Google TTS Türkçe sesi var ("Turkish (Turkey)"); TalkBack cihazın TTS motorunu kullanır. 3–5 yaş çocuğun TalkBack'i kendi kullanacağına dair veri yok; gerçekçi beklenti ebeveynin açık bıraktığı TalkBack'te uygulamanın bozulmaması ve her hedefin etiketli olması.
- Android 14+ doğrusal olmayan yazı ölçeği %200'e kadar; Flutter 3.16+ `TextScaler`. Switch Access tarama için odaklanabilir ve etiketli semantik düğüm ister; özel çizilen tuval ve düğmeler `Semantics(label, button)` sarmalayıcı olmadan ağaçta görünmez. Flutter test rehberi: `androidTapTargetGuideline` 48×48 px, `labeledTapTargetGuideline`, `textContrastGuideline`.

### 6.5 Çocuk kipleri

- Google Kids Space: Family Link ile denetimli hesap; Play sekmesi cihazdaki uygulamaları ve "teacher-approved" ücretsiz önerileri gösterir; ebeveyn herhangi bir uygulamayı ekleyebilir; desteklenen tablet listesinde Samsung ve Türkiye'nin ucuz markaları yok (Lenovo Tab M10/P11, Pixel Tablet, Nokia T20). Türkiye'de kullanılabilirlik dolaylı (Play TR'de "Yükle", Family Link Türkçe sayfası). Yorum: "Uygulamadan çıkılmıyor … restart yapmak gerekiyor" (Play TR, 19.07.2026).
- Samsung Kids: Android 9+ Galaxy cihazlarda; çıkış PIN'li; ebeveyn yüklü herhangi bir uygulamayı ekleyebilir; %51 Samsung payıyla Türkiye'de en olası ev sahibi. Uygulama ağ, dış bağlantı ve mağaza yönlendirmesi olmadan tam çalışmalı.
- Ekran sabitleme: sistem geri ve ana ekran jestleri uygulamayı terk ettirmez; her ekranda uygulama içi geri yolu şart.
- Family Link: ücretsiz uygulama indirme ve IAP için onay akışı; uygulama başına günlük süre sınırı; PEGI 3 ve "Ages 5 & Under" her içerik tavanının içinde kalır.

### 6.6 Cobi için teknik öneri (özet)

1. targetSdk 36; 16 KB hizalı derleme, eklenti .so dosyaları tek tek doğrulanarak (1 Şubat 2027 kapısı).
2. minSdk kararı: Android 10 Go ve 2 GB RAM cihazlar (Hometech, Everest) kapsanacaksa minSdk ≤ 29 ve gerçek cihaz testi; Impeller API 29 altında eski işleyiciye düşer.
3. Yön kilidi yok; dikey (601×1007 dp sınıfı en yaygın Samsung tablet yönü) ve yatay düzen; döndürmede tuval, renk ve geri alma korunur; bölünmüş ekranda çizim kaybolmaz.
4. Düzen test seti: 7" 1024×600, 8" 1280×800, 8,7" 1340×800, 10,1" 1280×800, 11" 1920×1200; Google resmî 1024×640 dp ve 1280×800 dp.
5. Kurulum boyutu rakip bandının (51–105 MB) altında; 323 sayfa için vektör ya da sıkıştırılmış varlık.
6. Avuç reddi ve çoklu dokunma: kenar bölgesinde ikinci teması yok say (Bebi "Dokunmatik Koruma", RV yorumu).
7. tr-TR yerelinde tam regresyon (Bebi'de Türkçe dilde donma raporu).
8. Hiç ağ çağrısı yok; AD_ID manifestte yok; Veri güvenliği formunda veri toplanmıyor beyanı; "Çevrimdışı" etiketi için gereken koşullar.
9. Her özel düğmeye Semantics etiketi; 48×48 px hedef; %200 yazı ölçeği; kontrast 4,5:1.
10. Her ekranda geri yolu; kapatılamayan tam ekran diyalog yok (Kids Space ve ekran sabitleme).
11. Kayıt güvenliği: sayfa çıkışında ve `onPause`'da kalıcı kayıt (IDZ "kayıt olmuyor yine beyaza dönüyor").

---

## 7. Cobi için anlamı

### 7.1 Türkiye'de fark yaratacak özellikler

| Özellik | Neden fark yaratır | Kanıt |
|---|---|---|
| Türkçe sesli nesne ve renk adları (isteğe bağlı İngilizce ikinci dil) | 1 Mn+ kurulumlu hiçbir boyama uygulamasında yok; ebeveynin en net özellik isteği; MEB kavram listesiyle (renk) örtüşür; Manzara prototipi zaten bu yönde | bölüm 1.5, 3 (11 + 10 kaynak), 5.2 |
| Türkiye takvimine bağlı sezon setleri: 23 Nisan, Ramazan ve Kurban Bayramı, Anneler Günü, 29 Ekim–10 Kasım–24 Kasım, Yerli Malı, yılbaşı-kış | vitrinde sezon içeriği var ama yalnız Batı takvimi (8/37); öğretmen üretimi en yüksek günler; bayram tatilleri ev kullanımını artırır | bölüm 1.2, 4.4 |
| Yerel nesne ve kamu malı kahraman sayfaları (simit, çay bardağı, nazar, lale, leylek, Kapadokya balonu, İstanbul kedisi; Keloğlan, Nasreddin Hoca, Karagöz-Hacivat kendi çizimle) | 37 uygulamada 0; TRT dışında yerel içerik yok; lisans gerekmez | bölüm 5.1, 5.3 |
| Çocuğun çıkamayacağı kilit: ebeveyn kapısı, avuç ve çoklu dokunma reddi, dış bağlantısız akış; Samsung Kids ve ekran sabitleme ile uyum | "çocuk çıkıyor, ayarları bozuyor" 6 kaynak; "ekran kitleme" isteği; vitrinde yalnız Bebi anlatıyor; Samsung %51 | bölüm 3, 6.5 |
| Düşük donanımlı tablette akıcılık ve her iki yönde düzen (1024×600, 2 GB RAM, Android 10 Go'dan 11" 1920×1200'e) | rakiplerin hiçbiri düşük cihaz ya da yön demiyor; donma-kasma 6 kaynak; Android 16 yön kilidini kaldırıyor; tablet puanı ayrı görünüyor | bölüm 6.1–6.3 |

Destekleyici (fark yaratır ama tek başına değil): 3 yaş için büyük dokunma hedefi ve Minik modu (yaşa uygunsuzluk 12 kaynak; Bebi "küçük çocuklar için boyama modu" ve Bimi Boo "sihirli boyama" kısmen karşılıyor); 1–5 sayıyla boyama ve daire-üçgen-kare şekil boyama (MAB.1.a, MAB.9'a bağlanır; öğretmen metni için dil sağlar); kapatılabilir konfeti ve ses (Fat Tuna örneği, TRT yorumlarında ses eksikliği şikâyeti).

### 7.2 Türkiye'de fark yaratmayacak özellikler

| Özellik | Neden fark yaratmaz | Yine de |
|---|---|---|
| Reklamsız, ücretsiz başlangıç, çevrimdışı, hesapsız | TRT'nin 42 uygulaması ve RV AppStudios (100 Mn+) aynı vaadi veriyor; "Çevrimdışı" etiketi 33/37'de var | reklam en çok şikâyet edilen tema (16 kaynak); ilk cümlede yazılmalı, ayırt edici diye sunulmamalı |
| Teacher Approved rozeti | 29/37'de var | yokluğu eksik; "yetişkinle birlikte" ve "sınıf içi" ifadelerinden kaçın |
| Yazdırma | ebeveyn yorumlarında 0 istek; öğretmen kâğıdı ücretsiz forumdan alıyor; vitrinde 0/37 | Anneler Günü ve bayram kartı için "PDF paylaş" düşük maliyetli deneme |
| Çıkartma, fırça çeşidi, parıltı | 15/37, 19/37, 12/37; standart | mevcut 6 fırça ve 16 çıkartma yeterli; parıltı fırçası ucuz ek |
| Sayıyla piksel boyama | 5 yaş altı için şikâyet ("ince seçim", "göz yoran"); yetişkin pazarının mekaniği | 1–5 ile sınırlı "say ve boya" ayrı şey |
| Yerli lisanslı karakter | Kral Şakir Boyama Kitabı 10 B+ ve 3,6 puan; Niloya, Pırıl, Rafadan Tayfa boyama talebi forumlarda yok | TRT karakteri talebi yalnız TRT'nin kendi uygulamasında |
| Yabancı lisanslı karakter (Disney, My Little Pony) | ilk 30'da var ama Cobi'nin yolu değil | — |
| "Tablet için optimize" ifadesi | rakipte 6/37, iddia olarak zayıf | gerçek tablet düzeni (bölüm 6.6) fark yaratır, ifade değil |

### 7.3 Mağaza metni için dil (Türkiye)

- İlk cümlede: 3–5 yaş, Türkçe sesli, reklamsız, internetsiz, hesapsız. Türk ebeveynin üçlüsü "güvenli, reklamsız ve öğretici".
- Eğitici vaat MEB diliyle: "küçük kas ve el-göz koordinasyonu", "renk ve şekil tanıma", "1'den 5'e sayma". "Sanat eğitimi" deme (program boyamayı sanat saymıyor).
- "Yetişkinle birlikte kullanım" ya da "sınıf için" deme (TA program dışı nedeni); "büyükanneyle birlikte boyanır" gibi kullanım öyküsü yorumlara bırakılabilir.
- Çeviri kalitesine dikkat: rakiplerde "Başvurumuzdan memnun musunuz?" ve Türkmence "Yenilikler" gibi hatalar var; özgün Türkçe metin başlı başına fark.

---

## 8. Doğrulanamayanlar

1. Ekran görüntüsü alt yazıları: görseller indirilmedi; vitrin analizi yalnız açıklama ve "Yenilikler" metnine dayanıyor. Metinde geçmeyen bir özellik uygulamada olabilir.
2. Play yorumları: web sayfası uygulama başına en çok 20 (bazı ajanlarda 3) yorum gösteriyor; tam yorum dökümü alınamadı. Yorum yazarlarının bir bölümü çocuk; ebeveyn-çocuk ayrımı metinden.
3. Reddit (r/Turkey, r/anneler vb.): 403, giriş duvarı ve ayna hataları; hiçbir sayfa açılamadı. Instagram ve TikTok anne ve öğretmen hesapları: içerik alınamadı.
4. YouTube: ebeveynin kendi sesiyle boyama uygulaması değerlendirdiği video bulunamadı; "okul öncesi akıllı tahta boyama" aramaları veri döndürmedi (araç sınırı olabilir).
5. Google Trends "boyama sayfası" ile "boyama oyunu" karşılaştırması: HTTP 429 (üç deneme).
6. Şubat 2024 Okul Öncesi Eğitim Programı PDF'i (12 MB) açılamadı; kazanım metinleri ikincil kaynaktan, kazanım numaraları yok. 2026 baskısının TTKB karar tarihi belgede yok. Bağımsız anaokullarının 2026-27'de hangi programı uyguladığı doğrulanmadı.
7. Anaokulu sınıflarında tablet ve etkileşimli tahta oranı: ulusal veri yok; FATİH kılavuzundaki "Anasınıfları hariç" ibaresi tek resmî dayanak (ilçe MEM kopyası, 2022). Özel anaokulları için veri yok.
8. okuloncesi.net konu sayıları toplam arşiv (2011–2016 ağırlıklı); yıllık üretim değil. 2027-28 MEB takvimi açıklanmadı; Eylül 2027 tarihleri tahmin.
9. Niloya resmî uygulamasında boyama modülü: yalnız niloya.com haber metnine dayanıyor; Play açıklamasında yok. 3. parti Rafadan Tayfa, Tavşan Momo, Niloya ve Kukuli (Emeli apps) uygulamalarının lisanslı olup olmadığı bilinmiyor. kralsakir.com, kukuli.com ve Pırıl resmî sitesi açılamadı.
10. Geliştirici ülkesi Play'de yazmıyor: HunGames, Game Tunes, Midwin, VFX Tricks, VIPGO TECH, TEA Tech "yerli" sayımı ad ve metne dayanıyor.
11. Kırmızı Balık, Küçük Kurbağa, Mini Mini Bir Kuş şarkılarının sahiplik ve anonimlik durumu bulunamadı; Ali Babanın Çiftliği'nin Old MacDonald uyarlaması olduğu iddiası doğrulanmadı. TRT Keloğlan karakter tasarımcısı bulunamadı.
12. Kitapyurdu "boyama kitabı 3 yaş" çok satanlar (403); Tudem ve Erdem Çocuk katalogları okunamadı. D&R sıralamasının ölçütü sayfada yazmıyor.
13. Trendyol, Hepsiburada, Vatan, cimri "çocuk tablet" ve en çok satan listeleri açılamadı; tablet kümesi listeleme ve ilgi sıralamasına dayanıyor. Lenovo Tab Kids ve Torima T16 teknik özellikleri eksik. Galaxy Tab A9 Kids Edition Türkiye satışı doğrulanmadı.
14. Google Kids Space ve Family Link için resmî ülke listesi yok; Türkiye kullanılabilirliği dolaylı. Samsung Kids Türkçe "uygulama ekle" sayfası 404.
15. Pil tüketimi ve ısınma şikâyeti hiçbir kaynakta çıkmadı; bu "sorun yok" anlamına gelmez.
16. Play "Uygulama içi satın alma" etiketi ayrıştırmada sayfanın başka bölümleriyle karışıyor; IAP verisi için `b-turkiye-android.md` tablosu esas alınmalı. "Reklam içerir" ve "Çevrimdışı" etiketleri tutarlı çıktı.
17. "Boyama ve öğren" için 2020–2024 yorumları reklam ve internet zorunluluğu, 2026 yorumları tersini söylüyor; Play sayfası 8 Kasım 2026'da "Reklam içerir" ve "Çevrimdışı" etiketlerinin ikisini de taşıyor.
18. TRT Piksel Boyama açıklaması "6 yaş ve üzeri" derken rozet "5 yaşa kadar" diyor; hangisinin geçerli olduğu bilinmiyor.
19. Flutter'ın 16 KB desteğine dair resmî sürüm notu bulunamadı; GitHub konuları (flutter/flutter#150168, #177147) kullanıldı.

---

## 9. Kaynaklar (erişim 8 Kasım 2026)

### Google Play Türkiye
- Aramalar: `https://play.google.com/store/search?q=<terim>&c=apps&hl=tr&gl=TR` — terimler: çocuk boyama, boyama oyunları, boyama kitabı çocuk, okul öncesi boyama; ayrıca TRT Çocuk, TRT Çocuk boyama, Niloya, Niloya boyama, Pırıl boyama, Kukuli, Rafadan Tayfa boyama, Pepee, Kral Şakir boyama, Harika Kanatlar, Keloğlan, Nasreddin Hoca, Türkçe boyama, boyama Türkçe sesli, sesli boyama, Türkçe İngilizce kelime öğrenme çocuk boyama, Atatürk boyama, 23 Nisan boyama, Türk bayrağı boyama (70 arama).
- Ayrıntı sayfaları: `https://play.google.com/store/apps/details?id=<paket>&hl=tr&gl=TR` — bölüm 1.3, 1.4 ve 2'deki tüm paketler; başlıcaları: com.orange.coloring.learn.kids, com.iz.coloring.games.kids.drawing.book.color.by.number, com.rvappstudios.kids.coloring.book.color.painting, com.bebi.family.baby.coloring, com.sinyee.babybus.paintingIII, com.joongly.coloring.kids, minipixel.easy.coloring.pages.draw.kids.painting, com.budgestudios.googleplay.BabyColoringBook, com.binibambini.acad.drawing, com.pages.kids.toddlers.painting, com.GameChangers.Coloringforkids, com.sunny.coloring.book.kids.paint, com.orange.gamesforkids.coloring.princess, com.bimiboo.kids.drawing, com.iz.coloring.games.kids.drawing.color.book.painting.learning.baby.toddlers, com.toddler.coloring, com.storytoys.disney.pixar.coloring.princess.googleplay, com.fattuna.superkidscoloring, com.hungames.paint, com.minimuffin.coloringstories, com.rvappstudios.toddler.preschool.kids.learning.games, com.yamo.paint, com.basi.kidscoloring, com.rvappstudios.shapes.colors.toddler, com.binibambini.drawingforgirls, com.meemu.coloring, com.midwin.kids.drawing.book.toddlers.coloring.games.preschool.painting, com.tt.coloring.drawing, com.YovoGames.paintinganimals, com.sinyee.babybus.princess_coloring_fantasy_magic_girls_games, com.kidsplaylearninggames.coloring.book.girls, com.kplg.colorbook, coloring.book.apps.kids, com.editale.kidsdraw, happy.pixel.coloring.art.color.games, minipixel.kids.color.games.paint.coloring.drawing.painting.book.preschool, com.rvappstudios.kids.drawing.games.coloring.book.paint, com.bimiboo.coloring, com.trtcocuk.pikselboyama, com.trtcocuk.anaokulum, com.trtcocuk.gameworldapp, com.trtcocuk.videoapp, com.Sentries.Niloya, com.piril.boyaar, com.bretzelgames.kralsakir.boyamakitabi, com.edujoy.superwings, com.dusyeri.uppy, com.hayri.game, com.vipgotech.minikfirca, com.dodedigital.boyama, com.penki.color.app, com.gamester.sevimliDostlar, com.tolga.minikellerboyama, com.google.android.apps.kids.home, com.google.android.apps.kids.familylink.
- APKPure boyut sayfaları (yalnız okundu): https://apkpure.com/tr/p/com.orange.coloring.learn.kids ; https://apkpure.com/tr/p/com.rvappstudios.kids.coloring.book.color.painting ; https://apkpure.com/tr/p/com.bebi.family.baby.coloring ; https://apkpure.com/tr/p/com.iz.coloring.games.kids.drawing.book.color.by.number ; https://apkpure.com/tr/little-panda-s-kids-coloring/com.sinyee.babybus.paintingIII ; https://apkpure.com/tr/easy-coloring-book-for-kids/com.joongly.coloring.kids ; https://apkpure.com/tr/trt-piksel-boyama/com.trtcocuk.pikselboyama ; https://apkpure.com/tr/trt-%C3%A7ocuk-anaokulum/com.trtcocuk.anaokulum

### App Store Türkiye
- https://apps.apple.com/tr/app/id1480696573 (RV Boyama Oyunları) ; https://apps.apple.com/tr/app/id451719402 (KidloLand) ; https://apps.apple.com/tr/app/id1423587600 (TRT Piksel Boyama) ; https://apps.apple.com/tr/app/id1545563182 (Bebi) ; https://apps.apple.com/tr/app/id942129040 (Boyama ve öğren)
- RSS: https://itunes.apple.com/rss/customerreviews/page=1/id=1129192831/sortby=mostrecent/json?cc=tr (Bimi Boo Boyama) ; https://itunes.apple.com/rss/customerreviews/page=2/id=1499329165/sortby=mostrecent/json?cc=tr (TRT Çocuk Anaokulum) ; https://itunes.apple.com/rss/customerreviews/page=1/id=6756377323/sortby=mostrecent/json?cc=tr (Mini Painter) ; https://itunes.apple.com/tr/rss/customerreviews/page=2/id=1001555097/sortBy=mostRecent/json (Bimi Boo Çizim)

### Ebeveyn kaynakları
- Ekşi Sözlük: https://eksisozluk.com/cocuklar-icin-uygulamalar--7243700 ; https://eksisozluk.com/khan-academy-kids--5956318 ; https://eksisozluk.com/lingokids--5879074 ; https://eksisozluk.com/youtube-kids--4701833?p=3 ; https://eksisozluk.com/3-yasa-kadar-tv-tablet-ve-telefonu-engelleyelim--5187082 ; https://eksisozluk.com/bebeklere-tablet-ve-telefon-kullandirtmak--5444346 ; https://eksisozluk.com/mathtale--8117867 ; https://eksisozluk.com/google-play-uzerinden-yapilan-dolandiricilik--5955439 ; https://eksisozluk.com/prenses-aylin-youtube-kanali-rezaleti--7155075
- Kadınlar Kulübü: https://www.kadinlarkulubu.com/konu/3-yas-cocuk-icin-mobil-egitici-oyun-oneriniz-var-mi.1507476/ ; https://www.kadinlarkulubu.com/konu/6yas-ekran-suresi.1421170/ ; https://www.kadinlarkulubu.com/konu/tablet-telefon-bagimliligi.1340677/ ; https://www.kadinlarkulubu.com/konu/cocuk-icin-tablet-onerisi.1088177/
- DonanımHaber: https://forum.donanimhaber.com/cocuk-icin-uygulama-oyun-tavsiyesi-3-yas--76003453 ; https://forum.donanimhaber.com/cocuklar-icin-mobil-oyun-onerileri--114380071 ; https://forum.donanimhaber.com/3-yas-icin-tablet-onerisi--68684869 ; https://forum.donanimhaber.com/5-6-yas-cocugum-icin-zeka-gelistirici-oyun-tavsiye--98628061 ; https://forum.donanimhaber.com/basima-gelecek-her-turlu-islemden-google-sorumludur-sacmaligi-cocuklariniza-tablet-almayin--116739238
- YouTube: https://www.youtube.com/watch?v=AtHqEwXJUT0 ; https://www.youtube.com/watch?v=gIFMlG_LVDg ; https://www.youtube.com/watch?v=x-dljVaSjJc ; https://www.youtube.com/watch?v=7Tb2lDFnU5Q ; https://www.youtube.com/watch?v=UfIQ9iKN6nw ; https://www.youtube.com/watch?v=YmHAu-LkggU ; https://www.youtube.com/watch?v=nHPcfYFs6jc ; https://www.youtube.com/watch?v=P1SIJJXydD8 ; https://www.youtube.com/watch?v=Umq5TKI6RT8 ; https://www.youtube.com/watch?v=i-9Se5VsJpE ; https://www.youtube.com/watch?v=vLEKIO85gmY ; https://www.youtube.com/watch?v=_2P345J_jN8
- Blog ve derleme: https://www.anneysen.com/1-6-yas-cocuk/makale/cocuk-gelisimi-cocuklar-icin-faydali-10-mobil-uygulama_10763 ; https://www.bebek.com/annelerin-indirmesi-gereken-11-mobil-uygulama/ ; https://www.webtekno.com/ekran-suresini-verimli-h-le-getirin-cocuklar-icin-en-iyi-egitici-tablet-uygulamalari-h206524.html ; https://www.hurriyet.com.tr/aile/okul-oncesi-egitim-icin-10-faydali-aplikasyon-420216
- Açılamayan: https://www.reddit.com/r/Turkey/search.json?q=çocuk+tablet+uygulama&restrict_sr=1 (403) ; https://old.reddit.com/r/Turkey/search?q=çocuk+uygulama+tablet&restrict_sr=on (giriş duvarı)

### MEB, Diyanet, öğretmen kaynakları
- Türkiye Yüzyılı Maarif Modeli Okul Öncesi Eğitim Programı (2024): https://tegm.meb.gov.tr/meb_iys_dosyalar/2024_09/20104013_2024programokuloncesionayli.pdf
- Aynı programın 2026 baskısı: https://tegm.meb.gov.tr/dosya/okuloncesi/okuloncesikilavuzkitaplar/tymmprogramkilavuz.pdf
- Okul Öncesi Eğitim Programı Şubat 2024 (açılamadı): https://tegm.meb.gov.tr/dosya/okuloncesi/guncellenenokuloncesiegitimprogrami.pdf
- Serdaroğlu & Bekir (2024): https://dergipark.org.tr/en/download/article-file/3954215 ; Kalaycı & Bayrakcı (2025): https://dergipark.org.tr/tr/download/article-file/4292149
- tymm.meb.gov.tr plan örnekleri: https://tymm.meb.gov.tr/okul-oncesi/unite/443 ; /446 ; /482 ; /483
- MEB Sosyal Etkinlikler Yönetmeliği: https://www.mevzuat.gov.tr/File/GeneratePdf?mevzuatNo=23639&mevzuatTur=KurumVeKurulusYonetmeligi&mevzuatTertip=5 ; EK-8 çizelgesi (Aksu İlçe MEM): https://aksu07.meb.gov.tr/meb_iys_dosyalar/2024_05/09101001_belirli_gunler_haftalar.pdf
- FATİH etkileşimli tahta kılavuzu (Siverek İlçe MEM): https://siverek.meb.gov.tr/meb_iys_dosyalar/2022_05/18153439_KYlavuz.pdf
- MEB 2026-2027 takvimi: https://www.meb.gov.tr/2026-2027-egitim-ogretim-yili-takvimi-aciklandi//haber/41057/tr
- Diyanet 2027 Dini Günler: https://vakithesaplama.diyanet.gov.tr/icerik.php?icerik=154
- Sınıf teknolojisi çalışmaları: https://dergipark.org.tr/en/download/article-file/1037930 ; https://search.trdizin.gov.tr/yayin/detay/406533 ; https://acikerisim.balikesir.edu.tr/items/53061e65-eb22-4fff-bb13-564a234d2f3e ; https://dergipark.org.tr/tr/download/article-file/5126859 ; https://acikerisim.comu.edu.tr/xmlui/handle/20.500.12428/2136 ; https://core.ac.uk/works/77707508 ; https://search.trdizin.gov.tr/yayin/detay/300983 ; https://dergipark.org.tr/en/download/article-file/1426829
- okuloncesi.net: https://www.okuloncesi.net/forum/ ; Boyama Sayfaları https://www.okuloncesi.net/forum/kategori/boyama-sayfalari.247/ ; Anneler Günü https://www.okuloncesi.net/forum/kategori/anneler-guenue-etkinlikleri.160/ ; Öğretmenler Günü https://www.okuloncesi.net/forum/kategori/ogretmenler-gunu-etkinlikleri.125/ ; Cumhuriyet Bayramı https://www.okuloncesi.net/forum/kategori/cumhuriyet-bayrami-etkinlikleri.117/ ; Hayvanları Koruma https://www.okuloncesi.net/forum/kategori/hayvanlari-koruma-guenue.115/ ; Ramazan https://www.okuloncesi.net/forum/kategori/ramazan-seker-bayrami-etkinlikleri.556/ ; Kurban https://www.okuloncesi.net/forum/kategori/kurban-bayrami-etkinlikleri.557/ ; 10 Kasım Atatürk boyama https://okuloncesi.net/forum/konu/10-kas-m-icin-ataturk-boyama-sayfas.543/ ; Anıtkabir https://www.okuloncesi.net/forum/konu/anitkabir-boyama-sayfasi.3523/ ; 23 Nisan pankartlı çocuklar https://www.okuloncesi.net/forum/konu/23-nisan-kutlu-olsun-pankartli-cocuklar-boyama.8172/ ; Canım Annem https://okuloncesi.net/forum/konu/can-m-annem-boyama-sayfas.9039/ ; Sonbahar yaprakları https://www.okuloncesi.net/forum/konu/sonbahar-yapraklari-boyama-sayfalari-yaprak-kalibi.70/
- Sorubak: https://www.sorubak.com/23nisandokumanlari.html?k1=8 ; Pinterest: https://tr.pinterest.com/ideas/okul-%C3%B6ncesi-boyama/917930818048/ ; Canva: https://www.canva.com/tr_tr/boyama-sayfasi/sablonlar/ ; tutkit: https://www.tutkit.com/tr/tasarim-sablonlari/boyama-sayfalari-yazdirilabilir-boyama-sayfalari
- Google Trends (429): https://trends.google.com/trends/explore?geo=TR&q=boyama%20sayfas%C4%B1,boyama%20oyunu

### Yerli markalar, telif, kitap pazarı
- https://www.trtcocuk.net.tr/ ; https://www.trtcocuk.net.tr/oyun ; https://www.trtcocuk.net.tr/boyama (404) ; https://www.niloya.com/ ; https://www.niloya.com/activity?id=1 ; https://www.rafadantayfa.com/ ; http://pepee.com.tr/ (→ https://www.uppyforkids.com/) ; https://www.dusyeri.com/tr ; https://www.kralsakir.com/ (erişilemedi) ; https://kukuli.com/ (500)
- FSEK 5846: https://www.mevzuat.gov.tr/MevzuatMetin/1.3.5846.pdf ; UNESCO: https://ich.unesco.org/en/RL/karagoz-00180 ; https://ich.unesco.org/en/lists?text=nasreddin ; https://ich.unesco.org/en/lists?text=korkut ; https://tr.wikipedia.org/wiki/Keloğlan_Masalları ; https://tr.wikipedia.org/wiki/Nasreddin_Hoca ; https://tr.wikipedia.org/wiki/Dandini_Dandini_Dastana ; https://www.liederkiste.com/downloads/ali-babanin.pdf
- D&R: https://www.dr.com.tr/kategori/kitap/cocuk-ve-genclik/okul-oncesi-6-ay-5-yas/boyama-kitaplari/grupno=00889 ; Timaş: https://timas.com.tr/cocuk-boyama-kitaplari ; YKY Doğan Kardeş: https://www.yapikrediyayinlari.com.tr/kitap/dogan-kardes/etkinlik ; İş Kültür: https://www.iskultur.com.tr/is-cocuk ; Redhouse: https://www.redhouse.com.tr/arama?q=boyama ; Kitapyurdu (403): https://www.kitapyurdu.com/kategori/kitap-cocuk-kitaplari-okul-oncesi-boyama/8.html

### Android, tablet pazarı, Google ve Samsung belgeleri
- akakçe: https://www.akakce.com/tablet/android-tablet.html ; https://www.akakce.com/tablet/hometech.html ; https://www.akakce.com/tablet/everest.html
- epey: https://www.epey.com/tablet/samsung-galaxy-tab-a11.html ; https://www.epey.com/tablet/samsung-galaxy-tab-a11-plus.html ; https://www.epey.com/tablet/samsung-galaxy-tab-a9.html ; https://www.epey.com/tablet/samsung-galaxy-tab-a9-plus.html ; https://www.epey.com/tablet/lenovo-tab-m9.html ; https://www.epey.com/tablet/lenovo-tab-one-tb305fu.html ; https://www.epey.com/tablet/lenovo-tab-m11-tb330fu.html ; https://www.epey.com/tablet/redmi-pad-se.html ; https://www.epey.com/tablet/redmi-pad-se-8-7.html ; https://www.epey.com/tablet/honor-pad-x9a.html ; https://www.epey.com/tablet/tcl-tab-10l-gen-4.html ; https://www.epey.com/tablet/general-mobile-e-tab-20.html ; https://www.epey.com/tablet/hometech-alfa-8tx.html ; https://www.epey.com/tablet/hometech-alfa-7lm.html ; https://www.epey.com/tablet/everest-everpad-dc-m700.html ; https://www.epey.com/tablet/ekran-boyutu/7-0/ ; https://www.epey.com/tablet/ekran-boyutu/8-0/
- Mağazalar: https://www.mediamarkt.com.tr/tr/search.html?query=%C3%A7ocuk%20tablet ; https://www.n11.com/arama?q=%C3%A7ocuk+tableti ; https://www.teknosa.com/arama/?s=%C3%A7ocuk%20tableti ; https://www.turkcell.com.tr/pasaj/bilgisayar-tablet/tabletler
- StatCounter: https://gs.statcounter.com/android-version-market-share/tablet/turkey ; https://gs.statcounter.com/screen-resolution-stats/tablet/turkey ; https://gs.statcounter.com/vendor-market-share/tablet/turkey ; https://gs.statcounter.com/platform-market-share/desktop-mobile-tablet/turkey
- Google Play ve Android: https://support.google.com/googleplay/android-developer/answer/9893335 (Families) ; https://support.google.com/googleplay/android-developer/answer/10075896 (Teacher Approved) ; https://google.play/business/programs/teacherapproved/ ; https://developer.android.com/google/play/requirements/target-sdk ; https://support.google.com/googleplay/android-developer/answer/11926878 ; https://developer.android.com/guide/practices/page-sizes ; https://android-developers.googleblog.com/2025/05/prepare-play-apps-for-devices-with-16kb-page-size.html ; https://developer.android.com/about/versions/16/behavior-changes-16 ; https://developer.android.com/docs/quality-guidelines/adaptive-app-quality/tier-3 ; https://android-developers.googleblog.com/2022/03/helping-users-discover-quality-apps-on.html ; https://support.google.com/googleplay/android-developer/answer/9866151 ; https://github.com/flutter/flutter/issues/150168 ; https://github.com/flutter/flutter/issues/177147 ; https://docs.flutter.dev/perf/impeller
- Erişilebilirlik: https://support.google.com/accessibility/android/answer/11101402?hl=en ; https://support.google.com/accessibility/android/answer/6122836?hl=en ; https://developer.android.com/about/versions/14/features ; https://docs.flutter.dev/ui/accessibility ; https://docs.flutter.dev/ui/accessibility/accessibility-testing ; https://docs.flutter.dev/release/breaking-changes/android-14-nonlinear-text-scaling-migration
- Çocuk kipleri: https://support.google.com/kidsspace/answer/10053691 ; https://support.google.com/kidsspace/answer/14104155 ; https://families.google/intl/tr_tr/familylink/ ; https://support.google.com/families/answer/7039872?hl=tr ; https://support.google.com/googleplay/answer/7103028?hl=tr ; https://support.google.com/android/answer/9455138?hl=tr ; https://www.samsung.com/us/support/answer/ANS00082342 ; https://www.samsung.com/ca/support/apps-services/what-is-samsung-kids ; https://www.samsung.com/tr/support/apps-services/how-to-use-samsung-kids/

### Ara dosyalar (bu oturumun scratchpad'i, kalıcı değil)
- `scratchpad/ozellik/play/parsed.json` (56 Play sayfasının ayrıştırılmış verisi), `scratchpad/ozellik/play/ids_1..4.txt` (arama sıraları), `scratchpad/ozellik/parts/q3-ebeveyn.md`, `q4-ogretmen-takvim.md`, `q2q5-yerli-turkce.md`, `q6-android.md` (alt araştırma raporları, tam alıntı ve kaynak listeleriyle).
