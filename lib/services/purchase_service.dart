import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The one-time Full Version unlock (a non-consumable product). Everything
/// commercial lives here and in FullVersionScreen, both behind the parental
/// gate; the child's screens never change with the purchase state.
///
/// Off unless the app is built with `--dart-define=COBI_IAP=true`, so a
/// build without store products keeps every page free. The store products
/// (id [productId]) must exist in App Store Connect and Play Console first.
class PurchaseService {
  PurchaseService._();

  static final PurchaseService _instance = PurchaseService._();

  factory PurchaseService() => _instance;

  static const bool enabled = bool.fromEnvironment('COBI_IAP');
  static const String productId = 'com.cobi.paint.full';
  static const String _prefsKey = 'full_version';

  /// True once the unlock was bought or restored on this device.
  final ValueNotifier<bool> isFull = ValueNotifier<bool>(false);

  /// A purchase waiting for a grown-up's approval (Ask to Buy); the app
  /// waits quietly and unlocks when the approval arrives.
  final ValueNotifier<bool> pending = ValueNotifier<bool>(false);

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// A fake store for tests; the real platform needs a device.
  @visibleForTesting
  static InAppPurchasePlatform? debugPlatform;

  InAppPurchasePlatform get _store {
    final fake = debugPlatform;
    if (fake != null) return fake;
    InAppPurchase.instance; // registers this OS's store plugin once
    return InAppPurchasePlatform.instance;
  }

  /// Reads the saved entitlement and starts listening for deliveries. Call
  /// before runApp so a purchase finished while the app was closed lands.
  Future<void> init() => enabled ? _start(readSaved: true) : Future<void>.value();

  /// Same as [init] without the build flag, for tests with a fake store.
  @visibleForTesting
  Future<void> listenForTesting({bool readSaved = false}) => _start(readSaved: readSaved);

  Future<void> _start({required bool readSaved}) async {
    if (readSaved) {
      final prefs = await SharedPreferences.getInstance();
      isFull.value = prefs.getBool(_prefsKey) ?? false;
    }
    _subscription ??= _store.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) => debugPrint('Purchase stream error: $e'),
    );
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == productId) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            await _grant();
            pending.value = false;
          case PurchaseStatus.pending:
            pending.value = true;
          case PurchaseStatus.error:
          case PurchaseStatus.canceled:
            pending.value = false;
        }
      }
      if (purchase.pendingCompletePurchase) await _store.completePurchase(purchase);
    }
  }

  Future<void> _grant() async {
    isFull.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  /// The product with its localised store price, or null when the store is
  /// unreachable or the product is not set up yet.
  Future<ProductDetails?> loadProduct() async {
    if (!enabled || !await _store.isAvailable()) return null;
    final response = await _store.queryProductDetails({productId});
    return response.productDetails.isEmpty ? null : response.productDetails.first;
  }

  Future<bool> buy(ProductDetails product) =>
      _store.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));

  Future<void> restore() => _store.restorePurchases();

  @visibleForTesting
  Future<void> reset() async {
    await _subscription?.cancel();
    _subscription = null;
    isFull.value = false;
    pending.value = false;
  }
}
