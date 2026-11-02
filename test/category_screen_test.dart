import 'package:cobi_paint_mobile/l10n/app_localizations.dart';
import 'package:cobi_paint_mobile/models/category.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/screens/category_screen.dart';
import 'package:cobi_paint_mobile/theme/app_theme.dart';
import 'package:cobi_paint_mobile/widgets/kid_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final animals = Category.getDefaultCategories().firstWhere((c) => c.id == 'animals');

  Future<void> pumpCategory(WidgetTester tester) async {
    // Built-in pages need no storage, so the provider works without init()
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CategoryScreen(category: animals),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the category and its page pictures', (tester) async {
    await pumpCategory(tester);

    expect(find.text('Hayvanlar'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.byType(KidButton), findsOneWidget, reason: 'one big home button');
  });

  testWidgets('page tiles and the home button meet the tap target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCategory(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    // VoiceOver/TalkBack users hear a name for every tile and button.
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
