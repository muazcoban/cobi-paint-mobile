import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// App name
  ///
  /// In tr, this message translates to:
  /// **'Cobi Paint'**
  String get appName;

  /// Home screen title
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get home;

  /// Categories title
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get categories;

  /// My artworks title
  ///
  /// In tr, this message translates to:
  /// **'Eserlerim'**
  String get myArtworks;

  /// Settings title
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// Animals category
  ///
  /// In tr, this message translates to:
  /// **'Hayvanlar'**
  String get animals;

  /// Plants category
  ///
  /// In tr, this message translates to:
  /// **'Bitkiler'**
  String get plants;

  /// Vehicles category
  ///
  /// In tr, this message translates to:
  /// **'Araçlar'**
  String get vehicles;

  /// Characters category
  ///
  /// In tr, this message translates to:
  /// **'Karakterler'**
  String get characters;

  /// Nature category
  ///
  /// In tr, this message translates to:
  /// **'Doğa'**
  String get nature;

  /// Food category
  ///
  /// In tr, this message translates to:
  /// **'Yiyecekler'**
  String get food;

  /// Import image button
  ///
  /// In tr, this message translates to:
  /// **'Resim Yükle'**
  String get importImage;

  /// Go pro button
  ///
  /// In tr, this message translates to:
  /// **'Pro\'ya Geç'**
  String get goPro;

  /// Save button
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// Saving text
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor...'**
  String get saving;

  /// Share button
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// Undo button
  ///
  /// In tr, this message translates to:
  /// **'Geri Al'**
  String get undo;

  /// Redo button
  ///
  /// In tr, this message translates to:
  /// **'İleri Al'**
  String get redo;

  /// Clear button
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  /// Fullscreen button
  ///
  /// In tr, this message translates to:
  /// **'Tam Ekran'**
  String get fullscreen;

  /// Exit fullscreen button
  ///
  /// In tr, this message translates to:
  /// **'Tam Ekrandan Çık'**
  String get exitFullscreen;

  /// Fill tool
  ///
  /// In tr, this message translates to:
  /// **'Doldur'**
  String get fill;

  /// Pencil tool
  ///
  /// In tr, this message translates to:
  /// **'Kalem'**
  String get pencil;

  /// Eraser tool
  ///
  /// In tr, this message translates to:
  /// **'Silgi'**
  String get eraser;

  /// Selected label
  ///
  /// In tr, this message translates to:
  /// **'Seçili'**
  String get selected;

  /// Select color dialog title
  ///
  /// In tr, this message translates to:
  /// **'Renk Seç'**
  String get selectColor;

  /// Cancel button
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// Select button
  ///
  /// In tr, this message translates to:
  /// **'Seç'**
  String get select;

  /// Paint texture title
  ///
  /// In tr, this message translates to:
  /// **'Boya Dokusu'**
  String get paintTexture;

  /// Paint texture description
  ///
  /// In tr, this message translates to:
  /// **'Boyanan alanların görünümünü seçin'**
  String get paintTextureDescription;

  /// No texture
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get textureNone;

  /// No texture description
  ///
  /// In tr, this message translates to:
  /// **'Düz ve pürüzsüz boyama'**
  String get textureNoneDesc;

  /// Canvas texture
  ///
  /// In tr, this message translates to:
  /// **'Tuval'**
  String get textureCanvas;

  /// Canvas texture description
  ///
  /// In tr, this message translates to:
  /// **'Gerçek tuval dokusu efekti'**
  String get textureCanvasDesc;

  /// Paper texture
  ///
  /// In tr, this message translates to:
  /// **'Kâğıt'**
  String get texturePaper;

  /// Paper texture description
  ///
  /// In tr, this message translates to:
  /// **'Kâğıt üzerine boya kalemi hissi'**
  String get texturePaperDesc;

  /// Watercolor texture
  ///
  /// In tr, this message translates to:
  /// **'Sulu Boya'**
  String get textureWatercolor;

  /// Watercolor texture description
  ///
  /// In tr, this message translates to:
  /// **'Sulu boya efekti'**
  String get textureWatercolorDesc;

  /// Hide panel button
  ///
  /// In tr, this message translates to:
  /// **'Gizle'**
  String get hide;

  /// Clear confirmation title
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clearConfirmTitle;

  /// Clear confirmation message
  ///
  /// In tr, this message translates to:
  /// **'Tüm boyamayı temizlemek istediğinize emin misiniz?'**
  String get clearConfirmMessage;

  /// Image saved message
  ///
  /// In tr, this message translates to:
  /// **'Resim kaydedildi!'**
  String get imageSaved;

  /// Image load error
  ///
  /// In tr, this message translates to:
  /// **'Resim yüklenemedi'**
  String get imageLoadError;

  /// Save error
  ///
  /// In tr, this message translates to:
  /// **'Kaydetme hatası'**
  String get saveError;

  /// Share error
  ///
  /// In tr, this message translates to:
  /// **'Paylaşma hatası'**
  String get shareError;

  /// WhatsApp
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// Instagram
  ///
  /// In tr, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// Reset view button
  ///
  /// In tr, this message translates to:
  /// **'Görünümü Sıfırla'**
  String get resetView;

  /// Language setting
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// Turkish language
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// English language
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get english;

  /// Select language dialog title
  ///
  /// In tr, this message translates to:
  /// **'Dil Seç'**
  String get selectLanguage;

  /// Sound effects setting
  ///
  /// In tr, this message translates to:
  /// **'Ses Efektleri'**
  String get soundEffects;

  /// Notifications setting
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// Rate app button
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Değerlendir'**
  String get rateApp;

  /// Privacy policy button
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// Terms of service button
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get termsOfService;

  /// About button
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// Version label
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get version;

  /// Pro label
  ///
  /// In tr, this message translates to:
  /// **'Pro'**
  String get pro;

  /// Pro features title
  ///
  /// In tr, this message translates to:
  /// **'Pro Özellikleri'**
  String get proFeatures;

  /// Unlimited images feature
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız Resim'**
  String get unlimitedImages;

  /// No ads feature
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız'**
  String get noAds;

  /// All categories feature
  ///
  /// In tr, this message translates to:
  /// **'Tüm Kategoriler'**
  String get allCategories;

  /// Buy pro button
  ///
  /// In tr, this message translates to:
  /// **'Pro Satın Al'**
  String get buyPro;

  /// Restore purchases button
  ///
  /// In tr, this message translates to:
  /// **'Satın Alımları Geri Yükle'**
  String get restorePurchases;

  /// Pro active label
  ///
  /// In tr, this message translates to:
  /// **'Pro Aktif'**
  String get proActive;

  /// Start coloring button
  ///
  /// In tr, this message translates to:
  /// **'Boyamaya Başla'**
  String get startColoring;

  /// Continue coloring button
  ///
  /// In tr, this message translates to:
  /// **'Boyamaya Devam Et'**
  String get continueColoring;

  /// Delete button
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// Delete confirmation title
  ///
  /// In tr, this message translates to:
  /// **'Eseri Sil'**
  String get deleteConfirmTitle;

  /// Delete confirmation message
  ///
  /// In tr, this message translates to:
  /// **'Bu eseri silmek istediğinize emin misiniz?'**
  String get deleteConfirmMessage;

  /// No artworks message
  ///
  /// In tr, this message translates to:
  /// **'Henüz eseriniz yok'**
  String get noArtworks;

  /// No artworks hint
  ///
  /// In tr, this message translates to:
  /// **'Bir resim boyayarak başlayabilirsiniz'**
  String get noArtworksHint;

  /// Recent artworks title
  ///
  /// In tr, this message translates to:
  /// **'Son Eserler'**
  String get recentArtworks;

  /// See all button
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör'**
  String get seeAll;

  /// Welcome message
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin!'**
  String get welcome;

  /// Welcome message description
  ///
  /// In tr, this message translates to:
  /// **'Boyamaya başlamak için bir kategori seç'**
  String get welcomeMessage;

  /// Import from gallery
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Yükle'**
  String get importFromGallery;

  /// Import from camera
  ///
  /// In tr, this message translates to:
  /// **'Kameradan Çek'**
  String get importFromCamera;

  /// Processing message
  ///
  /// In tr, this message translates to:
  /// **'İşleniyor...'**
  String get processing;

  /// Import success message
  ///
  /// In tr, this message translates to:
  /// **'Resim başarıyla yüklendi'**
  String get importSuccess;

  /// Import error message
  ///
  /// In tr, this message translates to:
  /// **'Resim yüklenemedi'**
  String get importError;

  /// Permission denied message
  ///
  /// In tr, this message translates to:
  /// **'İzin reddedildi'**
  String get permissionDenied;

  /// Camera permission message
  ///
  /// In tr, this message translates to:
  /// **'Kamera izni gerekli'**
  String get cameraPermission;

  /// Gallery permission message
  ///
  /// In tr, this message translates to:
  /// **'Galeri izni gerekli'**
  String get galleryPermission;

  /// OK button
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// Yes button
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No button
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// Loading message
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// Error title
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// Retry button
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// General settings section
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get general;

  /// Appearance settings section
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearance;

  /// Support settings section
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get support;

  /// Contact us button
  ///
  /// In tr, this message translates to:
  /// **'Bize Ulaşın'**
  String get contactUs;

  /// FAQ button
  ///
  /// In tr, this message translates to:
  /// **'Sıkça Sorulan Sorular'**
  String get faq;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Bitti'**
  String get done;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @marker.
  ///
  /// In tr, this message translates to:
  /// **'Keçeli kalem'**
  String get marker;

  /// No description provided for @brushSize.
  ///
  /// In tr, this message translates to:
  /// **'Fırça boyutu'**
  String get brushSize;

  /// No description provided for @importedPages.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflarım'**
  String get importedPages;

  /// No description provided for @gateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ebeveyn kontrolü'**
  String get gateTitle;

  /// No description provided for @gateInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için bu sayılara sırayla dokunun:'**
  String get gateInstruction;

  /// No description provided for @gateDigitWords.
  ///
  /// In tr, this message translates to:
  /// **'sıfır,bir,iki,üç,dört,beş,altı,yedi,sekiz,dokuz'**
  String get gateDigitWords;

  /// No description provided for @gateTryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Olmadı. Yeni sayılarla tekrar deneyin.'**
  String get gateTryAgain;

  /// No description provided for @parentsArea.
  ///
  /// In tr, this message translates to:
  /// **'Ebeveyn alanı'**
  String get parentsArea;

  /// No description provided for @parentsHint.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar, paylaşım ve silme yalnız buradan yapılır.'**
  String get parentsHint;

  /// No description provided for @ageMode.
  ///
  /// In tr, this message translates to:
  /// **'Mod'**
  String get ageMode;

  /// No description provided for @ageModeLittle.
  ///
  /// In tr, this message translates to:
  /// **'Minik (3–5 yaş)'**
  String get ageModeLittle;

  /// No description provided for @ageModeLittleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kocaman düğmeler, 8 renk, yakınlaştırma yok. Kalem çizginin dışına taşmaz.'**
  String get ageModeLittleDesc;

  /// No description provided for @ageModeBig.
  ///
  /// In tr, this message translates to:
  /// **'Büyük (6+ yaş)'**
  String get ageModeBig;

  /// No description provided for @ageModeBigDesc.
  ///
  /// In tr, this message translates to:
  /// **'16 renk, iki parmakla yakınlaştırma, fırça boyutları, ileri al.'**
  String get ageModeBigDesc;

  /// No description provided for @soundVolume.
  ///
  /// In tr, this message translates to:
  /// **'Ses seviyesi'**
  String get soundVolume;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @privacyPolicyText.
  ///
  /// In tr, this message translates to:
  /// **'Cobi Paint hiçbir kişisel veri toplamaz.\n\n• Hesap, reklam, analiz aracı ve internet bağlantısı yoktur.\n• Çocuğunuzun boyadığı resimler yalnız bu cihazda saklanır ve hiçbir sunucuya gönderilmez.\n• Bir resim yalnız siz ebeveyn kontrolünü geçip paylaşmayı seçtiğinizde, sistemin paylaşım menüsüyle ve sizin seçtiğiniz uygulamaya gönderilir.\n• Kayıtlı bir resmi Ebeveyn alanından silebilirsiniz. Uygulamayı silmek bütün resimleri siler.\n\nSorularınız için: muazcoban@icloud.com'**
  String get privacyPolicyText;

  /// No description provided for @guidedAccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çocuk uygulamada kalsın'**
  String get guidedAccessTitle;

  /// No description provided for @guidedAccessText.
  ///
  /// In tr, this message translates to:
  /// **'iPhone ve iPad\'de Rehberli Erişim\'i kullanabilirsiniz: Ayarlar > Erişilebilirlik > Rehberli Erişim\'i açın, sonra uygulama açıkken yan düğmeye üç kez basın. Android\'de Ayarlar > Güvenlik > Uygulama sabitleme\'yi kullanın.'**
  String get guidedAccessText;

  /// No description provided for @artworkOptions.
  ///
  /// In tr, this message translates to:
  /// **'Eser seçenekleri'**
  String get artworkOptions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
