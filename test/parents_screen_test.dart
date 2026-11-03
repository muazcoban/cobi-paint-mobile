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

  testWidgets('theme names follow the app language', (tester) async {
    await pumpParents(tester, 'en');
    await tester.scrollUntilVisible(find.text('Sunset'), 200);

    expect(find.text('Sunset'), findsOneWidget);
    expect(find.text('Gün Batımı'), findsNothing);
  });
}
