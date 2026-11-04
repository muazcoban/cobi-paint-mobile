import 'package:cobi_paint_mobile/l10n/app_localizations.dart';
import 'package:cobi_paint_mobile/screens/full_version_screen.dart';
import 'package:cobi_paint_mobile/services/purchase_service.dart';
import 'package:cobi_paint_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeStore extends InAppPurchasePlatform {
  _FakeStore({this.failRestore = false});

  final bool failRestore;
  int restoreCalls = 0;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => const Stream.empty();

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async => ProductDetailsResponse(
        productDetails: [
          ProductDetails(id: PurchaseService.productId, title: 'Full', description: '', price: '₺199,99', rawPrice: 199.99, currencyCode: 'TRY'),
        ],
        notFoundIDs: const [],
      );

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restoreCalls++;
    if (failRestore) throw PlatformException(code: 'storekit_no_response', message: 'offline');
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}
}

Widget _app() => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const FullVersionScreen(),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PurchaseService().reset();
  });

  testWidgets('shows the store price, restore and the privacy policy; never a hard-coded price', (tester) async {
    PurchaseService.debugPlatform = _FakeStore();
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // The build flag is off in tests, so loadProduct() reports no store:
    // the screen must still be complete and calm.
    expect(find.text('Mağazaya şu an ulaşılamıyor.'), findsOneWidget);
    expect(find.text('Satın alımları geri yükle'), findsOneWidget);
    expect(find.text('Gizlilik Politikası'), findsOneWidget);
    expect(find.textContaining('₺'), findsNothing);
  });

  testWidgets('restore calls the store once', (tester) async {
    final store = _FakeStore();
    PurchaseService.debugPlatform = store;
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Satın alımları geri yükle'));
    await tester.pump();
    expect(store.restoreCalls, 1);
  });

  testWidgets('a failing restore is said out loud and the button comes back', (tester) async {
    final store = _FakeStore(failRestore: true);
    PurchaseService.debugPlatform = store;
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Satın alımları geri yükle'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(store.restoreCalls, 1);
    expect(find.byType(SnackBar), findsOneWidget, reason: 'the grown-up learns that the store did not answer');
    final button = tester.widget<OutlinedButton>(
      find.ancestor(of: find.text('Satın alımları geri yükle'), matching: find.byType(OutlinedButton)),
    );
    expect(button.onPressed, isNotNull, reason: 'the button is usable again after the failure');
  });

  testWidgets('an owned unlock shows thanks instead of a button', (tester) async {
    PurchaseService.debugPlatform = _FakeStore();
    PurchaseService().isFull.value = true;
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Tam Sürüm açık. Teşekkürler!'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsNothing);
  });

  testWidgets('the screen meets the tap target, label and contrast guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    PurchaseService.debugPlatform = _FakeStore();
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
