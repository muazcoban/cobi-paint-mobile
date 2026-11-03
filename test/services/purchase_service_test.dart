import 'dart:async';

import 'package:cobi_paint_mobile/services/purchase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A store that delivers whatever the test tells it to.
class _FakeStore extends InAppPurchasePlatform {
  final controller = StreamController<List<PurchaseDetails>>.broadcast();
  final completed = <String>[];
  bool available = true;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => controller.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async => ProductDetailsResponse(
        productDetails: [
          for (final id in identifiers)
            ProductDetails(id: id, title: 'Full', description: 'All pages', price: '₺199,99', rawPrice: 199.99, currencyCode: 'TRY'),
        ],
        notFoundIDs: const [],
      );

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    deliver(purchaseParam.productDetails.id, PurchaseStatus.purchased);
    return true;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    deliver(PurchaseService.productId, PurchaseStatus.restored);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completed.add(purchase.productID);
  }

  void deliver(String productId, PurchaseStatus status) {
    controller.add([
      PurchaseDetails(
        productID: productId,
        verificationData: PurchaseVerificationData(localVerificationData: '', serverVerificationData: '', source: 'test'),
        transactionDate: '0',
        status: status,
      )..pendingCompletePurchase = true,
    ]);
  }
}

void main() {
  late _FakeStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = _FakeStore();
    PurchaseService.debugPlatform = store;
    await PurchaseService().reset();
  });

  tearDown(() async {
    await PurchaseService().reset();
    await store.controller.close();
  });

  test('the service stays off without the build flag', () {
    // This test binary is built without --dart-define=COBI_IAP=true.
    expect(PurchaseService.enabled, isFalse);
  });

  test('a delivered purchase unlocks, is saved and is completed', () async {
    final service = PurchaseService();
    await service.init();
    await service.listenForTesting();

    store.deliver(PurchaseService.productId, PurchaseStatus.purchased);
    await pumpEventQueue();

    expect(service.isFull.value, isTrue);
    expect(store.completed, [PurchaseService.productId]);
    expect((await SharedPreferences.getInstance()).getBool('full_version'), isTrue);
  });

  test('a restored purchase unlocks too; a pending one only waits', () async {
    final service = PurchaseService();
    await service.listenForTesting();

    store.deliver(PurchaseService.productId, PurchaseStatus.pending);
    await pumpEventQueue();
    expect(service.pending.value, isTrue);
    expect(service.isFull.value, isFalse);

    store.deliver(PurchaseService.productId, PurchaseStatus.restored);
    await pumpEventQueue();
    expect(service.isFull.value, isTrue);
    expect(service.pending.value, isFalse);
  });

  test('another product or an error changes nothing but is completed', () async {
    final service = PurchaseService();
    await service.listenForTesting();

    store.deliver('something.else', PurchaseStatus.purchased);
    store.deliver(PurchaseService.productId, PurchaseStatus.error);
    await pumpEventQueue();

    expect(service.isFull.value, isFalse);
    expect(store.completed, ['something.else', PurchaseService.productId]);
  });

  test('the saved entitlement survives a restart', () async {
    SharedPreferences.setMockInitialValues({'full_version': true});
    final service = PurchaseService();
    await service.listenForTesting(readSaved: true);
    expect(service.isFull.value, isTrue);
  });
}
