import 'dart:async';
import 'dart:io';

import 'package:cobi_paint_mobile/data/builtin_scenes.dart';
import 'package:cobi_paint_mobile/l10n/app_localizations.dart';
import 'package:cobi_paint_mobile/main.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/screens/full_version_screen.dart';
import 'package:cobi_paint_mobile/screens/home_screen.dart';
import 'package:cobi_paint_mobile/screens/parents_screen.dart';
import 'package:cobi_paint_mobile/screens/scene_screen.dart';
import 'package:cobi_paint_mobile/services/sound_service.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:cobi_paint_mobile/theme/app_theme.dart';
import 'package:cobi_paint_mobile/widgets/kid_button.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The system text size at its largest on the smallest supported phone,
/// 375 x 667 pt. The app caps text at 200% (main.dart), so the app's screens
/// are checked at the size a grown-up actually gets; the Full Version screen
/// is pumped without the cap, at 3.1 times. Every screen lays out without
/// overflow (a Flutter error, so it fails the test where it happens) and
/// no text is cut off with an ellipsis.
void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.disabled = true;
    dir = Directory.systemTemp.createTempSync('cobi_large_text_test');
  });

  tearDown(() => dir.deleteSync(recursive: true));

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

  void smallPhoneLargestText(WidgetTester tester) {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(750, 1334);
    tester.platformDispatcher.textScaleFactorTestValue = 3.12;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<AppProvider> openHome(WidgetTester tester) async {
    final app = provider();
    await tester.pumpWidget(CobiPaintApp(app: app));
    await settle(tester, () => app.isInitialized, reason: 'the provider read its folders');
    await settle(tester, () => find.byType(HomeScreen).evaluate().isNotEmpty, reason: 'the home screen');
    await tester.pumpAndSettle();
    return app;
  }

  /// No text on screen is cut off with an ellipsis or by a line limit.
  void expectWholeTexts(WidgetTester tester, String screen) {
    for (final element in find.byType(RichText).evaluate()) {
      final paragraph = element.renderObject! as RenderParagraph;
      expect(paragraph.didExceedMaxLines, isFalse, reason: '$screen: "${paragraph.text.toPlainText()}" is cut off');
    }
  }

  Future<void> scrollThrough(WidgetTester tester, Finder scrollable, String screen) async {
    expectWholeTexts(tester, screen);
    for (var i = 0; i < 12; i++) {
      await tester.drag(scrollable, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$screen, scrolled ${i + 1} times');
      expectWholeTexts(tester, '$screen, scrolled ${i + 1} times');
    }
  }

  /// A page goes back to its category; the category's home button then
  /// goes home.
  Future<void> goHome(WidgetTester tester) async {
    for (var i = 0; i < 3 && find.byType(HomeScreen).hitTestable().evaluate().isEmpty; i++) {
      await tester.tap(find.bySemanticsLabel('Home').first);
      await settle(tester, () => find.bySemanticsLabel('Home').evaluate().isEmpty || find.byType(PaintCanvas).evaluate().isEmpty,
          reason: 'left the page');
      await tester.pumpAndSettle();
    }
    expect(find.byType(HomeScreen).hitTestable(), findsOneWidget, reason: 'back home');
  }

  testWidgets('a child\'s screens: home, a category, a page, the Draw page and the scene', (tester) async {
    smallPhoneLargestText(tester);
    await openHome(tester);
    expect(tester.takeException(), isNull, reason: 'home');
    await scrollThrough(tester, find.byType(CustomScrollView).first, 'home');
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, 6000));
    await tester.pumpAndSettle();

    // The grid builds only the cards on screen.
    await tester.scrollUntilVisible(find.text('Food'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'a category');
    await scrollThrough(tester, find.byType(Scrollable).first, 'a category');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 6000));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PressableCard).hitTestable().first);
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the page loaded');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'a coloring page');
    await goHome(tester);

    await tester.scrollUntilVisible(find.text('Draw'), -200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the Draw page');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'the Draw page');
    await goHome(tester);

    unawaited(Navigator.of(tester.element(find.byType(HomeScreen)))
        .push(MaterialPageRoute<void>(builder: (_) => const SceneScreen(scene: gardenScene))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'the scene');
  });

  testWidgets('a grown-up\'s screens: the gate, the parents area, My Artworks, its sheet and the delete dialog',
      (tester) async {
    smallPhoneLargestText(tester);
    final app = await openHome(tester);

    // A picture for My Artworks first.
    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the Draw page');
    await tester.timedDrag(find.byType(PaintCanvas), const Offset(90, 70), const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 500));
    await settle(tester, () => app.savedArtworks.isNotEmpty, reason: 'autosave wrote the picture');
    await goHome(tester);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('gate-task')), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'the parental gate');
    final task = tester.widget<Text>(find.byKey(const ValueKey('gate-task'))).data!;
    final parts = task.split(' × ');
    final product = int.parse(parts[0]) * int.parse(parts[1].split(' ').first);
    for (final d in product.toString().split('')) {
      await tester.ensureVisible(find.byKey(ValueKey('gate-digit-$d')));
      await tester.tap(find.byKey(ValueKey('gate-digit-$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.byType(ParentsScreen), findsOneWidget, reason: 'the gate opened');
    expect(tester.takeException(), isNull, reason: 'the parents area');
    await scrollThrough(tester, find.byType(Scrollable).first, 'the parents area');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, 6000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Artworks'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'My Artworks');

    const channel = MethodChannel('cobi.paint/export');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      return switch (call.method) {
        'capabilities' => {'gallery': true, 'print': true},
        _ => null,
      };
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
    await tester.longPress(find.bySemanticsLabel(app.pagesById[app.savedArtworks.single.originalImageId]!.localizedName('en')));
    await tester.pumpAndSettle();
    final sheetTask = tester.widget<Text>(find.byKey(const ValueKey('gate-task'))).data!;
    final sheetParts = sheetTask.split(' × ');
    final sheetProduct = int.parse(sheetParts[0]) * int.parse(sheetParts[1].split(' ').first);
    for (final d in sheetProduct.toString().split('')) {
      await tester.ensureVisible(find.byKey(ValueKey('gate-digit-$d')));
      await tester.tap(find.byKey(ValueKey('gate-digit-$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget, reason: 'the grown-up sheet is open');
    expect(tester.takeException(), isNull, reason: 'the artwork sheet');
    await tester.ensureVisible(find.text('Delete'));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'the delete dialog');
  });

  testWidgets('the Full Version screen', (tester) async {
    smallPhoneLargestText(tester);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const FullVersionScreen(),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'the Full Version screen');
    await scrollThrough(tester, find.byType(Scrollable).first, 'the Full Version screen');
  });
}
