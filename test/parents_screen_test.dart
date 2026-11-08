import 'dart:io';

import 'package:cobi_paint_mobile/l10n/app_localizations.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/providers/locale_provider.dart';
import 'package:cobi_paint_mobile/screens/parents_screen.dart';
import 'package:cobi_paint_mobile/services/rating_prompt.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:cobi_paint_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CountingStoreReview implements StoreReview {
  int requests = 0;
  int listings = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> requestReview() async => requests++;

  @override
  Future<void> openStoreListing() async => listings++;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpParents(WidgetTester tester, String language) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ParentsScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the parents area meets the tap target, label and contrast guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpParents(tester, 'en');

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('the hint sends sharing, printing and deleting to My Artworks', (tester) async {
    await pumpParents(tester, 'en');
    expect(find.textContaining('press and hold it in My Artworks'), findsOneWidget);
    expect(find.textContaining('sharing and deleting live here'), findsNothing);
  });

  testWidgets('the spoken-names switch stays hidden while no clips are bundled', (tester) async {
    await pumpParents(tester, 'en');
    // The asset manifest is read on the real event loop.
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    // The list is lazy: bring the switches into view before looking.
    // The contact e-mail is a SelectableText with a scrollable of its own, so the list is named.
    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Vibration'), 200, scrollable: list);
    await tester.pumpAndSettle();
    expect(find.text('Vibration'), findsOneWidget, reason: 'the other switches stay');
    await tester.scrollUntilVisible(find.text('Keep your child in the app'), 100, scrollable: list);
    await tester.pumpAndSettle();
    expect(find.text('Spoken names'), findsNothing, reason: 'a switch that changes nothing would mislead');
  });

  testWidgets('the privacy text has no purchase paragraph in a build without the Full Version', (tester) async {
    await pumpParents(tester, 'en');
    // The list is lazy: the row exists a little before it is on screen.
    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyScreen), findsOneWidget);
    final text = tester.widget<SelectableText>(find.byType(SelectableText).first).data!;
    expect(text, contains('cobipaint@gmail.com'));
    expect(text, isNot(contains('Full Version')), reason: 'COBI_IAP is off in tests');
    expect(text, isNot(contains('purchase')));
  });

  testWidgets('the auto-complete switch is on by default and turns off', (tester) async {
    final dir = Directory.systemTemp.createTempSync('cobi_parents_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final app = AppProvider(
      storage: StorageService(documentsDirectory: () async => Directory('${dir.path}/docs')..createSync()),
      cacheDirectory: () async => Directory('${dir.path}/cache')..createSync(),
    );
    await tester.runAsync(app.init);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: app),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ParentsScreen(),
        ),
      ),
    );
    await tester.pump();
    final title = find.text('Fill small gaps when colouring with the brush');
    await tester.scrollUntilVisible(title, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    final tile = find.ancestor(of: title, matching: find.byType(SwitchListTile));
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);
    await tester.tap(tile);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(app.settings.autoComplete, isFalse);
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
  });

  testWidgets('the About section has a rate row that opens the store listing', (tester) async {
    final dir = Directory.systemTemp.createTempSync('cobi_parents_rate_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final store = _CountingStoreReview();
    final app = AppProvider(
      storage: StorageService(documentsDirectory: () async => Directory('${dir.path}/docs')..createSync()),
      cacheDirectory: () async => Directory('${dir.path}/cache')..createSync(),
      storeReview: store,
    );
    await tester.runAsync(app.init);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: app),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ParentsScreen(),
        ),
      ),
    );
    await tester.pump();
    final row = find.text('Rate the app');
    await tester.scrollUntilVisible(row, 200, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    expect(find.text('Opens the app store'), findsOneWidget, reason: 'the row says it leaves the app');
    await tester.tap(row);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    expect(store.listings, 1);
    expect(store.requests, 0, reason: 'the Parents row never shows the rating sheet itself');
  });

  testWidgets('theme names follow the app language', (tester) async {
    await pumpParents(tester, 'en');
    await tester.scrollUntilVisible(find.text('Sunset'), 200);

    expect(find.text('Sunset'), findsOneWidget);
    expect(find.text('Gün Batımı'), findsNothing);
  });
}
