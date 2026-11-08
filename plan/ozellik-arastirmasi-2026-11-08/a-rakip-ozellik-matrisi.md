# Rakip özellik matrisi: 2–6 yaş boyama ve çizim uygulamaları

Tarih: 8 Kasım 2026. Kapsam: App Store listesindeki 21 rakip, Google Play Türkiye aramasında ilk 15'e giren 9 ek çocuk uygulaması, karşılaştırma satırı olarak Cobi Paint; Khan Academy Kids, Pok Pok ve Sago Mini World'ün boyama bölümleri birer satır. Fiyat bu raporun dışında.

## 0. Sonuç

Pazarın çekirdeği her uygulamada aynı: 21 rakibin 21'inde fırçayla boyama, 16'sında desen ya da doku dolgusu, 16'sında bayram ve sezon içeriği, 15'inde simli, neon ya da gökkuşağı fırça, 13'ünde dokunarak dolgu var. Bu beş özellik "standart"tır; Cobi'de bunlardan desen dolgusu ve sezon içeriği yok.

Vitrinde satılan ayırt ediciler dört kümede toplanıyor. Birincisi "boyanınca canlanma": 21 rakibin 9'unda var (Bini Games'in üç uygulaması, Bimi Boo'nun ikisi, JMH, Toya, Kid Doodle, KidloLand). İkincisi öğrenme katmanı: harf, sayı ve şekil 6 uygulamada, izleme (tracing) 7'sinde, sayıyla boyama 7'sinde. Üçüncüsü rehberli çizim: adım adım çizim 6, noktadan noktaya 4 uygulamada. Dördüncüsü içerik ritmi: 8 uygulama düzenli yeni içerik vadediyor, 3'ü lisanslı karakter kullanıyor (Disney, Crayon Club, Crayola).

2025–2026 sürüm notları yönü gösteriyor. Bimi Boo Kids Coloring 12 ayda sayıyla boyama, noktadan noktaya, piksel sanatı, kazı-sürpriz oyunu ve altı bayram teması ekledi. RV AppStudios 24 özellik sürümünde sezon temalarını iki üç haftada bir yeniledi, simetri modu ve "Color Rain" ekledi. Crayon Club her ay lisanslı paket çıkardı, paint-by-numbers ve Pixel Art Studio ekledi. Kid Doodle beş ayda anlatıcı, yapay zekâ ile sayfa üretimi, canlanan dört kitap, yazdırma, Apple Pencil basıncı ve Split View ekledi.

Türk yeni girişler (Kalemo, Minik Palet, BoyaBoo, Cobi) aynı çekirdekte toplanıyor: dokunarak dolgu, reklamsız, ebeveyn kapısı, tek seferlik satın alma (BoyaBoo abonelik). Aralarındaki fark ince: Kalemo yaş modu, ödül kutusu, süre sınırı ve ilerleme ekranı; Minik Palet sayıyla boyama, kardeş profilleri ve süre sınırı; BoyaBoo konuşan etiket, sayı ve harf paketleri ve renk karıştırıcı ekliyor.

Cobi'nin rakiplerin çoğunda olmayan özellikleri vitrinde nadiren vaat ediliyor: çizgide kalan kalem 4/21, zoom 2/21, fırça kalınlığı 1/21, ayna 3/21, yazdırma 1/21, Apple Pencil 2/21, otomatik tamamlama 0/21. Bu özellikler satın alma kararını sürüklediğine dair vitrin kanıtı yok; "sessiz kalite" özellikleri.

Cobi'de olmayıp rakiplerde yaygın olanlar: Android (15/21), desen ve doku dolgusu (16), sezon ve bayram içeriği (16), boyanınca canlanma (9), düzenli yeni içerik (8), sayıyla boyama (7), izleme (7), harf-sayı-şekil (6), adım adım çizim (6), piksel sanatı (5), arka plan müziği (5), noktadan noktaya (4), mini oyun (4), giydirme (4), süre sınırı (3), lisanslı karakter (3), çoklu profil (2), anlatıcı (2), yapay zekâ sayfa (1).

Para modeli: 21 rakibin 13'ü abonelik, 3'ü uygulama içi satın alma, 2'si tek seferlik (Kalemo, Minik Palet), 1'i tamamen ücretsiz (RV AppStudios), 2'si ücretsiz ama satın alma durumu belirsiz (Kakadoo, Toya). Abonelik gerekçesi her yerde aynı cümle: "her ay yeni içerik".

Google Play Türkiye: "çocuk boyama" aramasında ilk 15'in 14'ü çocuk uygulaması ve bunların 13'ünde Teacher Approved rozeti var (tek istisna BabyBus). "boyama oyunları" aramasında ilk 15'in 8'i yetişkin sayı ve piksel boyama uygulaması; çocuk rafı "çocuk boyama" anahtar kelimesinde.

Sahibin tezi ("bu setle kimse satın almaz") kısmen doğrulanıyor: Cobi'nin seti pazarın standart çekirdeğini karşılıyor, ama vitrinde satılan dört ayırt edici kümenin (canlanma, öğrenme katmanı, rehberli çizim, içerik ritmi) hiçbirini içermiyor. Manzara prototipi (sahne kurma + iki dilde sesli nesne adı) ise nadir bir kümeye giriyor: sahne kurma 3/21, iki dilde sesli ad 0/21.

## 1. Yöntem

- Zaman ve kanal: 8 Kasım 2026, 10:36–11:45 (İstanbul), `curl` ile, oturum açmadan, kişiselleştirilmemiş sayfalar. Hiçbir uygulama indirilmedi, satın alınmadı.
- Kaynak 1, App Store meta verisi: `itunes.apple.com/lookup?id=<ID>&country=us` ve `country=tr` → açıklama, güncel sürüm notu, ekran görüntüsü adresleri, dil ve cihaz listesi, puan ve oy sayısı.
- Kaynak 2, sürüm geçmişi: Apple'ın web uygulamasının çağırdığı `apps.apple.com/api/apps/v1/catalog/us/apps/<ID>?platform=web&additionalPlatforms=ipad&extend=versionHistory` ucu → son 25 sürüm. 21 uygulamada 2025–2026 tarihli 335 sürüm var; 179'u özellik metni içeriyor, kalanı "hata düzeltmesi" kalıbı. Görev metninde geçen `shoebox-media-api-cache-apps` etiketi sayfada artık yok; sayfadaki `serialized-server-data` JSON'u yalnız son sürümü taşıyor.
- Kaynak 3, vitrin: her uygulamanın ABD vitrinindeki ilk 3 iPhone ekran görüntüsü 1000 px genişlikte indirildi; alt yazılar ve görünen arayüz ögeleri üç yardımcı ajan tarafından yazıya döküldü. Play'e özgü 9 uygulama için Play galerisinin ilk 3 karesi.
- Kaynak 4, Google Play Türkiye: `play.google.com/store/search?q=…&c=apps&hl=tr&gl=TR` iki sorgu için; sıralama sayfadaki kart sırası. Sonra 30 paketin detay sayfası: açıklama, "Yenilikler", "Öğretmenler tarafından şu yaş için onaylandı" dizgesi (Teacher Approved rozeti ve yaş bandı), indirme bandı, puan, güncelleme tarihi.
- Kaynak 5: Khan Kids yardım makalesi, Pok Pok için App Store açıklaması ve MacStories incelemesi, Sago Mini World için App Store açıklaması ve yardım sayfası.
- Kodlama: ✓ en az bir kaynak açıkça söylüyor ya da ekran görüntüsü gösteriyor. ✗ incelenen hiçbir kaynakta geçmiyor; uygulamada gizli olabilir, ama vitrine konmamış bir özellik satın alma kararını da etkilemez varsayımıyla "yok" sayıldı. ? kaynak belirsiz ya da çelişkili, ya da açıklama özellik vermeyecek kadar kısa (BoyaBoo, Budge).
- Sınıflama eşiği: 21 App Store rakibinde ✓ oranı ≥60 % standart, 40–59 % yaygın, 20–39 % ayırt edici, <20 % nadir.
- Kapsam dışı: fiyat, kullanıcı yorumları, uygulama içi deneme.

## 2. Ana matris

Satırlar: 21 App Store rakibi, sonra Play'e özgü 9 uygulama, en altta Cobi. Semboller: ✓ var, ✗ kaynaklarda geçmiyor, ? doğrulanamadı. Kaynak kodları ve gerekçeler 3. bölümde.

### Boyama

| Uygulama | Dokunarak dolgu | Fırçayla boyama | Çizgide kalma | Sayıyla boyama | Desen/doku dolgu | Simli/neon/gökkuşağı | Fırça kalınlığı | Zoom | Piksel sanatı | Renk karıştırma |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Bimi Boo Drawing for Kids (1001555097) | ✓ | ✓ | ? | ✗ | ✓ | ✓ | ? | ? | ✗ | ✗ |
| Bimi Boo Baby Coloring Games (1129192831) | ✓ | ✓ | ? | ✗ | ✓ | ✓ | ? | ? | ✗ | ✗ |
| Bimi Boo Kids Coloring Games. Drawing (6444398254) | ✓ | ✓ | ? | ✓ | ✓ | ✓ | ? | ? | ✓ | ✗ |
| KidloLand Coloring Games 2-6 (451719402) | ? | ✓ | ? | ✓ | ✓ | ✓ | ? | ? | ✓ | ✗ |
| Todli (908698556) | ? | ✓ | ? | ✓ | ✓ | ? | ? | ? | ✗ | ✗ |
| Pinksy (1260895318) | ? | ✓ | ? | ✗ | ✓ | ✓ | ? | ? | ✗ | ✗ |
| Drawing Academy (1436397693) | ✓ | ✓ | ? | ✓ | ✓ | ✓ | ? | ? | ✗ | ✗ |
| RV AppStudios Coloring Games (1480696573) | ✓ | ✓ | ? | ✓ | ✓ | ✓ | ? | ? | ✓ | ✗ |
| Amaya Coloring Book: Kids Games (1475222650) | ? | ✓ | ? | ✗ | ✓ | ? | ? | ? | ✗ | ✓ |
| JMH Coloring Book Kids 2+ (1635552708) | ✓ | ✓ | ? | ✗ | ? | ? | ? | ? | ✗ | ✗ |
| Kakadoo Drawing and coloring (1511146155) | ✓ | ✓ | ✓ | ✗ | ✓ | ? | ? | ? | ✗ | ✗ |
| Crayola Create and Play (1431955703) | ? | ✓ | ? | ✗ | ? | ✓ | ? | ? | ✓ | ✗ |
| Sago Mini Crayon Club (6740246122) | ? | ✓ | ? | ✓ | ✓ | ✓ | ? | ? | ✓ | ✗ |
| Budge Kids Coloring Games (6701986471) | ? | ✓ | ? | ✗ | ? | ? | ? | ? | ✗ | ✗ |
| Kalemo (6819157588) [TR] | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ? | ✓ | ✗ | ✗ |
| Minik Palet (6818500948) [TR] | ✓ | ✓ | ? | ✓ | ✗ | ✓ | ? | ? | ✗ | ✗ |
| BoyaBoo (6824867811) [TR] | ✓ | ✓ | ? | ? | ✓ | ✓ | ? | ? | ✗ | ✓ |
| Kid Doodle / Çocuk Boyama Oyunları 2 6 Yaş (1500785406) [TR] | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ |
| Toya (1509960273) | ✓ | ✓ | ? | ✗ | ✓ | ✓ | ? | ? | ✗ | ✗ |
| 22LEARN Toddler Coloring Book (6511237267) | ? | ✓ | ? | ✗ | ? | ? | ? | ? | ✗ | ✗ |
| Disney Coloring World (1400326821) | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ? | ? | ✗ | ✗ |
| **Play'e özgü (TR arama ilk 15)** | | | | | | | | | | |
| Orange Studios Boyama ve öğren (Play) | ✓ | ✓ | ? | ✗ | ? | ✓ | ? | ? | ✓ | ✗ |
| IDZ/KidloLand Çocuklar için Boyama Oyunları (Play) | ? | ✓ | ? | ✓ | ? | ? | ? | ? | ? | ✗ |
| Bebi Family Coloring games 2-5 (Play) | ✓ | ✓ | ? | ✗ | ? | ✓ | ? | ? | ✗ | ✗ |
| BabyBus Little Panda's Kids Coloring (Play) | ✓ | ✓ | ? | ✗ | ? | ? | ? | ? | ✗ | ✗ |
| Mini Pixel Çocuk çizim - boyama oyunları (Play) | ? | ✓ | ? | ✓ | ? | ✓ | ? | ✓ | ✗ | ✗ |
| Play and Learn Coloring & Drawing for Kids (Play) | ? | ✓ | ? | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Game Tunes Binky Çocuk Resim Boyama 2+ (Play) | ✓ | ✓ | ? | ✓ | ✓ | ✓ | ? | ? | ✗ | ✗ |
| Sunny Kid Games Coloring Book - Kids Paint (Play) | ? | ✓ | ? | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Orange Studios Prensesler - Boyama Kitabı (Play) | ✓ | ✓ | ? | ✗ | ? | ✓ | ? | ? | ✓ | ✗ |
| **Karşılaştırma** | | | | | | | | | | |
| Cobi Paint (6757766966) — bizim | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ | ✗ | ✗ |

