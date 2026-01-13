# Firebase Kurulum Rehberi - Cobi Paint

## 1. Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. "Proje Ekle" butonuna tıklayın
3. Proje adı: `cobi-paint` (veya istediğiniz bir isim)
4. Google Analytics'i aktif edin (isteğe bağlı)
5. Projeyi oluşturun

## 2. iOS Uygulaması Ekleme

1. Firebase Console'da iOS simgesine tıklayın
2. Bundle ID: `com.cobi.paint.cobiPaintMobile`
3. App nickname: `Cobi Paint iOS`
4. `GoogleService-Info.plist` dosyasını indirin
5. Dosyayı `ios/Runner/` klasörüne kopyalayın

## 3. Android Uygulaması Ekleme

1. Firebase Console'da Android simgesine tıklayın
2. Package name: `com.cobi.paint.cobi_paint_mobile`
3. App nickname: `Cobi Paint Android`
4. `google-services.json` dosyasını indirin
5. Dosyayı `android/app/` klasörüne kopyalayın

## 4. Firestore Database Kurulumu

1. Firebase Console'da "Firestore Database" seçin
2. "Veritabanı oluştur" butonuna tıklayın
3. Test modunda başlayın (daha sonra güvenlik kuralları ekleyin)

### Koleksiyon Yapısı:

```
categories/
  ├── animals/
  │   ├── name: "Hayvanlar"
  │   ├── nameEn: "Animals"
  │   ├── icon: "🐾"
  │   └── order: 1
  │
  └── plants/
      ├── name: "Bitkiler"
      ├── nameEn: "Plants"
      ├── icon: "🌸"
      └── order: 2

images/
  ├── image_001/
  │   ├── name: "Sevimli Kedi"
  │   ├── category: "animals"
  │   ├── imagePath: "images/animals/cat_001.png"
  │   ├── isActive: true
  │   └── createdAt: Timestamp
  │
  └── image_002/
      ├── name: "Güzel Çiçek"
      ├── category: "plants"
      ├── imagePath: "images/plants/flower_001.png"
      ├── isActive: true
      └── createdAt: Timestamp
```

## 5. Firebase Storage Kurulumu

1. Firebase Console'da "Storage" seçin
2. "Başlayın" butonuna tıklayın
3. Test modunda başlayın

### Klasör Yapısı:

```
images/
  ├── animals/
  │   ├── cat_001.png
  │   └── dog_001.png
  │
  ├── plants/
  │   └── flower_001.png
  │
  └── vehicles/
      └── car_001.png

user_artworks/
  └── {userId}/
      └── {artworkId}.png
```

## 6. Güvenlik Kuralları

### Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Categories - herkes okuyabilir
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if false; // Sadece admin
    }

    // Images - herkes okuyabilir
    match /images/{imageId} {
      allow read: if true;
      allow write: if false; // Sadece admin
    }

    // Users - kendi verisine erişim
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Public images
    match /images/{allPaths=**} {
      allow read: if true;
      allow write: if false;
    }

    // User artworks
    match /user_artworks/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 7. FlutterFire CLI ile Otomatik Kurulum (Önerilen)

```bash
# FlutterFire CLI'yi yükleyin
dart pub global activate flutterfire_cli

# Firebase'i yapılandırın
flutterfire configure --project=cobi-paint
```

Bu komut otomatik olarak:
- `lib/firebase_options.dart` dosyasını oluşturur
- iOS ve Android konfigürasyonlarını ekler

## 8. Resim Ekleme

Firebase Console'dan veya programatik olarak resim ekleyebilirsiniz:

### Console'dan:
1. Storage > images > animals klasörüne gidin
2. "Dosya yükle" ile PNG resmi yükleyin
3. Firestore > images koleksiyonuna belge ekleyin

### Admin Panel (Önerilen):
Daha kolay resim yönetimi için bir admin web paneli oluşturabilirsiniz.

## Notlar

- Boyama resimleri siyah-beyaz çizgi resimler olmalıdır
- Önerilen resim boyutu: 1024x1024 piksel
- Desteklenen format: PNG (şeffaf arkaplan için)
- Dosya boyutu: Maksimum 2MB önerilir
