import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService extends ChangeNotifier {
  static const String proSubscriptionId = 'cobi_paint_pro_monthly';
  static const String proLifetimeId = 'cobi_paint_pro_lifetime';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _available = false;
  bool _isPro = false;
  bool _loading = false;
  List<ProductDetails> _products = [];
  String? _error;

  bool get available => _available;
  bool get isPro => _isPro;
  bool get loading => _loading;
  List<ProductDetails> get products => _products;
  String? get error => _error;

  Future<void> init() async {
    _available = await _inAppPurchase.isAvailable();
    if (!_available) {
      _error = 'Store not available';
      notifyListeners();
      return;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _onDone,
      onError: _onError,
    );

    // Load products
    await loadProducts();

    // Restore purchases
    await restorePurchases();
  }

  Future<void> loadProducts() async {
    if (!_available) return;

    _loading = true;
    notifyListeners();

    try {
      final Set<String> ids = {proSubscriptionId, proLifetimeId};
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(ids);

      if (response.error != null) {
        _error = response.error!.message;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    if (!_available) return;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> buyPro({bool lifetime = false}) async {
    if (!_available) {
      _error = 'Store not available';
      notifyListeners();
      return false;
    }

    final productId = lifetime ? proLifetimeId : proSubscriptionId;
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found'),
    );

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      if (lifetime) {
        return await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      } else {
        return await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        _loading = true;
        notifyListeners();
      } else {
        _loading = false;

        if (purchase.status == PurchaseStatus.error) {
          _error = purchase.error?.message ?? 'Purchase error';
        } else if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          // Verify purchase and grant pro
          _verifyAndGrant(purchase);
        }

        if (purchase.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchase);
        }

        notifyListeners();
      }
    }
  }

  Future<void> _verifyAndGrant(PurchaseDetails purchase) async {
    // In production, verify with your server
    // For now, trust the purchase
    if (purchase.productID == proSubscriptionId ||
        purchase.productID == proLifetimeId) {
      _isPro = true;
      notifyListeners();
    }
  }

  void _onDone() {
    _subscription?.cancel();
  }

  void _onError(dynamic error) {
    _error = error.toString();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