### Çizim

| Uygulama | Serbest çizim | Ayna/simetri | Damga/çıkartma | Noktadan noktaya | İzleme (tracing) | Adım adım çizim |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| Bimi Boo Drawing for Kids (1001555097) | ? | ✗ | ✗ | ✗ | ✗ | ✗ |
| Bimi Boo Baby Coloring Games (1129192831) | ? | ✗ | ✗ | ✗ | ✓ | ✓ |
| Bimi Boo Kids Coloring Games. Drawing (6444398254) | ✓ | ✓ | ? | ✓ | ✓ | ? |
| KidloLand Coloring Games 2-6 (451719402) | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ |
| Todli (908698556) | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ |
| Pinksy (1260895318) | ? | ✗ | ✓ | ✗ | ✗ | ✓ |
| Drawing Academy (1436397693) | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ |
| RV AppStudios Coloring Games (1480696573) | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ |
| Amaya Coloring Book: Kids Games (1475222650) | ? | ✗ | ✓ | ✗ | ✗ | ✗ |
| JMH Coloring Book Kids 2+ (1635552708) | ? | ✗ | ✗ | ✗ | ✗ | ✓ |
| Kakadoo Drawing and coloring (1511146155) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Crayola Create and Play (1431955703) | ✓ | ✗ | ✓ | ✗ | ✓ | ? |
| Sago Mini Crayon Club (6740246122) | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| Budge Kids Coloring Games (6701986471) | ? | ✗ | ✗ | ✗ | ✗ | ✗ |
| Kalemo (6819157588) [TR] | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Minik Palet (6818500948) [TR] | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| BoyaBoo (6824867811) [TR] | ? | ✗ | ? | ✗ | ✗ | ✗ |
| Kid Doodle / Çocuk Boyama Oyunları 2 6 Yaş (1500785406) [TR] | ? | ✗ | ✓ | ✗ | ✗ | ✗ |
| Toya (1509960273) | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ |
| 22LEARN Toddler Coloring Book (6511237267) | ? | ✗ | ✗ | ✗ | ✓ | ✗ |
| Disney Coloring World (1400326821) | ? | ✗ | ✓ | ✗ | ✗ | ✗ |
| **Play'e özgü (TR arama ilk 15)** | | | | | | |
| Orange Studios Boyama ve öğren (Play) | ✓ | ✗ | ✓ | ✓ | ✓ | ✗ |
| IDZ/KidloLand Çocuklar için Boyama Oyunları (Play) | ? | ✗ | ? | ? | ✓ | ✓ |
| Bebi Family Coloring games 2-5 (Play) | ✓ | ✗ | ? | ✗ | ✗ | ✗ |
| BabyBus Little Panda's Kids Coloring (Play) | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| Mini Pixel Çocuk çizim - boyama oyunları (Play) | ? | ✗ | ✗ | ✗ | ? | ? |
| Play and Learn Coloring & Drawing for Kids (Play) | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| Game Tunes Binky Çocuk Resim Boyama 2+ (Play) | ? | ✗ | ✓ | ✗ | ? | ✗ |
| Sunny Kid Games Coloring Book - Kids Paint (Play) | ? | ✗ | ✓ | ✗ | ✗ | ✗ |
| Orange Studios Prensesler - Boyama Kitabı (Play) | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| **Karşılaştırma** | | | | | | |
| Cobi Paint (6757766966) — bizim | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ |

### Canlanma ve oyun

| Uygulama | Boyanınca canlanma | 3B/AR | Video içerik | Sahne kurma/dekor | Mini oyun/yapboz | Giydirme/salon |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| Bimi Boo Drawing for Kids (1001555097) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Bimi Boo Baby Coloring Games (1129192831) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Bimi Boo Kids Coloring Games. Drawing (6444398254) | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ |
| KidloLand Coloring Games 2-6 (451719402) | ✓ | ? | ✗ | ✓ | ✓ | ✓ |
| Todli (908698556) | ✓ | ✗ | ✗ | ? | ✓ | ✗ |
| Pinksy (1260895318) | ✓ | ✗ | ✗ | ? | ✗ | ✓ |
| Drawing Academy (1436397693) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| RV AppStudios Coloring Games (1480696573) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Amaya Coloring Book: Kids Games (1475222650) | ? | ✗ | ✗ | ✗ | ✗ | ✗ |
| JMH Coloring Book Kids 2+ (1635552708) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Kakadoo Drawing and coloring (1511146155) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Crayola Create and Play (1431955703) | ? | ✓ | ✓ | ✓ | ✓ | ✓ |
| Sago Mini Crayon Club (6740246122) | ? | ✗ | ✗ | ? | ✗ | ✗ |
| Budge Kids Coloring Games (6701986471) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Kalemo (6819157588) [TR] | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Minik Palet (6818500948) [TR] | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| BoyaBoo (6824867811) [TR] | ? | ✗ | ✗ | ✗ | ✗ | ✗ |
| Kid Doodle / Çocuk Boyama Oyunları 2 6 Yaş (1500785406) [TR] | ✓ | ✗ | ✗ | ✗ | ? | ✗ |
| Toya (1509960273) | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ |
| 22LEARN Toddler Coloring Book (6511237267) | ? | ✗ | ✗ | ✗ | ✗ | ✗ |
| Disney Coloring World (1400326821) | ? | ✓ | ✗ | ✓ | ? | ✓ |
| **Play'e özgü (TR arama ilk 15)** | | | | | | |
| Orange Studios Boyama ve öğren (Play) | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ |
| IDZ/KidloLand Çocuklar için Boyama Oyunları (Play) | ? | ✗ | ✗ | ✓ | ✓ | ? |
| Bebi Family Coloring games 2-5 (Play) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| BabyBus Little Panda's Kids Coloring (Play) | ✓ | ? | ✗ | ✗ | ✗ | ✗ |
| Mini Pixel Çocuk çizim - boyama oyunları (Play) | ? | ✗ | ✗ | ✗ | ✗ | ✗ |
| Play and Learn Coloring & Drawing for Kids (Play) | ✓ | ✗ | ✗ | ✓ | ✓ | ✗ |
| Game Tunes Binky Çocuk Resim Boyama 2+ (Play) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Sunny Kid Games Coloring Book - Kids Paint (Play) | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ |
| Orange Studios Prensesler - Boyama Kitabı (Play) | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ |
| **Karşılaştırma** | | | | | | |
| Cobi Paint (6757766966) — bizim | ✗ | ✗ | ✗ | prototip | ✗ | ✗ |

### Öğrenme ve ses

| Uygulama | Renk adı sesli | Nesne adı/bilgi sesli | Harf-sayı-şekil | İki dilde öğrenme | Ses efekti | Arka plan müziği | Anlatıcı/sesli yönerge | Mikrofon kaydı |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Bimi Boo Drawing for Kids (1001555097) | ✗ | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Bimi Boo Baby Coloring Games (1129192831) | ✗ | ✗ | ✗ | ✗ | ✓ | ? | ✗ | ✗ |
| Bimi Boo Kids Coloring Games. Drawing (6444398254) | ✗ | ✗ | ✗ | ✗ | ✓ | ? | ✗ | ✗ |
| KidloLand Coloring Games 2-6 (451719402) | ✗ | ✗ | ✓ | ✗ | ? | ? | ✗ | ✗ |
| Todli (908698556) | ✗ | ✗ | ✓ | ✗ | ? | ? | ✓ | ✗ |
| Pinksy (1260895318) | ✗ | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Drawing Academy (1436397693) | ✗ | ✗ | ✓ | ✗ | ✓ | ✓ | ? | ✗ |
| RV AppStudios Coloring Games (1480696573) | ✗ | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Amaya Coloring Book: Kids Games (1475222650) | ✗ | ✗ | ✗ | ✗ | ✓ | ? | ✗ | ✗ |
| JMH Coloring Book Kids 2+ (1635552708) | ✗ | ✗ | ? | ✗ | ? | ? | ✗ | ✗ |
| Kakadoo Drawing and coloring (1511146155) | ✗ | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Crayola Create and Play (1431955703) | ✗ | ✗ | ✓ | ✗ | ? | ? | ✗ | ✗ |
| Sago Mini Crayon Club (6740246122) | ✗ | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Budge Kids Coloring Games (6701986471) | ✗ | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Kalemo (6819157588) [TR] | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ? | ✗ |
| Minik Palet (6818500948) [TR] | ✗ | ✗ | ? | ✗ | ? | ? | ✗ | ✗ |
| BoyaBoo (6824867811) [TR] | ? | ✓ | ✓ | ? | ? | ? | ? | ✗ |
| Kid Doodle / Çocuk Boyama Oyunları 2 6 Yaş (1500785406) [TR] | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ | ✗ |
| Toya (1509960273) | ✗ | ✗ | ✗ | ✗ | ? | ✓ | ✗ | ✗ |
| 22LEARN Toddler Coloring Book (6511237267) | ✗ | ✗ | ✓ | ✗ | ✓ | ? | ✗ | ✗ |
| Disney Coloring World (1400326821) | ✗ | ✗ | ✗ | ✗ | ? | ✓ | ✗ | ✗ |
| **Play'e özgü (TR arama ilk 15)** | | | | | | | | |
| Orange Studios Boyama ve öğren (Play) | ✗ | ? | ✓ | ✓ | ? | ? | ✗ | ✗ |
| IDZ/KidloLand Çocuklar için Boyama Oyunları (Play) | ✗ | ✗ | ? | ✗ | ? | ? | ✗ | ✗ |
| Bebi Family Coloring games 2-5 (Play) | ✗ | ✗ | ✗ | ✗ | ✓ | ? | ✗ | ✗ |
| BabyBus Little Panda's Kids Coloring (Play) | ✗ | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Mini Pixel Çocuk çizim - boyama oyunları (Play) | ✗ | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Play and Learn Coloring & Drawing for Kids (Play) | ✗ | ✗ | ✗ | ✗ | ? | ? | ✗ | ✗ |
| Game Tunes Binky Çocuk Resim Boyama 2+ (Play) | ✗ | ✗ | ✓ | ✗ | ? | ✓ | ✗ | ✗ |
| Sunny Kid Games Coloring Book - Kids Paint (Play) | ✗ | ✗ | ✓ | ✗ | ✓ | ? | ? | ✗ |
| Orange Studios Prensesler - Boyama Kitabı (Play) | ✗ | ✗ | ? | ✗ | ? | ? | ✗ | ✗ |
| **Karşılaştırma** | | | | | | | | |
| Cobi Paint (6757766966) — bizim | ✗ | prototip | ✗ | prototip | ✓ | ✗ | ✗ | ✗ |

### İçerik

