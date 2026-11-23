# Cobi Paint: Google Play yayını

Bu dosya Google Play hazırlığının kaynağıdır: teknik kontroller, Play Console'da yapılanlar, upload
anahtarı, beyanların taslak cevapları ve yayına kadar kalan sıra. Mağaza metinleri `store_listing.md` içindeki
"Google Play" bölümündedir.

## Hesap ve uygulama (17 Kasım 2026)

- Geliştirici hesabı: cobistudio44@gmail.com, hesap kimliği 6559163290636255355, kişisel hesap, tacir
  beyanı yapılmış. Chrome'da Play Console bu hesapla `u/1` altında açılır.
- Uygulama oluşturuldu: Play uygulama kimliği 4972658893265024757, ad "Cobi: Coloring Games for Kids",
  paket adı `com.cobi.paint.cobi_paint_mobile` (oluşturma formunda müsaitliği sorgulandı, kullanılabilir
  çıktı; paket adı sonradan değişmez), varsayılan dil İngilizce (ABD), Türkçe çeviri, tür Uygulama,
  Ücretsiz. Tam Sürüm sonradan uygulama içi ürün olarak eklenir; ücretsiz yayımlanan uygulama ücretliye
  çevrilemez.
- Eski Play hesabı Nisan 2024'te kapandı. Bu repo 14 Ocak 2026'da başladı; paket adı eski hesapta
  yayımlanmış olamaz.

## Teknik kontroller

`flutter build appbundle --release` ve `flutter build apk --release` ile 2.3.0+10 derlendi:

| Kontrol | Sonuç |
|---|---|
| Hedef API (targetSdk) | 36 (Flutter 3.38.3 varsayılanı); minSdk 24, compileSdk 36, NDK 28.2 |
| 16 KB sayfa boyutu | `zipalign -c -P 16` doğruladı; bütün `.so` dosyalarında LOAD hizası en az 2^14 |
| İzinler | `BILLING`, `INTERNET`, `ACCESS_NETWORK_STATE` (satın alma kütüphanesinden), `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` |
| Reklam kimliği | Yok. Manifest'e `tools:node="remove"` ile koruma eklendi; ileride bir bağımlılık ekleyemez |
| Reklam, analitik, çökme raporu | Yok: bağımlılıklarda Firebase, AdMob ya da analitik paketi yok |
| İmza | Play'e kayıtlı upload anahtarı Memoko'nunki (SHA1 `96:5A:E9…18:54`), aşağıdaki "Upload anahtarı" bölümüne bakın. Repodaki `android/app/cobi-paint-keystore.jks` bugün Play'de geçmez. Parolalar `android/key.properties` içinde (ikisi de gitignore'da) |
| Gizlilik politikası | https://muazcoban.github.io/cobi-paint-mobile/privacy_policy.html canlı |

Satın alma kodu `--dart-define=COBI_IAP=true` olmadan kapalıdır; Play'e gidecek derlemede satın alma ekranı
yoktur. Kilit açılırken: Play'de ödeme profili, `com.cobi.paint.full` uygulama içi ürünü, Families
politikasının istediği ebeveyn kapısı (satın alma zaten kapı arkasında) ve aşağıdaki beyanların güncellenmesi.

## Play Console'da yapılanlar

- Uygulama içeriği: gizlilik politikası, reklam (yok), oturum açma bilgileri (kısıtlanmış bölüm yok),
  reklam kimliği (kullanılmıyor), resmi kurum uygulaması (hayır), finans özellikleri (yok), sağlık
  özellikleri (yok).
- Mağaza ayarları: Uygulama, kategori Eğitim, etiketler Boyama kitabı, Eğitim, Okul öncesi eğitim, Resim,
  Sanat ve tasarım; e-posta cobipaint@gmail.com, web sitesi https://muazcoban.github.io/cobi-paint-mobile/.
