import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob reklam yonetim servisi
/// COPPA uyumlu - cocuk uygulamasi icin yapilandirilmis
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;

  // Test Ad Unit ID'leri (Gelistirme icin)
  static const String _testBannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIdIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIdIos = 'ca-app-pub-3940256099942544/4411468910';

  // Production Ad Unit ID'leri (iOS - AdMob konsolundan)
  // Banner: ca-app-pub-5547492389514605/1971749064
  // Interstitial: ca-app-pub-5547492389514605/3569554155
  static const String _prodBannerIdAndroid = 'ca-app-pub-5547492389514605/1971749064';
  static const String _prodBannerIdIos = 'ca-app-pub-5547492389514605/1971749064';
  static const String _prodInterstitialIdAndroid = 'ca-app-pub-5547492389514605/3569554155';
  static const String _prodInterstitialIdIos = 'ca-app-pub-5547492389514605/3569554155';

  /// Banner reklam yuklendi mi?
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  /// Interstitial reklam yuklendi mi?
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  /// Yuklenmis banner reklam
  BannerAd? get bannerAd => _bannerAd;

  /// Platform ve mod'a gore banner Ad Unit ID
  String get _bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testBannerIdAndroid : _testBannerIdIos;
    }
    return Platform.isAndroid ? _prodBannerIdAndroid : _prodBannerIdIos;
  }

  /// Platform ve mod'a gore interstitial Ad Unit ID
  String get _interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testInterstitialIdAndroid : _testInterstitialIdIos;
    }
    return Platform.isAndroid ? _prodInterstitialIdAndroid : _prodInterstitialIdIos;
  }

  /// AdMob'u baslatir - COPPA uyumlu yapilandirma ile
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // COPPA uyumlulugu - cocuk uygulamasi icin ZORUNLU
      final requestConfiguration = RequestConfiguration(
        // Cocuklara yonelik icerik
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        // En dusuk icerik siniflandirmasi (G - Genel Izleyici)
        maxAdContentRating: MaxAdContentRating.g,
        // Yas altinda kullanici tedavisi
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
      );

      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      await MobileAds.instance.initialize();

      _isInitialized = true;
      debugPrint('AdService: AdMob basariyla baslatildi (COPPA uyumlu)');
    } catch (e) {
      debugPrint('AdService: AdMob baslatilamadi - $e');
    }
  }

  /// Banner reklam yukler
  Future<void> loadBannerAd({Function? onAdLoaded, Function? onAdFailed}) async {
    if (!_isInitialized) {
      debugPrint('AdService: AdMob henuz baslatilmadi');
      return;
    }

    // Onceki banner'i temizle
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdService: Banner reklam yuklendi');
          _isBannerAdLoaded = true;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: Banner reklam yuklenemedi - ${error.message}');
          ad.dispose();
          _bannerAd = null;
          _isBannerAdLoaded = false;
          onAdFailed?.call();
        },
        onAdOpened: (ad) {
          debugPrint('AdService: Banner reklam acildi');
        },
        onAdClosed: (ad) {
          debugPrint('AdService: Banner reklam kapandi');
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// Interstitial (video) reklam yukler
  Future<void> loadInterstitialAd({Function? onAdLoaded, Function? onAdFailed}) async {
    if (!_isInitialized) {
      debugPrint('AdService: AdMob henuz baslatilmadi');
      return;
    }

    // Zaten yuklenmis reklam varsa tekrar yukleme
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      debugPrint('AdService: Interstitial zaten yuklenmis');
      return;
    }

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: Interstitial reklam yuklendi');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          onAdLoaded?.call();

          // Reklam kapandiginda yeni reklam yukle
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('AdService: Interstitial reklam kapandi');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              // Otomatik olarak yeni reklam yukle
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdService: Interstitial gosterilemedi - ${error.message}');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Interstitial yuklenemedi - ${error.message}');
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          onAdFailed?.call();
        },
      ),
    );
  }

  /// Interstitial reklami gosterir
  /// [onAdShown] - Reklam gosterildikten sonra cagrilir
  /// [onAdNotReady] - Reklam hazir degilse cagrilir
  Future<void> showInterstitialAd({
    Function? onAdShown,
    Function? onAdNotReady,
  }) async {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      await _interstitialAd!.show();
      onAdShown?.call();
    } else {
      debugPrint('AdService: Interstitial reklam hazir degil');
      onAdNotReady?.call();
      // Reklam hazir degilse yuklemeyi baslat
      loadInterstitialAd();
    }
  }

  /// Banner reklami temizler
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  /// Tum reklamlari temizler
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoaded = false;
  }
}