| Uygulama | Sayfa/kapsam | Sezon/bayram içeriği | Düzenli yeni içerik | Lisanslı karakter | Yapay zekâ sayfa | Yazdırma |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| Bimi Boo Drawing for Kids (1001555097) | 176 sayfa / 11 tema | ✓ | ? | ✗ | ✗ | ✗ |
| Bimi Boo Baby Coloring Games (1129192831) | 165 sayfa / 11 paket | ✓ | ? | ✗ | ✗ | ✗ |
| Bimi Boo Kids Coloring Games. Drawing (6444398254) | 20+ ücretsiz; toplam belirtilmemiş | ✓ | ✓ | ✗ | ✗ | ✗ |
| KidloLand Coloring Games 2-6 (451719402) | 1000+ oyun (14 kategori) | ✓ | ✓ | ✗ | ✗ | ✗ |
| Todli (908698556) | 100+ ders, 300+ animasyon | ✓ | ? | ✗ | ✗ | ✗ |
| Pinksy (1260895318) | 70+ öğretici / 14 kategori (Play) | ✓ | ✓ | ✗ | ✗ | ✗ |
| Drawing Academy (1436397693) | 100+ canlı şablon / 150 çizim | ✓ | ? | ✗ | ✗ | ✗ |
| RV AppStudios Coloring Games (1480696573) | 400+ sayfa | ✓ | ✓ | ✗ | ✗ | ✗ |
| Amaya Coloring Book: Kids Games (1475222650) | 100+ sayfa / 9 paket | ✓ | ? | ✗ | ✗ | ✗ |
| JMH Coloring Book Kids 2+ (1635552708) | 50 sayfa (abonelikte) / 6 set | ✓ | ? | ✗ | ✗ | ✗ |
| Kakadoo Drawing and coloring (1511146155) | 130–135+ sayfa / 8 kategori | ? | ✗ | ✗ | ✗ | ✗ |
| Crayola Create and Play (1431955703) | "sınırsız" (iddia); aylık etkinlik | ✓ | ✓ | ✓ | ✗ | ✗ |
| Sago Mini Crayon Club (6740246122) | 1000+ sayfa / 75+ konu | ✓ | ✓ | ✓ | ✗ | ✗ |
| Budge Kids Coloring Games (6701986471) | 200+ sayfa | ✗ | ✗ | ✗ | ✗ | ✗ |
| Kalemo (6819157588) [TR] | 89 resim / 8 kitap (34 ücretsiz) | ✗ | ? | ✗ | ✗ | ✗ |
| Minik Palet (6818500948) [TR] | 100 resim (50 ücretsiz) | ✓ | ? | ✗ | ✗ | ✗ |
| BoyaBoo (6824867811) [TR] | ? (karuselde 10 paket görünüyor) | ✗ | ? | ✗ | ✗ | ✗ |
| Kid Doodle / Çocuk Boyama Oyunları 2 6 Yaş (1500785406) [TR] | 15 kitap; sayfa sayısı yazmıyor | ✓ | ✓ | ✗ | ✓ | ✓ |
| Toya (1509960273) | 35 sayfa | ✗ | ✗ | ✗ | ✗ | ✗ |
| 22LEARN Toddler Coloring Book (6511237267) | 144–150+ sayfa / 7 kategori | ✓ | ? | ✗ | ✗ | ✗ |
| Disney Coloring World (1400326821) | 2000+ sayfa | ✓ | ✓ | ✓ | ✗ | ✗ |
| **Play'e özgü (TR arama ilk 15)** | | | | | | |
| Orange Studios Boyama ve öğren (Play) | 200+ sayfa, 100+ etkinlik | ✓ | ? | ✗ | ✗ | ✗ |
| IDZ/KidloLand Çocuklar için Boyama Oyunları (Play) | 700+ oyun / 14 kategori | ✓ | ? | ✗ | ✗ | ✗ |
| Bebi Family Coloring games 2-5 (Play) | 400–500+ sayfa / 20+ kategori | ? | ? | ✗ | ✗ | ✗ |
| BabyBus Little Panda's Kids Coloring (Play) | 4 tema, 12 renk | ✗ | ✗ | ✗ | ✗ | ✗ |
| Mini Pixel Çocuk çizim - boyama oyunları (Play) | ? | ✗ | ✗ | ✗ | ✗ | ✗ |
| Play and Learn Coloring & Drawing for Kids (Play) | ? | ? | ✗ | ✗ | ✗ | ✗ |
| Game Tunes Binky Çocuk Resim Boyama 2+ (Play) | 150+ sayfa / 11 tema | ✗ | ✗ | ✗ | ✗ | ✗ |
| Sunny Kid Games Coloring Book - Kids Paint (Play) | 200+ resim | ✗ | ✗ | ✗ | ✗ | ✗ |
| Orange Studios Prensesler - Boyama Kitabı (Play) | 200+ sayfa | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Karşılaştırma** | | | | | | |
| Cobi Paint (6757766966) — bizim | 323 sayfa / 9 kategori / 3 seviye | ✗ | ✗ | ✗ | ✗ | ✓ |

### Kayıt ve ebeveyn

| Uygulama | Galeri | Otomatik kayıt | Paylaşım | Çoklu profil | Ebeveyn raporu/ilerleme | Süre sınırı | Ebeveyn kapısı |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Bimi Boo Drawing for Kids (1001555097) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| Bimi Boo Baby Coloring Games (1129192831) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| Bimi Boo Kids Coloring Games. Drawing (6444398254) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| KidloLand Coloring Games 2-6 (451719402) | ✓ | ? | ? | ✗ | ✗ | ✗ | ? |
| Todli (908698556) | ✓ | ? | ✓ | ✗ | ✗ | ✗ | ? |
| Pinksy (1260895318) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| Drawing Academy (1436397693) | ? | ? | ? | ✗ | ✗ | ✓ | ✓ |
| RV AppStudios Coloring Games (1480696573) | ? | ? | ? | ✓ | ? | ✗ | ? |
| Amaya Coloring Book: Kids Games (1475222650) | ✓ | ? | ✓ | ✗ | ✗ | ✗ | ? |
| JMH Coloring Book Kids 2+ (1635552708) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| Kakadoo Drawing and coloring (1511146155) | ? | ? | ✓ | ✗ | ✗ | ✗ | ? |
| Crayola Create and Play (1431955703) | ? | ? | ? | ? | ✗ | ✗ | ? |
| Sago Mini Crayon Club (6740246122) | ✓ | ? | ? | ✗ | ✗ | ✗ | ? |
| Budge Kids Coloring Games (6701986471) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| Kalemo (6819157588) [TR] | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ |
| Minik Palet (6818500948) [TR] | ✓ | ✓ | ? | ✓ | ✗ | ✓ | ✓ |
| BoyaBoo (6824867811) [TR] | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| Kid Doodle / Çocuk Boyama Oyunları 2 6 Yaş (1500785406) [TR] | ✓ | ✓ | ✓ | ? | ✗ | ✗ | ✓ |
| Toya (1509960273) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| 22LEARN Toddler Coloring Book (6511237267) | ✓ | ? | ? | ✗ | ✗ | ✗ | ? |
| Disney Coloring World (1400326821) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| **Play'e özgü (TR arama ilk 15)** | | | | | | | |
| Orange Studios Boyama ve öğren (Play) | ✓ | ? | ✓ | ✗ | ✗ | ✗ | ? |
| IDZ/KidloLand Çocuklar için Boyama Oyunları (Play) | ✓ | ? | ? | ✗ | ✗ | ✗ | ? |
| Bebi Family Coloring games 2-5 (Play) | ? | ? | ? | ✗ | ✗ | ✗ | ✓ |
| BabyBus Little Panda's Kids Coloring (Play) | ✓ | ? | ? | ✗ | ✗ | ✗ | ? |
| Mini Pixel Çocuk çizim - boyama oyunları (Play) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| Play and Learn Coloring & Drawing for Kids (Play) | ✓ | ? | ? | ✗ | ✗ | ✗ | ? |
| Game Tunes Binky Çocuk Resim Boyama 2+ (Play) | ? | ? | ? | ✗ | ✗ | ✗ | ? |
| Sunny Kid Games Coloring Book - Kids Paint (Play) | ✓ | ? | ✓ | ✗ | ✗ | ✗ | ✓ |
| Orange Studios Prensesler - Boyama Kitabı (Play) | ✓ | ? | ✓ | ✗ | ✗ | ✗ | ? |
| **Karşılaştırma** | | | | | | | |
| Cobi Paint (6757766966) — bizim | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✓ |

### Platform ve mağaza