- Varsayılan mağaza girişi: İngilizce ve Türkçe ad, kısa ve tam açıklama (taslak olarak kaydedildi).
- 23 Kasım 2026: varsayılan mağaza girişi iki dilde görselleriyle kaydedildi; kurulum listesi 12/12 oldu ve
  kapalı test açıldı. Play kaydederken "yapay zekâyla üretilmiş öğe beyanı" istedi: 512 px simge ve iki
  tanıtım görseli (simgeyi içerir) etiketli, ekran görüntüleri etiketsiz (uygulamanın kendi ekranları).
  Etiketli görsel mağazada yapay zekâ notuyla görünür; etiket Öğe kitaplığından değiştirilebilir.
- 23 Kasım 2026: "Kapalı test - Alpha" kanalı kuruldu. Kapsam 178 ülke ve bölge. Test kullanıcıları
  geliştirici hesabı düzeyindeki "Cobi Studio test kullanıcıları" e-posta listesinden gelir; liste Memoko ile
  ortaktır ve 23 Kasım'da 11 kişiydi. Geri bildirim adresi cobipaint@gmail.com. Sürüm 10 (2.3.0) yüklendi;
  Play'in hesapladığı ilk indirme boyutu 14,6 MB. Aynı gün 17 değişiklik Google incelemesine gönderildi.

## Upload anahtarı (23 Kasım 2026)

Play bu uygulama için Memoko'nun upload anahtarını bekler, repodaki Cobi anahtarını değil.

| Sertifika | SHA1 |
|---|---|
| Play'in beklediği (Memoko'nun upload anahtarı) | `96:5A:E9:90:5B:93:22:97:8E:D0:0F:E9:74:CD:AB:77:6E:27:18:54` |
| Repodaki `cobi-paint-keystore.jks` | `FB:08:94:E1:CE:93:BE:7A:C9:4B:52:D3:E6:0C:CE:F1:A5:AB:FC:F5` |

Repodaki anahtarla imzalanan paket "Android App Bundle yanlış anahtarla imzalanmış" hatası alır. İki
projede de paketin adı `app-release.aab`; ilk yükleme denemesinde Memoko'nun paketi yüklendi. Play o paketi
paket adı yüzünden reddetti, ama anahtarını bu yükleme sırasında Cobi'nin upload anahtarı olarak kaydettiği
görünüyor. Kullanıcıya giden imza bundan etkilenmez: Play App Signing açık, dağıtılan APK'ları Play bu
uygulamaya özel ve Google'da duran uygulama imzalama anahtarıyla imzalar.

