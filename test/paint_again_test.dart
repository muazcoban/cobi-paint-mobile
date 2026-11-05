import 'dart:io';

import 'package:cobi_paint_mobile/data/builtin_images.dart';
import 'package:cobi_paint_mobile/main.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/screens/coloring_screen.dart';
import 'package:cobi_paint_mobile/services/sound_service.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:cobi_paint_mobile/widgets/kid_button.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Colour this page again" (council, 5 Nov 2026): a grown-up opens a fresh
/// copy of a coloured page behind the gate; nothing is deleted, an untouched
/// copy is never saved, and the category card shows the newest copy.
void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.disabled = true;
    dir = Directory.systemTemp.createTempSync('cobi_again_test');
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

  // Leaving the coloring screen waits for the save, which only finishes on
  // the real event loop, so the pop is awaited with [settle].
  Future<void> goHome(WidgetTester tester) async {
    final onPage = find.byType(ColoringScreen).evaluate().isNotEmpty;
    await tester.tap(find.bySemanticsLabel('Home').hitTestable().first);
    if (onPage) {
      await settle(tester, () => find.byType(ColoringScreen).evaluate().isEmpty, reason: 'the coloring screen closed');
    }
    await tester.pumpAndSettle();
  }

  testWidgets('a grown-up colours a page again: a new copy, the old one stays, the card opens the newest', (tester) async {
    const channel = MethodChannel('cobi.paint/export');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      return switch (call.method) {
        'capabilities' => {'gallery': false, 'print': false},
        _ => null,
      };
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

    final app = provider();
    await tester.pumpWidget(CobiPaintApp(app: app));
    await settle(tester, () => app.isInitialized, reason: 'the provider read its folders');
    await settle(tester, () => find.text('Animals').evaluate().isNotEmpty, reason: 'home screen');
    await tester.pumpAndSettle();

    // Colour the first Food page once.
    await tester.ensureVisible(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PressableCard).hitTestable().first);
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the page loaded');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PaintCanvas));
    await tester.pump(const Duration(milliseconds: 500));
    await settle(tester, () => app.savedArtworks.isNotEmpty, reason: 'autosave wrote the picture');
    final first = app.savedArtworks.single;
    // Tiles read the page name in the app's language; the artwork keeps the
    // name it was saved with.
    final page = builtInImages.firstWhere((p) => p.id == first.originalImageId);
    final label = page.localizedName('en');
    await goHome(tester); // back to the category
    await goHome(tester); // back home
    // The home list is still scrolled down to Food; the gallery card is above.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 800));
    await tester.pumpAndSettle();
    await settle(tester, () => find.text('My Artworks').evaluate().isNotEmpty, reason: 'home again');

    // Behind the gate: the new row opens the same page blank.
    await tester.tap(find.text('My Artworks'));
    await tester.pumpAndSettle();
    final handle = tester.ensureSemantics();
    await passGate(tester, find.bySemanticsLabel(label));
    expect(find.text('Colour this page again'), findsOneWidget);
    expect(find.text('The old picture stays here'), findsOneWidget);
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
    await tester.tap(find.text('Colour this page again'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the fresh page loaded');
    await tester.pumpAndSettle();
    final screen = tester.widget<ColoringScreen>(find.byType(ColoringScreen));
    expect(screen.existingArtwork, isNull, reason: 'not tied to the old artwork');
    expect(tester.widget<PaintCanvas>(find.byType(PaintCanvas)).document.isEmpty, isTrue, reason: 'a blank page');

    // Leaving without a touch saves nothing.
    await goHome(tester);
    expect(app.savedArtworks, hasLength(1));

    // Again, and this time the child colours it: a second copy appears.
    await passGate(tester, find.bySemanticsLabel(label));
    await tester.tap(find.text('Colour this page again'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the fresh page loaded');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PaintCanvas));
    await tester.pump(const Duration(milliseconds: 500));
    await settle(tester, () => app.savedArtworks.length == 2, reason: 'the copy was saved');
    final copies = app.savedArtworks.where((a) => a.originalImageId == first.originalImageId).toList();
    expect(copies, hasLength(2));
    expect(copies.any((a) => a.id == first.id), isTrue, reason: 'the old picture stays');
    final newest = copies.firstWhere((a) => a.id != first.id);
    await goHome(tester); // back to My Artworks
    await goHome(tester); // back home
    await settle(tester, () => find.text('Food').evaluate().isNotEmpty, reason: 'home again');

    // The category card opens the newest copy.
    await tester.ensureVisible(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(label).hitTestable().first);
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the page loaded');
    await tester.pumpAndSettle();
    expect(tester.widget<ColoringScreen>(find.byType(ColoringScreen)).existingArtwork?.id, newest.id);
  });
}