| Uygulama | Apple Pencil (iddia) | Split View | Android | Çevrimdışı | Aile Paylaşımı (iddia) | Dil | Play Teacher Approved | Para modeli |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Bimi Boo Drawing for Kids (1001555097) | ✗ | ✗ | ✓ | ✓ | ? | 40 | ✓ (≤5 yaş) | abonelik (BB Pass), 6 ücretsiz sayfa |
| Bimi Boo Baby Coloring Games (1129192831) | ✗ | ✗ | ✓ | ? | ? | 40 | ✓ (≤8 yaş) | abonelik (BB Pass) |
| Bimi Boo Kids Coloring Games. Drawing (6444398254) | ✗ | ✗ | ✓ | ✓ | ? | 40 | ✓ (≤5 yaş) | abonelik (yıllık, 3 gün deneme) |
| KidloLand Coloring Games 2-6 (451719402) | ✗ | ✗ | ✓ | ✓ | ? | 18 | ✓ (≤12 yaş) | abonelik (7,99 $/ay, 49,99 $/yıl), 14 oyun ücretsiz |
| Todli (908698556) | ✗ | ✗ | ✓ | ✓ | ? | 33 | ✓ (≤8 yaş) | uygulama içi satın alma |
| Pinksy (1260895318) | ✗ | ✗ | ✓ | ✓ | ? | 33 | ✗ | uygulama içi satın alma |
| Drawing Academy (1436397693) | ✗ | ✗ | ✓ | ✓ | ? | 13 | ✓ (≤8 yaş) | abonelik (7 gün deneme) |
| RV AppStudios Coloring Games (1480696573) | ✗ | ✗ | ✓ | ? | — | 47 | ✓ (≤12 yaş) | tamamen ücretsiz (reklam yok, IAP yok) |
| Amaya Coloring Book: Kids Games (1475222650) | ✗ | ✗ | ✓ | ✓ | ? | 10 | ✓ (≤5 yaş) | abonelik (Amaya Plus, 3 cihaz) |
| JMH Coloring Book Kids 2+ (1635552708) | ✗ | ✗ | ✓ | ✓ | ? | 16 | ✗ | abonelik (haftalık 9,99 $, 3 gün deneme) |
| Kakadoo Drawing and coloring (1511146155) | ✗ | ✗ | ✓ | ? | ? | 1 | ✓ (≤8 yaş) | ücretsiz; Play'de IAP |
| Crayola Create and Play (1431955703) | ✗ | ✗ | ? | ? | ? | 12 | — (Play TR'de yok) | abonelik (7 gün deneme, 5 uygulama paketi) |
| Sago Mini Crayon Club (6740246122) | ✗ | ✗ | ✓ | ✓ | ? | 9 | ✓ (≤5 yaş) | abonelik (Piknik paketi) |
| Budge Kids Coloring Games (6701986471) | ✗ | ✗ | ✓ | ? | ? | 11 | ✓ (≤5 yaş) | abonelik |
| Kalemo (6819157588) [TR] | ✗ | ✗ | ✓ | ✓ | ✓ | 12 | ✗ | tek seferlik (kitap başı ya da hepsi) |
| Minik Palet (6818500948) [TR] | ✗ | ✗ | ✗ | ✓ | ✓ | 2 | — (Play'de yok) | tek seferlik paketler |
| BoyaBoo (6824867811) [TR] | ✗ | ✗ | ✗ | ? | ? | 1 (TR arayüz) | — (Play'de yok) | abonelik |
| Kid Doodle / Çocuk Boyama Oyunları 2 6 Yaş (1500785406) [TR] | ✓ (basınç) | ✓ | ✗ | ✓ (YZ hariç) | ? | 15 anlatıcı dili | — (Play'de bulunamadı) | abonelik (haftalık/yıllık) |
| Toya (1509960273) | ✗ | ✗ | ? | ? | ? | 1 | — (Play'de bulunamadı) | ücretsiz; IAP ? |
| 22LEARN Toddler Coloring Book (6511237267) | ✗ | ✗ | ✗ | ? | ? | 1 | — (Play'de yok) | IAP (kitaplar zamanla ücretsiz) |
| Disney Coloring World (1400326821) | ✓ | ✗ | ✓ | ✓ (indirilen içerik) | ✓ | 5 | ✓ (6–8 yaş) | abonelik |
| **Play'e özgü (TR arama ilk 15)** | | | | | | | | |
| Orange Studios Boyama ve öğren (Play) | — | — | ✓ | ? | — | ? | ✓ (≤8 yaş) | ücretsiz (reklam durumu ?) |
| IDZ/KidloLand Çocuklar için Boyama Oyunları (Play) | — | — | ✓ | ? | — | ? | ✓ (≤12 yaş) | "tamamen ücretsiz" (Play metni) |
| Bebi Family Coloring games 2-5 (Play) | — | — | ✓ | ✓ | — | ? | ✓ (≤5 yaş) | ücretsiz + IAP |
| BabyBus Little Panda's Kids Coloring (Play) | — | — | ✓ | ? | — | ? | ✗ | ücretsiz (reklam durumu ?) |
| Mini Pixel Çocuk çizim - boyama oyunları (Play) | — | — | ✓ | ✓ | — | ? | ✓ (≤12 yaş) | ücretsiz (reklam durumu ?) |
| Play and Learn Coloring & Drawing for Kids (Play) | — | — | ✓ | ? | — | ? | ✓ (≤8 yaş) | ücretsiz (reklamsız iddiası) |
| Game Tunes Binky Çocuk Resim Boyama 2+ (Play) | — | — | ✓ | ✓ | — | ? | ✓ (≤5 yaş) | tek IAP |
| Sunny Kid Games Coloring Book - Kids Paint (Play) | — | — | ✓ | ? | — | ? | ✓ (≤8 yaş) | ücretsiz (reklam durumu ?) |
| Orange Studios Prensesler - Boyama Kitabı (Play) | — | — | ✓ | ? | — | ? | ✓ (≤8 yaş) | ücretsiz (reklam durumu ?) |
| **Karşılaştırma** | | | | | | | | |
| Cobi Paint (6757766966) — bizim | ✓ (basınç) | ? | ✗ | ✓ | ? | 2 | — | tek seferlik (henüz açılmadı) |



## 3. Uygulama notları

Her uygulama için: vitrinin ilk 3 karesinin alt yazısı, açıklamanın ilk cümlesi, yaş bandı, özellik özeti, 2025–2026 sürüm notlarının yönü, Play durumu. Puanlar App Store ABD, 8 Kasım 2026.

### Bimi Boo Drawing for Kids – Baby Games (1001555097)
- Bimi Boo, 2–5 yaş, 4,28 puan (638 bin oy), v3.106 (1 Kasım 2026), 169 MB.
- Vitrin: "176 COLORING PAGES" · "Perfect for all ages" · "Different tools, colors and patterns" (15 renk, 15 desen, simli kalem, desen rulosu, kamera düğmesi).
- İlk cümle: "Drawing for Kids - Baby Games is an ad-free set of painting pages for toddlers to color and draw."
- Özellik: 176 sayfa, 11 tema (Cadılar Bayramı ve Noel dâhil); kalem, fırça, sprey, mum, keçeli, tebeşir; "Magic Painting"; geri al; çevrimdışı; 6 ücretsiz sayfa. Canlanma, öğrenme ve çıkartma yok.
- 2025–2026: 14 sürüm; yalnız "Magic" paketi (Nisan 2026) ve yeni ana menü (Haziran 2026). Kalanı kararlılık metni.
- Play: `com.bimiboo.drawing`, 5 Mn+, Teacher Approved (≤5 yaş).

### Bimi Boo Baby Coloring Games for Kids (1129192831)
- Bimi Boo, 2–4 yaş, 4,25 (467 bin), v2.73 (29 Ekim 2026).
- Vitrin: "165 Coloring Pages for Kids" · "Lots of Theme Packs" · "Cute Simple Pictures".
- İlk cümle: "Creative and educational games for children that help your child spend time with an electronic device effectively."
- Özellik (Play TR metni daha açık): dört yaş basamağı. 2+ "Renk Sihri" (parmak kaydırınca renk belirir), 3+ klasik boyama (fırça, kalem, keçeli, sim), 4+ "çizgileri takip et ve canlandır", 5+ noktalı kılavuzla çizim. Sesler ve komik karakterler.
- 2025–2026: 14 sürüm; animasyonlu sim efekti (Haziran 2026), grafik yenileme (Eylül 2026).
- Play: `com.bimiboo.coloring`, 10 Mn+, Teacher Approved (≤8 yaş).

### Bimi Boo Kids Coloring Games. Drawing (6444398254)
- Bimi Boo, 2–6 yaş, 4,22 (50 bin), v1.99 (30 Ekim 2026).
- Vitrin: 1. kare alt yazısız · "Child-Friendly Interface" (noktalı kılavuzla izleme, simli dolgu, çıkartma simgesi) · "Different Tools, Colours and Patterns" (35 desen).
- İlk cümle: "Bimi Boo Drawing is both fun and educational!"
- Özellik: biten sayfa kısa çizgi filme dönüşür; kontur boyama, serbest çizim, kaleidoskop ayna, neon-sim; aylık içerik; 20+ ücretsiz sayfa; abonelik.
- 2025–2026: 25 sürümün 15'i özellik metni. Sayıyla boyama (Aralık 2025); Noel, kış, Çin Yeni Yılı, St. Patrick, Paskalya, okula dönüş ve Cadılar Bayramı temaları; Scratch Surprise kazı oyunu (Mart 2026); Dot to Dot (Nisan 2026); büyük boyama güncellemesi (Mayıs 2026); piksel sanatı (Ağustos 2026). Bimi Boo'nun en hızlı özellik ekleyen uygulaması.
- Play: `com.bimiboo.kids.drawing`, 1 Mn+, Teacher Approved (≤5 yaş); "çocuk boyama" aramasında 15. sıra.

### KidloLand Coloring Games for Kids 2-6! (451719402)
- KidloLand ("Coloring Club"), 4,36 (227 bin), v11.65 (30 Ekim 2026).
- Vitrin: "COLORING" · "DRAWING" (kesik çizgi rehberli çizim) · "TRACING" (şekil izleme).
- İlk cümle: "Welcome to KidloLand Coloring Club® - a great place to start your child's creative journey, including coloring games, step-by-step drawings, toddler games, and cooking games."
- Özellik: 1000+ oyun; glow boyama, sürpriz boyama, "color and animate", mandala, piksel sanatı; adım adım çizim ve boş tuval; yapboz, noktadan noktaya, eşleştirme; sayıyla boyama, ABC, sayı ve şekil izleme; kelebek bahçesi ve akvaryum sahnesi; giydirme ve dekorasyon; yemek oyunları; altı ödül.
- 2025–2026: 12 özellik sürümü. Çizim kategorisi ve pizza süsleme (Temmuz 2025); Color and Pop, 3B piksel sanatı, şekil yapboz, "Connect the Numbers and Color" (Kasım 2025); Princess World: tırnak salonu, giydirme, ev dekorasyonu (Aralık 2025); Scene Coloring ve çıkartma ödülü, Home Design (Temmuz 2026); Cozy Coloring 40+ sayfa (Ağustos 2026); Cadılar Bayramı (Ekim 2026). Yön: boyama uygulamasından kız oyunları ve mini oyun platformuna.
- Play: IDZ Digital (KidloLand'ın Android yayıncı adı), `com.iz.coloring.games.kids.drawing.book.color.by.number`, 10 Mn+, 4,6, Teacher Approved (≤12 yaş); "çocuk boyama" aramasında 2. sıra.

### Todli: Drawing Games for Kids (908698556)
- Bini Games, 2–5 yaş, 4,49 (38 bin), v8.3.1 (23 Ekim 2026).
- Vitrin: "TODDLER COLOR GAMES" · "INTERACTIVE COLORING BOOK FOR KIDS / Voice-over / 100+ TUTORIALS" · "EASY KIDS DRAWING GAMES WITH TUTORIALS".
- İlk cümle: "Start your child's artistic journey with Todli — the ultimate safe, ad-free, offline coloring app for toddlers aged 2 to 5!"
- Özellik: her resim canlanır ve oynanabilir karaktere dönüşür; biten çizimler kişisel çıkartma defterine girer ve yeni resimlerde kullanılır; sesli adım adım çizim; sayıyla boyama; etkileşimli hikâye kitapları; ABC ve 123 izleme; mantık, yapboz, hafıza; paylaşım.
- 2025–2026: Hastane (Temmuz 2025), Tamagotchi tarzı evcil hayvan (Ağustos 2025), Serbest Çizim modu (Aralık 2025), Funny Stars yıldız birleştirme (Mart 2026), okula dönüş öğrenme paketleri (Ağustos 2026).
- Play: `com.binibambini.MiniLite`, 10 Mn+, Teacher Approved (≤8 yaş); Play metni 100+ ders ve 300+ animasyon diyor.

### Pinksy: Drawing Games for Kids (1260895318)
- Bini Games, kız çocuk 2–8 yaş, 4,61 (37 bin), v7.5.3 (19 Ekim 2026), 492 MB.
- Vitrin: "Drawing for girls" (neon çizim ekranı, SUBSCRIBE düğmesi) · "Build your sticker collection" · "Drawing step-by-step".
- İlk cümle: "Pinksy — Creative Art & Coloring Game for Kids Ages 2–8".
- Özellik: prenses, unicorn, chibi; güzellik salonu (tırnak, makyaj, saç) ve giydirme; keçeli, mum, kalem, simli fırça; çıkartma, baskı, desen; "her biten resim canlanır"; düzenli yeni içerik; çevrimdışı.
- 2025–2026: Creative Nails Studio (Ekim 2025), Noel kostümleri (Aralık 2025), tırnak aksesuarları (Mart 2026), Güzellik Salonu saç (Ağustos 2026). Yön: boyamadan çok salon ve giydirme.
- Play: `com.binibambini.drawingforgirls`, 10 Mn+, Teacher Approved yok.

### Drawing Academy – Kids Drawing Games & Coloring (1436397693)
- Bini Games, 2–7 yaş, 4,51 (18 bin), v5.6.3 (29 Ekim 2026).
- Vitrin: "DRAW 150 PICTURES!" · "Trace the lines!" · "All your drawings come to life!".
- İlk cümle: "Want to Be an Artist?"
- Özellik: 100+ canlı şablon (kontur bitince kelebek uçar, roket kalkar); harf ve sayı izleme, şarkı eşliğinde; sayıyla dinozor boyama; Magic Color Lab (cihazı salla, neon konfeti; müzikle boya); ebeveyn paneli: oyun süresi sınırı ve satın alma kilidi; çevrimdışı; 7 gün deneme.
- 2025–2026: Funny Stars (Kasım 2025), Noel karakterleri (Aralık 2025); 25 sürümün 22'si kararlılık metni.
- Play: `com.binibambini.acad.drawing`, 10 Mn+, Teacher Approved (≤8 yaş); "çocuk boyama" 10., "boyama oyunları" 14. sıra.

### RV AppStudios Coloring Games: Painting, Glow (1480696573)
- RV AppStudios, 4,51 (7,5 bin), v2.0.3 (4 Kasım 2026), 47 dil.
- Vitrin: "No Ads / 400+ Coloring Pages" · "Create Your Own Drawing" · "Bright Colors & Patterns".
- İlk cümle: "Kids love fun coloring games, and this Coloring Game is one of the best free coloring book and painting apps for children!"
- Özellik: beş mod. Fun Paint (dokun doldur, 12 renk), Color Fill (çıkartma, sim, mum, desen), Drawing (boş tuval), Glow Pen (karanlıkta neon), Number Paint (sayıyla boyama). Çocuk başına profil; zorluk ayarı; tamamen ücretsiz, reklamsız, satın alma yok.
- 2025–2026: 25 sürümün 24'ü özellik metni. İki üç haftada bir sezon teması (araba, Noel, kar, Paskalya, bahar, Anneler Günü, çikolata, yaz, okul, sonbahar, Cadılar Bayramı); Color Rain modu (Şubat 2026); piksel sayfaları (Nisan ve Eylül 2026); Simetrik boyama modu (Ağustos 2026); yeni sayıyla boyama resimleri (Ağustos 2026).
- Play: `com.rvappstudios.kids.coloring.book.color.painting`, 100 Mn+, 4,2, Teacher Approved (≤12 yaş); her iki aramada ilk 4.

### Amaya Coloring Book: Kids Games (1475222650)
- Amaya Soft, 2–5 yaş, 4,23 (20 bin), v2.13.0 (23 Ekim 2026).
- Vitrin: "Fun coloring book for kids / 100+ coloring pages" · "9 theme packs" · "Save colored pictures".
- İlk cümle: "Pencils and brushes are ready! Enjoy coloring, drawing, and learning with the Coloring Book app!"
- Özellik: temalar, desenler, çıkartmalar, galeri, animasyon ve ses efektleri; Amaya Plus aboneliği (20+ uygulama, 3 cihaz).
- 2025–2026: Kadınlar Tarihi Ayı paketi (Mart 2025), Dünya Günü paketi (Mayıs 2025), Cadılar Bayramı (Ekim 2026), kendi rengini karıştırma (Ekim 2026; listede renk karıştırma olan iki uygulamadan biri).
- Play: `com.amayasoft.toddler.kids.coloring.game.boys.girls.color`, 1 Mn+, Teacher Approved (≤5 yaş).

### JMH Coloring Book – Kids Games 2+ (1635552708)
- JMH Developers, 4,06 (5,3 bin), v2.1.0 (2 Kasım 2026).
- Vitrin: üç karede alt yazı yok; 6 araç (sihirli değnek, fırça, sprey, kalem, fosforlu, silgi) ve 6 renk görünüyor.
- İlk cümle: "Our app is a creative coloring game for kids with a large collection of amazing pictures featuring a variety of animals and vehicles, including service vehicles."
- Özellik: hayvan ve araç adlarını öğrenme (metin); kalem, fırça, sprey; sihirli değnek (tek dokunuş dolgu); abonelikte 50 sayfa, 10 araç, 6 set.
- 2025–2026: v2.0.0 (Ağustos 2026) adım adım çizim, sayfa animasyonları ve yeni grafik; kalanı optimizasyon.
- Para: haftalık 9,99 $, aylık 19,99 $, yıllık 99,99 $; listenin en pahalı aboneliği. Play: `coloring.book.games.kids.toddlers`, 100 B+, Teacher Approved yok.

### Kakadoo Drawing and coloring for kids (1511146155)
- Kakadoo (Joongly), 2–4+ yaş, 4,16 (12 bin), v1.85 (8 Ağustos 2026), yalnız İngilizce.
- Vitrin: alt yazı yalnız 2. karede: "135+ PAGES - 8 THEME PACKS"; 1. ve 3. karede parmakla dokunarak dolgu ve doku ruloları (bulut, çim, yıldızlı gece, kalp).
- İlk cümle: "Coloring book for kids and babies aged 2, 3, 4 years and older."
- Özellik: çocuk başladığı konturun dışına çıkamaz (çizgide kalma); doku boyama; Play metninde çizim modu (siyah kalemle çiz, sonra sayfa gibi boya) ve çizimi mesajlaşma uygulamasıyla büyükanneye gönderme.
- 2025–2026: 4 sürüm; büyük desen paleti (Mayıs 2025), genişletilmiş renk paleti (Ağustos 2026).
- Play: `com.joongly.coloring.kids`, 5 Mn+, Teacher Approved (≤8 yaş); "çocuk boyama" 6. sıra.

### Crayola Create and Play (1431955703)
- Red Games, 2 yaştan yetişkine, 4,34 (43 bin), v2.63.0 (5 Kasım 2026), 2,1 GB.
- Vitrin: "Developed by Crayola experts & educators!" (3B dinozor boyama) · "An app from the Crayola CREATIVITY BUNDLE" · "Coloring fun with digital Crayola art tools!".
- İlk cümle: "Explore dozens of art, coloring, and educational activities with Crayola Create and Play, the official Crayola app for curious kids to learn through fun, creative play!"
- Özellik: "sınırsız" sayfa iddiası; piksel sanatı; glow art; 3B tasarım; kodlama, heceleme, sayı tanıma; kendi resminden yapboz; evcil hayvan bakımı; damga, çıkartma, sim; aylık etkinlik; Smithsonian iş birliği; COPPA ve PRIVO.
- 2025–2026: 18 özellik sürümü, her ay bir etkinlik: Paddington (lisanslı, Eylül 2025 ve Temmuz 2026), Halloween Quest, Holiday Storybook Quest, Creativity Week, Winter Rainbow Rush, Glow Art sayfaları (Mart 2026), Unicorn Month, Camp Create and Play, Dino Month (yeni araçlar), Style Squad, Space (Kasım 2026). "How to Draw" videoları (Kasım 2025); izleme etkinlikleri (Mayıs 2026).
- Play TR'de Create and Play yok; "Crayola Minikler Boyama" (Red Games, 2–6 yaş) ayrı bir uygulama ve Teacher Approved rozeti yok.

### Sago Mini Crayon Club: Color PAW Patrol (6740246122)
- Sago Mini (Piknik), 2–6 yaş, 4,03 (1,3 bin), v2.4 (2 Kasım 2026), 983 MB.
- Vitrin: "crayon club / Color and create with PAW Patrol! / Part of the piknik bundle" · "Make art with Sago Mini World pals!" · "Safe, ad-free, and perfect for ages 2-6".
- İlk cümle: "ARTS & CRAFTS WITHOUT THE CLEAN-UP!"
- Özellik: 1000+ sayfa, 75+ konu; PAW Patrol, Gabby's Dollhouse, Mo Willems'ın Güvercin'i, Sago Mini; mum, boya, damga, çıkartma; sayıyla boyama; boş tuval; sihirli değnekle gökkuşağı, sim, desenli washi bant; aylık içerik; çevrimdışı; COPPA ve kidSAFE.
- 2025–2026: 13 özellik sürümü. Cadılar Bayramı glow (Ekim 2025); Gabby 45 sayfa ve yeni çıkartmalar (Kasım 2025); kış ve Yeni Yıl; Sevgililer; Ramazan paketi (Mart 2026); Güvercin paketleri ve paint-by-numbers (Nisan 2026); Fairylandia; PAW Dino; Pixel Art Studio (Temmuz 2026); Dünya Kedi Günü; Sago Mini paketi, etkileşimli sayfalar ve "ekstra büyük sayfa" (Eylül 2026); 50 karanlıkta parlayan sayfa (Ekim 2026).
- Play: `com.sagosago.CrayonClub.googleplay`, 1 Mn+, Teacher Approved (≤5 yaş).

### Budge Kids Coloring Games & Drawing (6701986471)
- Budge Studios, 2–6 yaş, 4,21 (13 bin), v2026.1.0 (15 Haziran 2026).
- Vitrin: "200+ coloring pages / KIDS COLORING GAME" · "No ADS / EASY FOR ALL AGES" · "Ages 1-5 / FUN & SIMPLE".
- İlk cümle: "Discover a fun and engaging coloring app for kids!"
- Özellik: kolay çizim ve boyama araçları, "benzersiz fırça stilleri", hayvan, araba, prenses, çiçek. Açıklama başka özellik vermiyor. Abonelik; ESRB Privacy Certified.
- 2025–2026: 3 sürüm, hepsi hata düzeltmesi. Listenin en az geliştirilen uygulaması.
- Play: `com.budgestudios.googleplay.BabyColoringBook`, 500 B+, Teacher Approved (≤5 yaş), son güncelleme Ekim 2025; "çocuk boyama" 9. sıra.

### Kalemo: Kids Coloring Games (6819157588) [TR]
- Fikret Alp Işık, 2–6 yaş, henüz oy yok, v1.0.0 (4 Kasım 2026), 12 MB, iOS 17+.
- Vitrin: "Tap to color, like magic / Colors bloom and stay inside the lines" · "89 pictures in 8 books / Animals, dinosaurs, space, fantasy and more" · "Crayons, markers, glitter / Patterns and rainbows for bigger kids".
- İlk cümle: "Kalemo is a calm, cheerful coloring studio for children aged 2 to 6."
- Özellik: dokunarak dolgu; mum, keçeli ve sim şeklin içinde kalır; desen ve gökkuşağı dolgusu; 6 kâğıtta serbest çizim (kara tahta dâhil); "Resimlerim" duvarı; kazanılan renk kutuları (Pastel, Neon, Kozmik); maskot kutlaması; yumuşak ses ve müzik; üç yaş modu (6–7 yaşta zoom ve detaylı resim); Büyükler köşesi: 12 dil, ses, müzik, titreşim, oyun süresi sınırı, ilerleme; tek seferlik satın alma (kitap başı ya da hepsi); Aile Paylaşımı.
- Sürüm geçmişi: tek sürüm. Play: `com.kalemo.app` (yayıncı "Hook Global"), 10+ indirme, Teacher Approved yok.
- Cobi'ye en yakın rakip: aynı çekirdek artı yaş modu, ödül kutusu, süre sınırı ve ilerleme ekranı.

### Minik Palet: Kids Coloring (6818500948) [TR]
- Caner Gümüş, 0–6 yaş, henüz oy yok, v1.2.0 (28 Ekim 2026), 7 MB.
- Vitrin: "100 coloring pages / 50 free • No ads" · "Tap to paint! / No reading needed" · "Color by number / Learn colors and numbers".
- İlk cümle: "Minik Palet is an ad-free, safe coloring app made for children aged 0-6, available in Turkish and English."
- Özellik: üç oyun: Dokun ve Boya, Serbest Çizim (renkli kâğıt, neon kalem), Numara Boya. Kolay ve zor seviye (1–3 ve 4–6 yaş); kutlama; otomatik kayıt; kardeşler için ayrı profil ve galeri (pakette 6 çocuk); günlük ekran süresi sınırı; Türkçe ve İngilizce; ebeveyn kapısı; Ebeveyn Paketi ve Cadılar Bayramı Paketi tek seferlik; Aile Paylaşımı.
- 2025–2026: 1.1.0 (20 Ekim 2026) 100 sayfa, Deniz ve Oyuncak kategorileri, Cadılar Bayramı paketi, dil seçimi; 1.2.0 Ebeveyn Paketi'ne erişim.
- Play'de yok.

### BoyaBoo: Çocuk Boyama Oyunu (6824867811) [TR]
- Arif Tok, henüz oy yok, v1.0.2 (6 Kasım 2026), 19 MB.
- Vitrin: 1. kare logo ve Oynat; 2. kare kilitli paket karuseli (sayılar "3", harf "A", prenses, dinozor, ahtapot, roket, aslan, inek, itfaiye) ve 10 boyanmış önizleme; 3. kare zürafa sayfası, kova aracı, dokunulan buruna "Burun" konuşma balonu, kamera simgesi, Türk bayrağı, 11 renk, 5 kilitli doku (sim, parlak, gökkuşağı, nokta, puantiye) ve kilitli renk çarkı. Kare dosya adları: `acilis`, `secim`, `konusan_boyama`, `sayilar`, `premium`, `renk_karistirici`.
- Açıklama: mağazadaki metin yalnız abonelik iptali, EULA ve gizlilik bağlantısından oluşuyor; gizlilik politikası bir claude.ai artifact adresine gidiyor. Özellik listesi yok.
- Özellik (yalnız ekranlardan): dokunarak dolgu, konuşan etiket (dokunulan parçanın adı), sayı ve harf paketleri, doku dolguları, renk karıştırıcı, kamera ile kaydetme; abonelik.
- Sürüm geçmişi: tek sürüm. Play'de yok.

### Kid Doodle / Çocuk Boyama Oyunları 2 6 Yaş (1500785406) [TR]
- Atilla Özder, 2–6 yaş, 4,0 (152 oy), v3.1.0 (21 Ekim 2026), 200 MB, iOS 17+.
- Vitrin: "Offline coloring game for kids / ages 0-6" · "Safe to hand over / No ads, parental controls" (15 + 3 matematik kapısı) · "Kids imagine / AI creates coloring pages" (Kim? Nerede? Ne yapıyor? kartları). 4.–10. karelerin dosya adları: coloring-comes-alive, gentle-voice, hear-and-learn-color-names, fun-facts, glitter-patterns-stickers, simple-or-detailed, art-widget.
- İlk cümle: "Kid Doodle is a free coloring app for kids ages 2 to 6 — a safe, ad-free creative playground where toddlers and preschoolers can color, paint and doodle to their heart's content."
- Özellik: 15 temalı kitap; sihirli dolgu kovası; sim, desen, çıkartma; her araç rengini hatırlar; anlatıcı renk ve araç adlarını söyler, biten sayfayı alkışlar (15 dil); güvenli yapay zekâ ile sayfa üretimi (resimli kartlardan seçim, yazmak ebeveyn kapısı arkasında, internet gerekir); kaydet, paylaş, yazdır; haftalık ya da yıllık abonelik.
- 2025–2026: ilk sürüm 22 Haziran 2026; 25 sürümün 24'ü özellik metni. Çizgi içi/dışı anahtarı (Haziran); anlatıcı ve renk adları (Temmuz); kutlama ve "nasıl boyanır" turu; canlı kitap dünyaları; yazdırma ve Apple Pencil basıncı (Ağustos); gerçek fırça dokuları, şarkılar, sağdan sola diller; yapay zekâ sayfaları "My Coloring Pages" (24 Ağustos); kalınlık kaydırıcısı, iki parmak zoom, çamaşır ipi galerisi (1 Eylül); Müzik sayfaları biten resimle konser verir, widget, imza (15 Eylül); Çiftlik kitabı (hayvan sesleri); Taşıtlar kitabı (24 hareket eden araç, gerçek motor sesleri, çocuğun boyadığı araçlar trafikte); Uzay kitabı (roket sayar, iniş yapar); iPad her yön, Split View, çoklu pencere (17 Ekim); bilgiler sesli okunur (21 Ekim).
- Play'de bulunamadı. Not: 2–6 yaş bandında listenin en hızlı özellik temposu; Cobi ile aynı yaş bandı ve Türk geliştirici.

### Toya: Coloring games for kids (1509960273)
- ToyaTap, 2–6 yaş, 4,67 (2,6 bin), v5.5 (13 Ekim 2026), yalnız İngilizce.
- Vitrin: "Coloring game for kids" · "Doodle drawing zone" (ayna düğmesi, çıkartma yüzü, desen rulosu, baloncuk değneği, kova) · "Magic sketch mode" (siyah tuvalde gökkuşağı neon, damga).
- İlk cümle: "Enrich your child's screen time with art and creativity."
- Özellik: 35 sayfa (listenin en azı); mum, keçeli, simli fırça; "animasyonlu ögelerle boyama"; sakinleştirici müzik; reklamsız.
- 2025–2026: 12 özellik sürümü. Movie Theater Mode, boyama tekniği videoları (Kasım 2025); Neon Odası (Nisan 2026); müze koridoru oda seçici (Ekim 2026); grafik yenilemeleri.
- Play TR'de bulunamadı.

### 22LEARN Toddler Coloring Book for Kids / Colorland (6511237267)
- 22LEARN, 2–5 yaş, 4,65 (1,2 bin), v1.2.2 (3 Şubat 2026), 83 MB, yalnız İngilizce.
- Vitrin: "Drawing for kids" · "Learn how to draw shapes!" (kesik çizgili kalp izleme) · "150+ Coloring pages" (çerçevede Oynat düğmeli domuz).
- İlk cümle: "Get ready for a world of vibrant colors and endless creativity with the Colorland app!"
- Özellik: 144 sayfa, 7 kategori; büyülü kale merkezi; biten sayfalar kale duvarında sergilenir; şekil, sayı ve harf izleme; fırça, kalem, "duvar kâğıdı"; animasyon ve ses efekti.
- 2025–2026: 4 sürüm; Dino kitabı ücretsiz (Ocak 2025), Noel kitabı (Aralık 2025), ABC izleme ücretsiz (Şubat 2026). Son sürüm Şubat 2026.
- Play'de yok.

### Disney Coloring World (1400326821)
- StoryToys, 4,34 (282 bin), v18.9.1 (22 Ekim 2026), 1,9 GB, 5 dil.
- Vitrin: "A playful and creative experience" · "2,000+ coloring pages" · "A rainbow of art tools" (mum, kalem, desen bandı, çıkartma, kova, sim, 3 keçeli, dolma kalem, sprey, silgi).
- İlk cümle: "Disney Coloring World offers a magical and creative experience for children and fans of all ages, featuring beloved characters from Frozen, Disney Princesses, Mickey, Stitch, Pixar, Star Wars, Marvel, and more!"
- Özellik: 2000+ sayfa; Magic Color aracı ("mükemmel boyar"); giydirme; mekân dekorasyonu; 3B oyun setleri; indirilen içerik çevrimdışı; Aile Paylaşımı; Apple Pencil; abonelik.
- 2025–2026: 21 özellik sürümü. Her ay lisanslı paket (Zootropolis 2, Toy Story 5, Hoppers, Elio, dört Star Wars paketi, Marvel); düzen yenilemesi, paket ve karaktere göre arama (Ocak 2025); Giydirme yenilemesi (Nisan 2026); müzikli pop-up çıkartma kitabı Küçük Deniz Kızı (Temmuz 2026).
- Play: `com.storytoys.disney.pixar.coloring.princess.googleplay`, 10 Mn+, Teacher Approved (6–8 yaş), "Google Kalem desteği"; "çocuk boyama" 19., "boyama oyunları" 15. sıra.

### Play'e özgü uygulamalar (TR arama ilk 15)

Sıra numaraları: Ç = "çocuk boyama", B = "boyama oyunları" (8 Kasım 2026, `hl=tr&gl=TR`).

#### Orange Studios — Boyama ve öğren (`com.orange.coloring.learn.kids`)
- Ç1, B1; 100 Mn+, 3,9, Teacher Approved (≤8 yaş).
- Vitrin: "Draw and colors realistically!" (nesne adı iki dilli: "Car- Automóvil") · "More than 100 educational activities!" (glow, piksel, matematik, piyano, hafıza, giydirme kareleri) · "Easy and intuitive for children!".
- Özellik: 200+ sayfa; serbest mod; alfabe ve sayı yazma, sayma, şekil; 100+ damga; albüm; sosyal ağlara paylaşım; noktaları birleştir; Noel, Cadılar Bayramı, dinozor koleksiyonları. Reklam durumu sayfadan çıkarılamadı.

#### IDZ Digital (KidloLand) — Çocuklar için Boyama Oyunları (`com.iz.coloring.games.kids.drawing.book.color.by.number`)
- Ç2, B8; 10 Mn+, 4,6, Teacher Approved (≤12 yaş).
- Vitrin: "Boyama oyunu" · "Resim çizme" (kesik çizgi rehberli çizim) · "Renk oyunu".
- Özellik: Kidlo markası; 700+ oyun, 14 kategori; sihirli karalama, sürpriz boyama, dekorasyon oyunları, Noel ve Paskalya; Play metni "tamamen ücretsiz" diyor (iOS sürümü abonelik).

#### Bebi Family — Coloring games for kids: 2-5 y (`com.bebi.family.baby.coloring`)
- Ç4, B13; 5 Mn+, 4,0, Teacher Approved (≤5 yaş).
- Vitrin: "500+ coloring pages" (dokun-doldur silme efekti) · "Amazing Color Collections" · "Let Your Creativity Shine" (Glow).
- Özellik: 400+ sesli ve animasyonlu sayfa; 20+ kategori; glow çizim; basitleştirilmiş çizim modu; çevrimdışı; dokunma koruması (başparmak ekranın aktif alanındayken yanlış dokunmayı engelliyor; listede tek örnek); ebeveyn kapısı; reklamsız.

#### BabyBus — Little Panda's Kids Coloring (`com.sinyee.babybus.paintingIII`)
- Ç5; 10 Mn+, 3,5, Teacher Approved yok.
- Vitrin: "Let's draw a magic picture!" · "Color the police car!" (damga, kova, sprey) · "The animals have come to life!" (3B görünümlü köpek).
- Özellik: iki mod (boyama, karalama); 4 tema; 12 renk; sihirli kalem, yağlı boya fırçası; fotoğraf aracı ve albüm; sihirli değnek ile boyanan resim "gerçek nesneye" dönüşür (koşan köpek, giden otobüs).

#### Mini Pixel — Çocuk çizim - boyama oyunları (`minipixel.easy.coloring.pages.draw.kids.painting`)
- Ç7; 100 B+, 3,6, Teacher Approved (≤12 yaş).
- Vitrin: "DRAW AND COLOR" (örneğe bak ve kopyala) · "EASY TO PAINT" · "COLORED BY NUMBERS" (1–9 etiketli araba).
- Özellik: adım adım boyama öğrenme, glow boya, zoom ve kaydırma, kategoriler, çevrimdışı. Açıklama metni Bimi Boo ve RV metinlerinden kopyalanmış ("Bu Bimi Boo Çocuklar için Boyama…"). Reklam durumu çıkarılamadı.

#### Play and Learn Games — Coloring & Drawing for Kids (`com.pages.kids.toddlers.painting`)
- Ç11; 10 B+, 4,2, Teacher Approved (≤8 yaş).
- Vitrin: "Fun drawing for kids" · "Paint cute pictures" · "Foster creativity and imagination" (üç kare de serbest çizim tuvali).
- Özellik: çizimler canlanır ve hikâye anlatır; etkileşimli sahneler (roket inşa et, boya, fırlat; yumurtayı boya ve çatlat; çiçek çiz ve sula; Noel ağacı süsle); biten resimler çıkartma olur; serbest çizim aracı; galeri; reklamsız; 8 yaşa kadar. Son güncelleme Ekim 2025.

#### Game Tunes — Çocuk Resim Boyama Oyunları 2+ / Binky (`com.GameChangers.Coloringforkids`)
- Ç12; 50 B+, Teacher Approved (≤5 yaş).
- Vitrin: "150+ Çocuklar İçin Boyama Sayfaları" (hoparlör düğmesi, kalınlık kaydırıcısı) · "Çeşitli araçlar, renkler ve motifler" (desen dolguları) · "11 Boyama Kategorisi".
- Özellik: 150+ sayfa, 11 tema (ABC, 123, şekiller, renkler, glow çizim dâhil); mum, fırça, kalem, desen, çıkartma, sim; sayıyla boyama; rahatlatıcı müzik; çevrimdışı; tek uygulama içi satın alma.

#### Sunny Kid Games — Coloring Book - Kids Paint (`com.sunny.coloring.book.kids.paint`)
- Ç13; 10 Mn+, 3,5, Teacher Approved (≤8 yaş).
- Vitrin: "Coloring with pencils, crayons and brushes!" · "Decorate with fun stickers!" · "Lots of fun activities" (arayüz etiketleri İspanyolca: COLOREAR, DECORAR, BATERÍA…).
- Özellik: hepsi bir arada: 200+ resim, çıkartmayla manzara süsleme, davul ve ksilofon, boyut ve renge göre sıralama, yapboz, şekil, harf ve sayı telaffuzu, toplama ve çıkarma, hayvan sesleri, hafıza, köstebek, robot; yetişkin onayıyla sosyal paylaşım. TR mağazada İspanyolca arayüz görüntüleri.

#### Orange Studios — Prensesler - Boyama Kitabı (`com.orange.gamesforkids.coloring.princess`)
- Ç14, B11; 50 Mn+, 3,9, Teacher Approved (≤8 yaş).
- Vitrin: "Draw and colors realistically!" · "Easy and intuitive for kids!" (neon kurbağa) · "Many educational activities!" (Pixel Art, Glow, Pop Balloons, Free Drawing, Learn the Colors, Music, Drum).
- Özellik: 200+ prenses, unicorn, deniz kızı, elbise ve makyaj sayfası; tırnak salonu; 100+ çıkartma; serbest çizim; piyano, hafıza, havai fişek; albüm ve sosyal paylaşım; "tüm içerik %100 ücretsiz" (reklam durumu çıkarılamadı).

#### İlk 15 dışında kalan ama ilk 22'de görünen çocuk uygulamaları
- Toy Tap "Çocuklar Boyama Kitabı" (Ç17; 10 Mn+; Teacher Approved yok; 8 kategori, etiket damgası, "animasyon ve seslendirme" iddiası).
- IDZ "Çocuk Boyama Oyunlar & Kitabı" (Ç16; 10 Mn+; 50+ sayfa; "Button Art" güncellemesi).
- Mini Muffin "1+ yaş için boyama oyunu" (B18; 500 B+; Teacher Approved ≤5 yaş; sim, duvar kâğıdı bandı; son güncelleme Ekim 2025).
- BabyBus "Prenses Oyunu: Fantezi Boyama" (B17; 10 Mn+; çocuk ve yetişkin karışık; 160+ renk, rastgele renklendirme, zoom).
- Fat Tuna "Super Kids Coloring Book" (Ç20; sayfası incelenmedi).
- Kapsam dışı yetişkin uygulamaları: Happy Color, Color by Number (Wildlife), Pixel Art (Easybrain), No.Pix, Paint by Number (Oakever), ibis Paint X, Zen Color, Pixel Art Coloring (HDuo), Colorfy, Tap Color Pro.

### Khan Academy Kids, Pok Pok, Sago Mini World (yalnız boyama bölümü)
- Khan Academy Kids (1378467217, ücretsiz, 2–8 yaş): "Create" sekmesinde hayvan, taşıt ve karakter boyama sayfaları, arka planlar, kuru boya ve mum boya, gökkuşağı mum, sürükle-bırak çıkartmalar; mikrofonla ses kaydederken çıkartmaları hareket ettirince animasyonlu hikâye oluşur; geri al; Galeri'ye kaydetme ve kamera rulosuna aktarma. Mağaza açıklaması boyamadan hiç söz etmiyor; kaynak yardım makalesi. Mikrofon kaydı listedeki 21 rakibin hiçbirinde yok.
- Pok Pok (1550204730, abonelik, 2–8 yaş): "Drawing" oyuncağı boş tuval, 8 renk ve tuvali silen bir kaydırıcı; boyama sayfası yok (MacStories, 2021). Ayrıca "Connect the Dots" oyuncağı (9to5Mac, Kasım 2022). Dilsiz, düşük uyaranlı tasarım; 8 renk Cobi Minik modun 9 rengiyle aynı mertebe.
- Sago Mini World (874425722, abonelik, 2–6 yaş): App Store açıklaması ve yardım sayfası boyama ya da çizimden söz etmiyor; Sago'nun boyama ürünü ayrı uygulama Crayon Club (aynı Piknik aboneliği). World içinde boyama etkinliği olup olmadığı doğrulanamadı (?).


## 4. Standart, ayırt edici, nadir

Sayımlar 21 App Store rakibi üzerinden; Play'e özgü 9 uygulama ayrı sütunda. "?" sayısı, o özelliğin mağaza metninden ne kadar az okunabildiğini gösterir: ebeveyn kapısı 17, otomatik kayıt 18, zoom 19 ve fırça kalınlığı 20 uygulamada "?"; bu dört özellik vitrine konmuyor.

N (App Store listesi) = 21, N (Play'e özgü) = 9

| Özellik | App Store ✓ | App Store ? | Play'e özgü ✓ | Sınıf (App Store ✓ oranı) | Cobi |
|---|:-:|:-:|:-:|---|:-:|
| Dokunarak dolgu | 13/21 | 8 | 5/9 | standart (≥60 %) | ✓ |
| Fırçayla boyama | 21/21 | 0 | 9/9 | standart (≥60 %) | ✓ |
| Çizgide kalma | 4/21 | 17 | 0/9 | nadir (<20 %) | ✓ |
| Sayıyla boyama | 7/21 | 1 | 3/9 | ayırt edici (20–39 %) | ✗ |
| Desen/doku dolgu | 16/21 | 4 | 1/9 | standart (≥60 %) | ✗ |
| Simli/neon/gökkuşağı | 15/21 | 6 | 5/9 | standart (≥60 %) | ✓ |
| Fırça kalınlığı | 1/21 | 20 | 0/9 | nadir (<20 %) | ✓ |
| Zoom | 2/21 | 19 | 1/9 | nadir (<20 %) | ✓ |
| Piksel sanatı | 5/21 | 0 | 2/9 | ayırt edici (20–39 %) | ✗ |
| Renk karıştırma | 2/21 | 0 | 0/9 | nadir (<20 %) | ✗ |
| Serbest çizim | 11/21 | 10 | 5/9 | yaygın (40–59 %) | ✓ |
| Ayna/simetri | 3/21 | 0 | 0/9 | nadir (<20 %) | ✓ |
| Damga/çıkartma | 11/21 | 2 | 6/9 | yaygın (40–59 %) | ✓ |
| Noktadan noktaya | 4/21 | 0 | 1/9 | nadir (<20 %) | ✗ |
| İzleme (tracing) | 7/21 | 0 | 2/9 | ayırt edici (20–39 %) | ✗ |
| Adım adım çizim | 6/21 | 2 | 1/9 | ayırt edici (20–39 %) | ✗ |
| Boyanınca canlanma | 9/21 | 6 | 3/9 | yaygın (40–59 %) | ✗ |
| 3B/AR | 2/21 | 1 | 0/9 | nadir (<20 %) | ✗ |
| Video içerik | 2/21 | 0 | 0/9 | nadir (<20 %) | ✗ |
| Sahne kurma/dekor | 3/21 | 3 | 3/9 | nadir (<20 %) | prototip |
| Mini oyun/yapboz | 4/21 | 2 | 5/9 | nadir (<20 %) | ✗ |
| Giydirme/salon | 4/21 | 0 | 2/9 | nadir (<20 %) | ✗ |
| Renk adı sesli | 1/21 | 1 | 0/9 | nadir (<20 %) | ✗ |
| Nesne adı/bilgi sesli | 2/21 | 0 | 0/9 | nadir (<20 %) | prototip |
| Harf-sayı-şekil | 6/21 | 2 | 3/9 | ayırt edici (20–39 %) | ✗ |
| İki dilde öğrenme | 0/21 | 1 | 1/9 | nadir (<20 %) | prototip |
| Ses efekti | 7/21 | 14 | 2/9 | ayırt edici (20–39 %) | ✓ |
| Arka plan müziği | 5/21 | 16 | 1/9 | ayırt edici (20–39 %) | ✗ |
| Anlatıcı/sesli yönerge | 2/21 | 3 | 0/9 | nadir (<20 %) | ✗ |
| Mikrofon kaydı | 0/21 | 0 | 0/9 | nadir (<20 %) | ✗ |
| Sezon/bayram içeriği | 16/21 | 1 | 2/9 | standart (≥60 %) | ✗ |
| Düzenli yeni içerik | 8/21 | 10 | 0/9 | ayırt edici (20–39 %) | ✗ |
| Lisanslı karakter | 3/21 | 0 | 0/9 | nadir (<20 %) | ✗ |
| Yapay zekâ sayfa | 1/21 | 0 | 0/9 | nadir (<20 %) | ✗ |
| Yazdırma | 1/21 | 0 | 0/9 | nadir (<20 %) | ✓ |
| Galeri | 8/21 | 13 | 6/9 | ayırt edici (20–39 %) | ✓ |
| Otomatik kayıt | 3/21 | 18 | 0/9 | nadir (<20 %) | ✓ |
| Paylaşım | 5/21 | 16 | 3/9 | ayırt edici (20–39 %) | ✓ |
| Çoklu profil | 2/21 | 2 | 0/9 | nadir (<20 %) | ✗ |
| Ebeveyn raporu/ilerleme | 1/21 | 1 | 0/9 | nadir (<20 %) | ✗ |
| Süre sınırı | 3/21 | 0 | 0/9 | nadir (<20 %) | ✗ |
| Ebeveyn kapısı | 4/21 | 17 | 2/9 | nadir (<20 %) | ✓ |

Okuma:

- Standart (≥60 %): fırçayla boyama 21/21, desen ve doku dolgusu 16/21, sezon ve bayram içeriği 16/21, simli/neon/gökkuşağı fırça 15/21, dokunarak dolgu 13/21. Cobi'de desen dolgusu ve sezon içeriği yok.
- Yaygın (40–59 %): serbest çizim 11/21, damga ve çıkartma 11/21, boyanınca canlanma 9/21. Cobi'de canlanma yok.
- Ayırt edici (20–39 %): sayıyla boyama 7, izleme 7, ses efekti 7 (14'ü "?"), düzenli yeni içerik 8, galeri 8 (13'ü "?"), harf-sayı-şekil 6, adım adım çizim 6, piksel sanatı 5, arka plan müziği 5, paylaşım 5. Cobi'de sayıyla boyama, izleme, adım adım, piksel, müzik ve düzenli içerik yok.
- Nadir (<20 %): çizgide kalma 4, noktadan noktaya 4, mini oyun 4, giydirme 4, ebeveyn kapısı 4 (17'si "?"), ayna 3, lisanslı karakter 3, sahne kurma 3, süre sınırı 3, otomatik kayıt 3, 3B 2, video 2, nesne adı sesli 2, anlatıcı 2, zoom 2, çoklu profil 2, renk karıştırma 2, renk adı sesli 1, fırça kalınlığı 1, yapay zekâ sayfa 1, yazdırma 1, ebeveyn raporu 1, iki dilde öğrenme 0, mikrofon kaydı 0.
- Cobi'nin nadir kümedeki varlıkları: çizgide kalma, ayna, zoom, fırça kalınlığı, yazdırma, otomatik kayıt, ebeveyn kapısı; prototipte sahne kurma ve iki dilde sesli nesne adı.
- Play'e özgü 9 uygulamada ayrışan tek şey mini oyun (5/9) ve sahne kurma (3/9): Play'in ücretsiz boyama uygulamaları "hepsi bir arada" eğitim paketine kayıyor.


## 5. Vitrin dili

Sayımlar 21 App Store rakibinin ilk 3 ekran görüntüsü alt yazısı ve açıklamanın ilk cümlesi üzerinden.

| Vaat | İlk 3 karede | Örnek alt yazılar |
|---|:-:|---|
| Sayfa ya da içerik sayısı rakamla | 12/21 | "176 COLORING PAGES", "2,000+ coloring pages", "400+ Coloring Pages", "89 pictures in 8 books", "100 coloring pages / 50 free", "150+ Coloring pages", "135+ PAGES" |
| Araç ve desen çeşitliliği | 6/21 | "Different tools, colors and patterns" (Bimi Boo ×2), "Bright Colors & Patterns", "A rainbow of art tools", "Crayons, markers, glitter / Patterns and rainbows", "Coloring fun with digital Crayola art tools!" |
| Reklamsız, güvenli, ebeveyn kontrolü | 6/21 | "No Ads", "No ads, parental controls", "Safe, ad-free", "No ADS", "50 free • No ads" |
| Öğrenme, izleme | 4/21 | "TRACING", "Trace the lines!", "Learn how to draw shapes!", "Learn colors and numbers" |
| Yaş bandı | 3/21 | "Ages 1-5", "perfect for ages 2-6", "ages 0-6" |
| Adım adım, öğretici | 3/21 | "Drawing step-by-step", "100+ TUTORIALS", "DRAWING" (rehberli) |
| Marka ya da lisans | 3/21 | "Color and create with PAW Patrol!", "Developed by Crayola experts", Disney logosu |
| Boyanınca canlanma | 2/21 | "All your drawings come to life!", "INTERACTIVE COLORING BOOK" (Kid Doodle 4. karede "coloring comes alive"; BabyBus Play'de "The animals have come to life!") |
| Okuma gerektirmez, dokun boya | 2/21 | "Tap to color, like magic", "Tap to paint! No reading needed" (yalnız Kalemo ve Minik Palet; Cobi açıklamada) |
| Abonelik paketi | 2/21 | "CREATIVITY BUNDLE", "Part of the piknik bundle" |
| Yapay zekâ | 1/21 | "Kids imagine / AI creates coloring pages" |
| Kız çocuk | 1/21 | "Drawing for girls" |

Açıklamanın ilk cümlesi: 10/21 yaş bandı veriyor ("toddlers aged 2 to 5", "children aged 2 to 6", "ages 2–8"); 5/21 ilk cümlede "safe", "ad-free" ya da "offline" diyor (Todli, Drawing Academy, Kid Doodle, Minik Palet, Bimi Boo Drawing); 7/21 "educational", "learn" ya da "develop" ile açıyor. Canlanma açıklamalarda ilk 3 kareden daha sık: 9/21 açıklama, 2/21 alt yazı. Alt yazısız vitrin: JMH (3 kare), Kakadoo (2 kare), Bimi Boo Kids (1 kare), BoyaBoo (2 kare).

En çok vitrinlenen beş vaat sırasıyla: sayfa sayısı, araç ve desen çeşitliliği, reklamsız ve güvenli, öğrenme ve izleme, yaş bandı. Cobi'nin mevcut vitrini (01_fill, 02_lines, 03_celebration, 04_draw, 05_home, 06_artworks, 07_gate) bu beşliden sayfa sayısını ve reklamsızlığı açıklamada veriyor, alt yazıda vermiyor.


## 6. Doğrulanamayanlar

- Matristeki her "?" bir doğrulanamayan; toplam dağılımı 4. bölümdeki tabloda. En çok "?" alan sütunlar: fırça kalınlığı (20/21), zoom (19), otomatik kayıt (18), çizgide kalma (17), ebeveyn kapısı (17), arka plan müziği (16), paylaşım (16), ses efekti (14), galeri (13). Bu özellikler mağaza metnine girmiyor; uygulamayı açmadan karar verilemez.
- BoyaBoo: App Store açıklaması özellik metni içermiyor (yalnız abonelik, EULA ve gizlilik bağlantısı); özellikler ekran görüntüsü ve dosya adlarından çıkarıldı. "Konuşan boyama" sesli mi yoksa yalnız yazılı etiket mi, karardan belli değil.
- Budge: açıklama "kolay araçlar, benzersiz fırça stilleri" dışında özellik vermiyor; Budge'ın Play sayfası da aynı metin.
- "Boyanınca canlanma" ile "arayüz animasyonu" ayrımı Amaya, 22LEARN, Crayon Club ("interactive coloring pages") ve Disney ("3D playsets") için metinden çözülemedi; "?" bırakıldı.
- "Düzenli yeni içerik": yalnız açıklamada "regularly/monthly" diyen ya da sürüm geçmişinde aylık içerik görülen uygulamalar ✓; Bimi Boo Drawing ve Baby Coloring gibi bayram teması ekleyip ritim vaat etmeyenler "?".
- Çevrimdışı: açıklamada yazmayanlar "?"; RV AppStudios ve Kakadoo gibi ücretsiz uygulamalar için reklam yokluğu çevrimdışı anlamına gelmez.
- Apple Pencil ve Aile Paylaşımı yalnız iddia edildiğinde ✓ (Disney, Kid Doodle, Kalemo, Minik Palet); Apple'ın API'sindeki `familyShareEnabledDate` alanı güvenilir okunamadı.
- Google Play'de reklam var/yok bilgisi ("Reklam içerir" etiketi) ayrıştırılmadı; Orange Studios, BabyBus, Mini Pixel, Sunny ve IDZ için reklam durumu "?".
- Play arama sıralaması tek bir kişiselleştirilmemiş `curl` isteğinin kart sırası (8 Kasım 2026, 10:38); cihazdaki Play uygulamasında sıra değişebilir.
- Play'de bulunamayanlar: Kid Doodle, Toya, 22LEARN, Crayola Create and Play (TR), Minik Palet, BoyaBoo, Cobi. Arama ve tahmini paket adlarıyla denendi; farklı bir paket adıyla yayında olabilirler.
- Vitrin alt yazıları ABD vitrininden; Türk geliştiricilerin TR vitrinindeki alt yazılar Türkçe olabilir, karşılaştırılmadı. Yalnız ilk 3 kare okundu; Kid Doodle'ın 4.–10. kareleri dosya adlarından yorumlandı.
- Sürüm geçmişi Apple'ın verdiği son 25 sürümle sınırlı; Pinksy, Todli, Drawing Academy, RV, Kid Doodle, Crayola, Disney ve Crayon Club için 25 sürüm 2025–2026'nın tamamını kapsamıyor (en eski görülen sürüm tarihi her uygulamanın notunda).
- Sago Mini World içinde boyama etkinliği var mı: App Store açıklaması, yardım sayfası ve web araması yanıt vermedi.
- Pok Pok çizim oyuncağının 8 renk bilgisi 2021 tarihli bir inceleme; güncel sürümde değişmiş olabilir.
- Khan Academy Kids'in boyama sayfası sayısı ve çıkartma listesi yardım makalesinde yok.
- Cobi için Split View ve Aile Paylaşımı bu çalışmada kontrol edilmedi; "?" bırakıldı.


## 7. Kaynaklar

Her App Store uygulaması için üç adres okundu: `https://apps.apple.com/us/app/id<ID>`, `https://apps.apple.com/tr/app/id<ID>?l=tr`, `https://itunes.apple.com/lookup?id=<ID>&country=us` (ve `country=tr`). Sürüm geçmişi: `https://apps.apple.com/api/apps/v1/catalog/us/apps/<ID>?platform=web&additionalPlatforms=ipad&extend=versionHistory`. Aşağıda kimlikler ve Play adresleri.

| Uygulama | App Store ID | Google Play |
|---|---|---|
| Bimi Boo Drawing for Kids | 1001555097 | https://play.google.com/store/apps/details?id=com.bimiboo.drawing&hl=tr&gl=TR |
| Bimi Boo Baby Coloring Games | 1129192831 | https://play.google.com/store/apps/details?id=com.bimiboo.coloring&hl=tr&gl=TR |
| Bimi Boo Kids Coloring Games. Drawing | 6444398254 | https://play.google.com/store/apps/details?id=com.bimiboo.kids.drawing&hl=tr&gl=TR |
| KidloLand Coloring Games | 451719402 | https://play.google.com/store/apps/details?id=com.iz.coloring.games.kids.drawing.book.color.by.number&hl=tr&gl=TR |
| Todli | 908698556 | https://play.google.com/store/apps/details?id=com.binibambini.MiniLite&hl=tr&gl=TR |
| Pinksy | 1260895318 | https://play.google.com/store/apps/details?id=com.binibambini.drawingforgirls&hl=tr&gl=TR |
| Drawing Academy | 1436397693 | https://play.google.com/store/apps/details?id=com.binibambini.acad.drawing&hl=tr&gl=TR |
| RV AppStudios Coloring Games | 1480696573 | https://play.google.com/store/apps/details?id=com.rvappstudios.kids.coloring.book.color.painting&hl=tr&gl=TR |
| Amaya Coloring Book | 1475222650 | https://play.google.com/store/apps/details?id=com.amayasoft.toddler.kids.coloring.game.boys.girls.color&hl=tr&gl=TR |
| JMH Coloring Book 2+ | 1635552708 | https://play.google.com/store/apps/details?id=coloring.book.games.kids.toddlers&hl=tr&gl=TR |
| Kakadoo | 1511146155 | https://play.google.com/store/apps/details?id=com.joongly.coloring.kids&hl=tr&gl=TR |
| Crayola Create and Play | 1431955703 | TR'de yok; Crayola Minikler Boyama: https://play.google.com/store/apps/details?id=com.crayolallc.coloring.toddler&hl=tr&gl=TR |
| Sago Mini Crayon Club | 6740246122 | https://play.google.com/store/apps/details?id=com.sagosago.CrayonClub.googleplay&hl=tr&gl=TR |
| Budge Kids Coloring Games | 6701986471 | https://play.google.com/store/apps/details?id=com.budgestudios.googleplay.BabyColoringBook&hl=tr&gl=TR |
| Kalemo | 6819157588 | https://play.google.com/store/apps/details?id=com.kalemo.app&hl=tr&gl=TR |
| Minik Palet | 6818500948 | bulunamadı |
| BoyaBoo | 6824867811 | bulunamadı |
| Kid Doodle | 1500785406 | bulunamadı |
| Toya | 1509960273 | bulunamadı |
| 22LEARN Toddler Coloring Book | 6511237267 | bulunamadı |
| Disney Coloring World | 1400326821 | https://play.google.com/store/apps/details?id=com.storytoys.disney.pixar.coloring.princess.googleplay&hl=tr&gl=TR |
| Cobi Paint | 6757766966 | yayında değil |

Play'e özgü uygulamalar:

- https://play.google.com/store/apps/details?id=com.orange.coloring.learn.kids&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=com.bebi.family.baby.coloring&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=com.sinyee.babybus.paintingIII&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=minipixel.easy.coloring.pages.draw.kids.painting&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=com.pages.kids.toddlers.painting&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=com.GameChangers.Coloringforkids&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=com.sunny.coloring.book.kids.paint&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=com.orange.gamesforkids.coloring.princess&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=com.toddler.coloring&hl=tr&gl=TR (Toy Tap)
- https://play.google.com/store/apps/details?id=com.minimuffin.coloringstories&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=com.sinyee.babybus.princess_coloring_fantasy_magic_girls_games&hl=tr&gl=TR
- https://play.google.com/store/apps/details?id=com.iz.coloring.games.kids.drawing.color.book.painting.learning.baby.toddlers&hl=tr&gl=TR

Play aramaları:

- https://play.google.com/store/search?q=%C3%A7ocuk%20boyama&c=apps&hl=tr&gl=TR
- https://play.google.com/store/search?q=boyama%20oyunlar%C4%B1&c=apps&hl=tr&gl=TR

Khan Academy Kids, Pok Pok, Sago Mini World:

- https://apps.apple.com/us/app/id1378467217 ve https://khankids.zendesk.com/hc/en-us/articles/21188738836763-How-to-use-creative-tools-inside-the-Khan-Kids-app
- https://apps.apple.com/us/app/id1550204730, https://www.macstories.net/reviews/pok-pok-playroom-a-delightful-digital-toybox-for-kids/, https://9to5mac.com/2022/11/17/pok-pok-playroom-connect-the-dots/
- https://apps.apple.com/us/app/id874425722 ve https://help.sagomini.com/article/368-what-is-sago-mini-world

Ham veri (bu oturumun çalışma alanı, repo dışı): `/private/tmp/claude-501/-Users-muazcobanos-Work-Workspace-Cobi-Paint-Mobile/ed955974-f6d6-4880-9d51-962c5cb4a230/scratchpad/ozellik/raw/` altında `lookup_*.json`, `vh/*.json`, `version_history_filtered.txt`, `shots/`, `play/*.html`, `play/play_details_all.txt`. Matris üretici: aynı klasörde `build_tables.py`.