**Sürüm derlemek.** Gradle imzayı `android/key.properties` dosyasından okur. 2.3.0 (10) şöyle derlendi:
Cobi'nin `key.properties` dosyası yedeklendi, yerine Memoko reposundaki `android/key.properties` kopyalandı,
`flutter build appbundle --release` koşuldu, sonra Cobi'nin dosyası geri kondu. Yüklemeden önce imzayı ve
paket adını kontrol edin; Memoko'nun paketi de aynı anahtarı taşır, yalnız SHA1 ikisini ayırmaz:

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab | grep SHA1
unzip -p build/app/outputs/bundle/release/app-release.aab base/manifest/AndroidManifest.xml | strings | grep -m1 com.cobi.paint
```

**Cobi'nin kendi anahtarına dönmek.** Play Console → Uygulama imzalama → "Sıfırlama talep edin". Play yeni
upload sertifikasını `.pem` dosyası olarak ister. Talep Google'ın onayına bağlıdır; onay gelene kadar yalnız
kayıtlı anahtarla yükleme yapılır.

## Beyanlar ve taslak cevaplar

23 Kasım 2026'da dört beyan Play'de tamamlanmış görünüyordu; Yayın özeti hedef yaş aralığını 0–8 gösterdi.
Aşağıdaki taslaklar cevapların gerekçesi olarak kalıyor.

Bu dört beyan sahibin onayını ister: anketi doldurmak IARC Hizmet Şartları'nı kabul etmek demektir, hedef
kitle Families taahhütleri içerir, tacirlik durumu hukuki bir karardır.

**İçerik derecelendirmesi (IARC).** Kategori: oyun olmayan, eğitim ve eğlence içerikli uygulama. Şiddet,
korku, cinsellik, kumar, uyuşturucu, küfür: yok. Kullanıcılar birbiriyle iletişim kurmaz, içerik
paylaşmaz (resim paylaşımı ebeveyn kapısının arkasında, sistemin paylaşım menüsüyle), konum paylaşılmaz.
Dijital ürün satın alma: bugünkü derlemede yok; kilit açılınca "evet" olarak güncellenir. Beklenen sonuç:
her bölgede en düşük yaş derecesi (PEGI 3, ESRB Everyone, USK 0).

**Hedef kitle ve içerik.** Yaş grupları: 5 ve altı, 6–8 (Büyük mod 6 yaş ve üstü için). Uygulama çocukların
ilgisini çeker: evet. Families politikası tam uygulanır: reklam yok, reklam kimliği yok, veri toplanmaz,
dış bağlantılar ve satın alma ebeveyn kapısının arkasında. Play bu beyanla uygulamayı Teacher Approved
incelemesine alabilir.

**Veri güvenliği.** Veri toplanmaz ve paylaşılmaz. Resimler yalnız cihazda kalır; paylaşım kullanıcının
seçtiği uygulamaya sistem menüsüyle gider ve geliştiriciye ulaşmaz. Hesap yok, bu yüzden hesap silme
bağlantısı gerekmez. Puan isteme Google Play'in kendi penceresidir (`in_app_review`).

**Tacirlik durumu ve Hizmet Şartları.** Hesap tacir beyanlı; Play bu uygulama için durumu onaylamayı ya da
"bu uygulama tacir uygulaması değil" demeyi istiyor. Satış (Tam Sürüm) planlandığı için "evet" beklenir;
karar sahibin. App Store Connect'te Cobi'nin DSA durumu "non-trader"; iki mağaza aynı gerçeği anlatmalı.
Hizmet Şartları bağlantısı isteğe bağlı ("varsa"); bugün böyle bir sayfa yok.

## Görseller

`tool/store/play_graphics.py` 512 px simgeyi ve iki dilde 1024×500 tanıtım görselini üretir.
`tool/store/take_screenshots.py --android --define COBI_LOCALE=tr_TR` aynı mağaza yürüyüşünü emülatörde koşar
(emülatörün sistem dili adb ile değişmediği için dili yürüyüş kendisi ayarlar); Play telefon
karesinde uzun kenar kısa kenarın en çok iki katı olabildiği için emülatör 1080×1920'ye ayarlanır, 7 inç
tablet 1200×1920, 10 inç tablet 1600×2560. Alt yazıları `tool/store/caption_screenshots.py` ekler. Dosyalar
`build/store_screenshots/play_*` altında, repoda değil.

## Yayına kadar sıra

1. Dört beyan: tamam.
2. İlk AAB: 2.3.0 (10) 23 Kasım 2026'da kapalı test kanalına yüklendi. Derleme numarası (versionCode) bir
   kez yüklenince tekrar kullanılamaz; sıradaki numara 11. İmza için "Upload anahtarı" bölümüne bakın.
3. Kapalı test: 23 Kasım 2026'da incelemeye gönderildi. Onaydan sonra Test kullanıcıları sekmesinde web
   katılım bağlantısı görünür; Memoko'daki düzene göre beklenen bağlantı
   https://play.google.com/apps/testing/com.cobi.paint.cobi_paint_mobile. Yeni kişisel hesaplarda üretime
   çıkmak için en az 12 test kullanıcısının son 14 gün boyunca kapalı teste katılmış olması gerekir; şart her
   uygulama için ayrıdır. Ortak liste 23 Kasım'da 11 kişiydi.
4. 14 gün sonra üretime erişim başvurusu, sonra üretim sürümü. Yayından sonra geliştirici sitesine Play
   bağlantısı eklenir (ayrı repo).
