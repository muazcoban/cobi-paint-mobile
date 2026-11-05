import 'dart:io';

import 'package:cobi_paint_mobile/main.dart';
import 'package:cobi_paint_mobile/models/user_settings.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/screens/category_screen.dart';
import 'package:cobi_paint_mobile/services/sound_service.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:cobi_paint_mobile/widgets/kid_button.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Apple HIG and App Review 4.0 checks on the screens a child and a grown-up
/// actually reach: 44 pt targets, a label on every target, 4.5:1 text
/// contrast, and layouts that survive an iPad and a narrow Split View pane.
/// The flows mirror app_test.dart: real screens, engine and storage in a
/// temporary folder.
void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.disabled = true;
    dir = Directory.systemTemp.createTempSync('cobi_a11y_test');
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

  Future<void> openHome(WidgetTester tester, AppProvider app) async {
    await tester.pumpWidget(CobiPaintApp(app: app));
    await settle(tester, () => app.isInitialized, reason: 'the provider read its folders');
    await settle(tester, () => find.text('Animals').evaluate().isNotEmpty, reason: 'the splash went to the home screen');
    await tester.pumpAndSettle();
  }

  Future<void> openDraw(WidgetTester tester) async {
    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the blank page loaded');
    await tester.pumpAndSettle();
  }

  Future<void> expectGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  // A long press asks the multiplication; the answer is read off the screen.
  Future<void> passGate(WidgetTester tester, Finder target) async {
    await tester.longPress(target);
    await tester.pumpAndSettle();
    final task = tester.widget<Text>(find.byKey(const ValueKey('gate-task'))).data!;
    final parts = task.split(' × ');
    final product = int.parse(parts[0]) * int.parse(parts[1].split(' ').first);
    for (final d in product.toString().split('')) {
      await tester.tap(find.byKey(ValueKey('gate-digit-$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('the home screen meets the iOS tap target, label and contrast guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    final app = provider();
    await openHome(tester, app);

    await expectGuidelines(tester);
    handle.dispose();
  });

  testWidgets('My Artworks, its options sheet and the delete dialog meet the guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    final app = provider();
    await openHome(tester, app);
    await openDraw(tester);
    await tester.timedDrag(find.byType(PaintCanvas), const Offset(90, 70), const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 500));
    await settle(tester, () => app.savedArtworks.isNotEmpty, reason: 'autosave wrote the picture');
    await tester.tap(find.bySemanticsLabel('Home'));
    await settle(tester, () => find.text('Animals').evaluate().isNotEmpty, reason: 'back on the home screen');
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Artworks'));
    await tester.pumpAndSettle();
    final saved = app.savedArtworks.single;
    expect(find.bySemanticsLabel(app.pagesById[saved.originalImageId]!.localizedName('en')), findsOneWidget);
    await expectGuidelines(tester);

    // The sheet asks the platform what it can do; without an engine the
    // reply never comes, so the channel answers like iOS: nothing extra.
    const channel = MethodChannel('cobi.paint/export');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      return switch (call.method) {
        'capabilities' => {'gallery': false, 'print': false},
        _ => null,
      };
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

    await passGate(tester, find.bySemanticsLabel(app.pagesById[saved.originalImageId]!.localizedName('en')));
    expect(find.text('Share'), findsOneWidget, reason: 'the grown-up sheet is open');
    expect(find.text('Delete'), findsOneWidget);
    await expectGuidelines(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget, reason: 'deleting asks once more');
    await expectGuidelines(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(app.savedArtworks, hasLength(1), reason: 'cancel keeps the picture');
    handle.dispose();
  });

  testWidgets('a coloring page meets the guidelines in Minik and in Büyük', (tester) async {
    final handle = tester.ensureSemantics();
    final app = provider();
    await openHome(tester, app);

    await tester.ensureVisible(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(find.byType(CategoryScreen), findsOneWidget);
    await expectGuidelines(tester);

    await tester.tap(find.byType(PressableCard).hitTestable().first);
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the page loaded');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Fill'), findsOneWidget);
    await expectGuidelines(tester);

    await app.setAgeMode(AgeMode.big);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Brush size'), findsOneWidget, reason: 'Büyük shows the size cell');
    await expectGuidelines(tester);
    handle.dispose();
  });

  testWidgets('the coloring screen fits a 13-inch iPad, a landscape iPad and a narrow Split View pane', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(2064, 2752); // iPad Pro 13" portrait

    final app = provider();
    await openHome(tester, app);
    await openDraw(tester);
    expect(tester.takeException(), isNull, reason: 'portrait iPad lays out without overflow');
    expect(find.bySemanticsLabel('Undo'), findsOneWidget);

    tester.view.physicalSize = const Size(2752, 2064); // landscape: the wide layout
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'landscape iPad lays out without overflow');
    expect(find.bySemanticsLabel('Undo'), findsOneWidget);
    expect(find.byType(PaintCanvas), findsOneWidget);

    tester.view.physicalSize = const Size(640, 2048); // 320 x 1024 pt: the narrowest Split View pane
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'a narrow pane lays out without overflow');
    expect(find.bySemanticsLabel('Undo'), findsOneWidget);
    expect(find.bySemanticsLabel('Home'), findsOneWidget);
    await tester.timedDrag(find.byType(PaintCanvas), const Offset(40, 30), const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(tester.widget<PaintCanvas>(find.byType(PaintCanvas)).document.strokes, isNotEmpty,
        reason: 'drawing still works in the narrow pane');
  });
}
