import 'dart:io';

import 'package:cobi_paint_mobile/main.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/screens/home_screen.dart';
import 'package:cobi_paint_mobile/services/sound_service.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:cobi_paint_mobile/theme/app_theme.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The theme a grown-up picks in the Parents area colours the whole app,
/// not only the Parents area: the child's screens take its page colour.
void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.disabled = true;
    AppTheme.setTheme('coral');
    dir = Directory.systemTemp.createTempSync('cobi_theme_test');
  });

  tearDown(() {
    AppTheme.setTheme('coral');
    dir.deleteSync(recursive: true);
  });

  AppProvider provider() => AppProvider(
        storage: StorageService(documentsDirectory: () async => Directory('${dir.path}/docs')..createSync()),
        cacheDirectory: () async => Directory('${dir.path}/cache')..createSync(),
      );

  Future<void> settle(WidgetTester tester, bool Function() done, {String reason = 'in time', int rounds = 240}) async {
    for (var i = 0; i < rounds && !done(); i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(done(), isTrue, reason: reason);
  }

  Color homeBackground(WidgetTester tester) =>
      tester.widget<Scaffold>(find.descendant(of: find.byType(HomeScreen), matching: find.byType(Scaffold))).backgroundColor!;

  testWidgets('the Parents theme colours the home and coloring screens, and comes back after a restart', (tester) async {
    final app = provider();
    await tester.pumpWidget(CobiPaintApp(app: app));
    await settle(tester, () => app.isInitialized, reason: 'the provider read its folders');
    await settle(tester, () => find.text('Animals').evaluate().isNotEmpty, reason: 'home screen');
    await tester.pumpAndSettle();
    expect(homeBackground(tester), AppTheme.themes['coral']!.background);

    // What the theme chip in the Parents area does.
    AppTheme.setTheme('ocean');
    await app.updateSettings(app.settings.copyWith(selectedTheme: 'ocean'));
    await tester.pumpAndSettle();
    expect(homeBackground(tester), AppTheme.themes['ocean']!.background, reason: 'the home screen follows');

    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the blank page loaded');
    await tester.pumpAndSettle();
    final coloring = tester.widget<Scaffold>(find.byType(Scaffold).last);
    expect(coloring.backgroundColor, AppTheme.themes['ocean']!.background, reason: 'the coloring screen follows');

    // A fresh provider on the same storage reads the saved choice and
    // applies it before the first frame.
    AppTheme.setTheme('coral');
    final again = provider();
    await tester.runAsync(again.init);
    expect(again.settings.selectedTheme, 'ocean');
    expect(AppTheme.currentTheme, 'ocean', reason: 'init applies the saved theme');
  });
}
