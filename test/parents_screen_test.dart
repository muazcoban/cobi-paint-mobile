import 'package:cobi_paint_mobile/l10n/app_localizations.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/providers/locale_provider.dart';
import 'package:cobi_paint_mobile/screens/parents_screen.dart';
import 'package:cobi_paint_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyScreen), findsOneWidget);
    final text = tester.widget<SelectableText>(find.byType(SelectableText).first).data!;
    expect(text, contains('cobipaint@gmail.com'));
    expect(text, isNot(contains('Full Version')), reason: 'COBI_IAP is off in tests');
    expect(text, isNot(contains('purchase')));
  });

  testWidgets('theme names follow the app language', (tester) async {
    await pumpParents(tester, 'en');
    await tester.scrollUntilVisible(find.text('Sunset'), 200);

    expect(find.text('Sunset'), findsOneWidget);
    expect(find.text('Gün Batımı'), findsNothing);
  });
}
