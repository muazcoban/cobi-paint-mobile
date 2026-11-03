import 'dart:io';

import 'package:cobi_paint_mobile/data/page_order.dart';
import 'package:cobi_paint_mobile/main.dart';
import 'package:cobi_paint_mobile/models/user_settings.dart';
import 'package:cobi_paint_mobile/screens/category_screen.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/services/sound_service.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:cobi_paint_mobile/widgets/kid_button.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The whole app, from the splash to a saved picture, with the real
/// screens, engine and storage in a temporary folder.
///
/// File and isolate work started by the app only completes on the real event
/// loop, and each completion then needs the test clock to move on, so
/// [settle] alternates the two until the awaited state is there.
void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.disabled = true; // no audio plugin in the test runner
    dir = Directory.systemTemp.createTempSync('cobi_app_test');
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
    expect(
      done(),
      isTrue,
      reason: '$reason (sad face: ${find.byIcon(Icons.sentiment_dissatisfied_rounded).evaluate().length}, '
          'spinner: ${find.byType(CircularProgressIndicator).evaluate().length})',
    );
  }

  Future<void> openHome(WidgetTester tester, AppProvider app) async {
    await tester.pumpWidget(CobiPaintApp(app: app));
    await settle(tester, () => app.isInitialized, reason: 'the provider read its folders');
    await settle(tester, () => find.text('Animals').evaluate().isNotEmpty, reason: 'the splash went to the home screen');
    await tester.pumpAndSettle();
  }

  testWidgets('a child opens Draw, draws, goes home and finds the picture in My Artworks', (tester) async {
    final app = provider();
    await openHome(tester, app);
    expect(find.text('Draw'), findsOneWidget, reason: 'the device language in tests is English');

    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the blank page loaded');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Fill'), findsNothing, reason: 'the blank page has the mirror where the fill is');
    expect(find.bySemanticsLabel('Mirror off'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    final canvas = find.byType(PaintCanvas);
    await tester.timedDrag(canvas, const Offset(90, 70), const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 500)); // autosave fires after 400 ms
    await settle(tester, () => app.savedArtworks.isNotEmpty, reason: 'autosave wrote the picture');

    // Minik has one mirror switch: four-way, on or off.
    await tester.tap(find.bySemanticsLabel('Mirror off'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Four-way mirror'), findsOneWidget);
    await tester.timedDrag(canvas, const Offset(-60, 40), const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    final document = tester.widget<PaintCanvas>(canvas).document;
    expect(document.strokes, hasLength(2), reason: 'the copies are drawn, not stored');
    expect(document.strokes.last.symmetry, 4);
    await tester.tap(find.bySemanticsLabel('Undo'));
    await tester.pumpAndSettle();
    expect(document.strokes, hasLength(1), reason: 'one mirrored stroke is one undo step');
    await tester.tap(find.bySemanticsLabel('Four-way mirror'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Mirror off'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Home'));
    await settle(tester, () => find.text('Animals').evaluate().isNotEmpty, reason: 'back on the home screen');
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Artworks'));
    await tester.pumpAndSettle();
    final saved = app.savedArtworks.single;
    expect(app.storageService.resolveArtworkFile(saved.thumbnailPath).existsSync(), isTrue);
    expect(find.bySemanticsLabel(saved.name), findsOneWidget, reason: 'the framed picture is on the wall');
  });

  testWidgets('a category lists its pages and opens one', (tester) async {
    final app = provider();
    await openHome(tester, app);

    // The Food card sits below the fold at the test window size.
    await tester.ensureVisible(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(find.byType(CategoryScreen), findsOneWidget);
    // The grid is lazy, so only the first rows are built; tap the first card.
    final level = currentLevel(app.settings, app.savedArtworks, app.pagesById);
    expect(orderPages(app.getImagesForCategory('food'), level).first.level, 1, reason: 'a new child sees level 1 first');
    // The home screen's cards are still in the tree under the route, so
    // only a card that can be hit counts.
    final cards = find.byType(PressableCard).hitTestable();
    expect(cards, findsWidgets);

    await tester.tap(cards.first);
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the page loaded');
    await tester.pumpAndSettle();
    expect(find.byType(PaintCanvas), findsOneWidget);
    expect(find.bySemanticsLabel('Fill'), findsOneWidget, reason: 'a coloring page keeps the fill');
    expect(find.bySemanticsLabel('Mirror off'), findsNothing, reason: 'the mirror is only on the blank page');
  });

  testWidgets('the brush button cycles to stickers and a tap on the page sticks one', (tester) async {
    final app = provider();
    await openHome(tester, app);
    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the blank page loaded');
    await tester.pumpAndSettle();

    // Minik: marker, rainbow, spray, glitter, sticker, marker again. No menu
    // anywhere, and the crayon and the neon pen stay in Büyük.
    var label = 'Marker';
    for (final next in ['Rainbow brush', 'Spray paint', 'Glitter brush', 'Sticker: star']) {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(next), findsOneWidget, reason: 'after "$label" comes "$next"');
      expect(find.bySemanticsLabel(RegExp('Crayon|Neon pen')), findsNothing);
      label = next;
    }

    await tester.tapAt(tester.getCenter(find.byType(PaintCanvas)));
    await tester.pumpAndSettle();
    final document = tester.widget<PaintCanvas>(find.byType(PaintCanvas)).document;
    expect(document.stickers, hasLength(1));
    expect(document.stickers.single.code, 'star');
    expect(find.bySemanticsLabel('Sticker: heart'), findsOneWidget, reason: 'the next sticker comes up');
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await tester.tap(find.bySemanticsLabel('Sticker: heart'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Marker'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Undo'));
    await tester.pumpAndSettle();
    expect(document.stickers, isEmpty);
  });

  testWidgets('in Büyük mode the brush cycles through the crayon to stickers, and the size cell scales them', (tester) async {
    final app = provider();
    await openHome(tester, app);
    await app.updateSettings(app.settings.copyWith(ageMode: AgeMode.big));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the blank page loaded');
    await tester.pumpAndSettle();

    var label = 'Marker';
    for (final next in ['Rainbow brush', 'Crayon', 'Spray paint', 'Glitter brush', 'Neon pen', 'Sticker: star']) {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(next), findsOneWidget, reason: 'after "$label" comes "$next"');
      label = next;
    }

    final canvas = find.byType(PaintCanvas);
    await tester.tapAt(tester.getCenter(canvas));
    await tester.pumpAndSettle();
    final document = tester.widget<PaintCanvas>(canvas).document;
    final middle = document.stickers.single.size;

    // The brush size cell in the palette sizes stickers as well.
    await tester.tap(find.bySemanticsLabel('Brush size'));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(canvas) + const Offset(0, -60));
    await tester.pumpAndSettle();
    expect(document.stickers, hasLength(2));
    expect(document.stickers.last.size, greaterThan(middle));
    expect(document.stickers.last.code, 'red_heart', reason: 'the next sticker in the order');
  });

  testWidgets('in Büyük mode the mirror cycles two, four, six and off', (tester) async {
    final app = provider();
    await openHome(tester, app);
    await app.updateSettings(app.settings.copyWith(ageMode: AgeMode.big));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the blank page loaded');
    await tester.pumpAndSettle();
    for (final label in ['Two-way mirror', 'Four-way mirror', 'Six-way mirror', 'Mirror off']) {
      await tester.tap(find.byWidgetPredicate((w) => w is KidButton && w.child is MirrorGlyph));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: 'after a tap the mirror is "$label"');
    }
  });
}
