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
    Locale('tr')
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
  /// **'Doga'**
  String get nature;

  /// Food category
  ///
  /// In tr, this message translates to:
  /// **'Yiyecekler'**
  String get food;

  /// Import image button
  ///
  /// In tr, this message translates to:
  /// **'Resim Yukle'**
  String get importImage;

  /// Go pro button
  ///
  /// In tr, this message translates to:
  /// **'Pro\'ya Gec'**
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
  /// **'Paylas'**
  String get share;

  /// Undo button
  ///
  /// In tr, this message translates to:
  /// **'Geri Al'**
  String get undo;

  /// Redo button
  ///
  /// In tr, this message translates to:
  /// **'Ileri Al'**
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
  /// **'Tam Ekrandan Cik'**
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
  /// **'Secili'**
  String get selected;

  /// Select color dialog title
  ///
  /// In tr, this message translates to:
  /// **'Renk Sec'**
  String get selectColor;

  /// Cancel button
  ///
  /// In tr, this message translates to:
  /// **'Iptal'**
  String get cancel;

  /// Select button
  ///
  /// In tr, this message translates to:
  /// **'Sec'**
  String get select;

  /// Paint texture title
  ///
  /// In tr, this message translates to:
  /// **'Boya Dokusu'**
  String get paintTexture;

  /// Paint texture description
  ///
  /// In tr, this message translates to:
  /// **'Boyanan alanlarin gorunumunu secin'**
  String get paintTextureDescription;

  /// No texture
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get textureNone;

  /// No texture description
  ///
  /// In tr, this message translates to:
  /// **'Duz ve puruzsuz boyama'**
  String get textureNoneDesc;

  /// Canvas texture
  ///
  /// In tr, this message translates to:
  /// **'Tuval'**
  String get textureCanvas;

  /// Canvas texture description
  ///
  /// In tr, this message translates to:
  /// **'Gercek tuval dokusu efekti'**
  String get textureCanvasDesc;

  /// Paper texture
  ///
  /// In tr, this message translates to:
  /// **'Kagit'**
  String get texturePaper;

  /// Paper texture description
  ///
  /// In tr, this message translates to:
  /// **'Kagit uzerine boya kalemi hissi'**
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
  /// **'Tum boyamayi temizlemek istediginize emin misiniz?'**
  String get clearConfirmMessage;

  /// Image saved message
  ///
  /// In tr, this message translates to:
  /// **'Resim kaydedildi!'**
  String get imageSaved;

  /// Image load error
  ///
  /// In tr, this message translates to:
  /// **'Resim yuklenemedi'**
  String get imageLoadError;

  /// Save error
  ///
  /// In tr, this message translates to:
  /// **'Kaydetme hatasi'**
  String get saveError;

  /// Share error
  ///
  /// In tr, this message translates to:
  /// **'Paylasma hatasi'**
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
  /// **'Gorunumu Sifirla'**
  String get resetView;

  /// Language setting
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// Turkish language
  ///
  /// In tr, this message translates to:
  /// **'Turkce'**
  String get turkish;

  /// English language
  ///
  /// In tr, this message translates to:
  /// **'Ingilizce'**
  String get english;

  /// Select language dialog title
  ///
  /// In tr, this message translates to:
  /// **'Dil Sec'**
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
  /// **'Uygulamayi Degerlendir'**
  String get rateApp;

  /// Privacy policy button
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikasi'**
  String get privacyPolicy;

  /// Terms of service button
  ///
  /// In tr, this message translates to:
  /// **'Kullanim Kosullari'**
  String get termsOfService;

  /// About button
  ///
  /// In tr, this message translates to:
  /// **'Hakkinda'**
  String get about;

  /// Version label
  ///
  /// In tr, this message translates to:
  /// **'Surum'**
  String get version;

  /// Pro label
  ///
  /// In tr, this message translates to:
  /// **'Pro'**
  String get pro;

  /// Pro features title
  ///
  /// In tr, this message translates to:
  /// **'Pro Ozellikleri'**
  String get proFeatures;

  /// Unlimited images feature
  ///
  /// In tr, this message translates to:
  /// **'Sinirsiz Resim'**
  String get unlimitedImages;

  /// No ads feature
  ///
  /// In tr, this message translates to:
  /// **'Reklamsiz'**
  String get noAds;

  /// All categories feature
  ///
  /// In tr, this message translates to:
  /// **'Tum Kategoriler'**
  String get allCategories;

  /// Buy pro button
  ///
  /// In tr, this message translates to:
  /// **'Pro Satin Al'**
  String get buyPro;

  /// Restore purchases button
  ///
  /// In tr, this message translates to:
  /// **'Satin Alimlari Geri Yukle'**
  String get restorePurchases;

  /// Pro active label
  ///
  /// In tr, this message translates to:
  /// **'Pro Aktif'**
  String get proActive;

  /// Start coloring button
  ///
  /// In tr, this message translates to:
  /// **'Boyamaya Basla'**
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
  /// **'Bu eseri silmek istediginize emin misiniz?'**
  String get deleteConfirmMessage;

  /// No artworks message
  ///
  /// In tr, this message translates to:
  /// **'Henuz eseriniz yok'**
  String get noArtworks;

  /// No artworks hint
  ///
  /// In tr, this message translates to:
  /// **'Bir resim boyayarak baslayabilirsiniz'**
  String get noArtworksHint;

  /// Recent artworks title
  ///
  /// In tr, this message translates to:
  /// **'Son Eserler'**
  String get recentArtworks;

  /// See all button
  ///
  /// In tr, this message translates to:
  /// **'Tumunu Gor'**
  String get seeAll;

  /// Welcome message
  ///
  /// In tr, this message translates to:
  /// **'Hosgeldin!'**
  String get welcome;

  /// Welcome message description
  ///
  /// In tr, this message translates to:
  /// **'Boyamaya baslamak icin bir kategori sec'**
  String get welcomeMessage;

  /// Import from gallery
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Yukle'**
  String get importFromGallery;

  /// Import from camera
  ///
  /// In tr, this message translates to:
  /// **'Kameradan Cek'**
  String get importFromCamera;

  /// Processing message
  ///
  /// In tr, this message translates to:
  /// **'Isleniyor...'**
  String get processing;

  /// Import success message
  ///
  /// In tr, this message translates to:
  /// **'Resim basariyla yuklendi'**
  String get importSuccess;

  /// Import error message
  ///
  /// In tr, this message translates to:
  /// **'Resim yuklenemedi'**
  String get importError;

  /// Permission denied message
  ///
  /// In tr, this message translates to:
  /// **'Izin reddedildi'**
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
  /// **'Hayir'**
  String get no;

  /// Loading message
  ///
  /// In tr, this message translates to:
  /// **'Yukleniyor...'**
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
  /// **'Gorunum'**
  String get appearance;

  /// Support settings section
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get support;

  /// Contact us button
  ///
  /// In tr, this message translates to:
  /// **'Bize Ulasin'**
  String get contactUs;

  /// FAQ button
  ///
  /// In tr, this message translates to:
  /// **'Sikca Sorulan Sorular'**
  String get faq;
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
      'that was used.');
}
