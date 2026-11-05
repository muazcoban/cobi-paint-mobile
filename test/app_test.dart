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
import 'package:flutter/services.dart';
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
    expect(saved.name, 'Çizim', reason: 'the saved name stays Turkish');
    expect(find.bySemanticsLabel('Drawing'), findsOneWidget, reason: 'the framed picture is on the wall, read in English');
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

  testWidgets('on a 375 pt phone the new categories are a scroll away, keep the card size and open their pages',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(750, 1624); // 375 x 812 pt

    final app = provider();
    await openHome(tester, app);
    Finder card(String name) => find.ancestor(of: find.text(name), matching: find.byType(PressableCard));
    final size = tester.getSize(card('Animals'));
    // Two columns: (375 - 2 x 16 padding - 16 spacing) / 2 wide; the grid is the same for every card.
    expect(size.width, closeTo(163.5, 0.01));

    for (final (name, id) in [('Space', 'space'), ('Music', 'music'), ('Clothes', 'clothes')]) {
      await tester.scrollUntilVisible(find.text(name), 120, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(tester.getSize(card(name)), size, reason: '$name has the same tap target as the first card');

      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byType(CategoryScreen), matching: find.text(name)), findsOneWidget);
      expect(app.getImagesForCategory(id).length, greaterThanOrEqualTo(12), reason: name);
      expect(find.byType(PressableCard).hitTestable(), findsWidgets, reason: '$name shows its pages');

      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryScreen), findsNothing);
    }
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

  testWidgets('behind the gate a grown-up on Android can save a picture to the gallery and print it', (tester) async {
    final app = provider();
    await openHome(tester, app);
    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the blank page loaded');
    await tester.pumpAndSettle();
    await tester.timedDrag(find.byType(PaintCanvas), const Offset(90, 70), const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 500));
    await settle(tester, () => app.savedArtworks.isNotEmpty, reason: 'autosave wrote the picture');
    await tester.tap(find.bySemanticsLabel('Home'));
    await settle(tester, () => find.text('Animals').evaluate().isNotEmpty, reason: 'back on the home screen');
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Artworks'));
    await tester.pumpAndSettle();
    final saved = app.savedArtworks.single;

    // A long press asks the multiplication; the answer is read off the screen.
    Future<void> passGate() async {
      await tester.longPress(find.bySemanticsLabel(app.pagesById[saved.originalImageId]!.localizedName('en')));
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

    // The platform says what it can do; a real reply needs the engine, so
    // the channel is mocked from the start: first a device that can do
    // neither (the plain sheet, as on iOS), then an Android 10 phone.
    const channel = MethodChannel('cobi.paint/export');
    final calls = <MethodCall>[];
    var canExport = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'capabilities' => {'gallery': canExport, 'print': canExport},
        'saveToGallery' => 'content://media/external/images/media/7',
        _ => null,
      };
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

    await passGate();
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Print'), findsNothing);
    expect(find.text('Save to gallery'), findsNothing);
    await tester.tapAt(const Offset(20, 20)); // closes the sheet
    await tester.pumpAndSettle();

    canExport = true;
    await passGate();
    expect(find.text('Save to gallery'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
    expect(find.text('Print blank page'), findsNothing, reason: 'a free drawing has no line art to print');
    await tester.tap(find.text('Save to gallery'));
    // The picture is read from disk, which only completes on the real loop.
    await settle(tester, () => find.text('Saved to gallery').evaluate().isNotEmpty,
        reason: 'the grown-up gets a confirmation');
    final save = calls.singleWhere((c) => c.method == 'saveToGallery');
    final saveArgs = save.arguments as Map;
    expect(saveArgs['bytes'], isA<Uint8List>().having((b) => b.length, 'length', greaterThan(100)));
    expect(saveArgs['name'], startsWith('cobi_paint_'));

    await passGate();
    await tester.tap(find.text('Print'));
    await settle(tester, () => calls.any((c) => c.method == 'print'), reason: 'the print dialog was asked for');
    final print = calls.singleWhere((c) => c.method == 'print');
    expect((print.arguments as Map)['name'], saved.name);
    expect((print.arguments as Map)['bytes'], isA<Uint8List>());
  });

  testWidgets('Büyük hands undo to the system and the keyboard; Minik keeps it to the button', (tester) async {
    final undoCalls = <Map<Object?, Object?>>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.undoManager, (call) async {
      if (call.method == 'UndoManager.setUndoState') undoCalls.add(Map<Object?, Object?>.from(call.arguments as Map));
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.undoManager, null));

    final app = provider();
    await openHome(tester, app);
    await tester.tap(find.text('Draw'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the blank page loaded');
    await tester.pumpAndSettle();
    final canvas = find.byType(PaintCanvas);
    await tester.timedDrag(canvas, const Offset(90, 70), const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    final document = tester.widget<PaintCanvas>(canvas).document;
    expect(document.strokes, hasLength(1));
    // Minik: the system never hears of the stroke, so three fingers on the
    // page do nothing and a toddler's keyboard changes nothing.
    expect(undoCalls.where((c) => c['canUndo'] == true), isEmpty, reason: 'Minik keeps undo to its button');
    expect(UndoManager.client, isNull);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(document.strokes, hasLength(1), reason: 'no keyboard undo in Minik');

    await app.updateSettings(app.settings.copyWith(ageMode: AgeMode.big));
    await tester.pumpAndSettle();
    expect(UndoManager.client, isNotNull, reason: 'Büyük hands the stack to the system');
    expect(undoCalls.last, {'canUndo': true, 'canRedo': false});

    // A three-finger swipe or the system's Cmd-Z arrives through the channel.
    Future<void> platformUndo(String direction) async {
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        SystemChannels.undoManager.name,
        SystemChannels.undoManager.codec.encodeMethodCall(MethodCall('UndoManagerClient.handleUndo', [direction])),
        (_) {},
      );
      await tester.pumpAndSettle();
    }

    await platformUndo('undo');
    expect(document.strokes, isEmpty);
    expect(undoCalls.last, {'canUndo': false, 'canRedo': true});
    await platformUndo('redo');
    expect(document.strokes, hasLength(1));

    // A hardware keyboard on Android: Ctrl-Z and Ctrl-Shift-Z.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ);
    await tester.pumpAndSettle();
    expect(document.strokes, isEmpty, reason: 'Ctrl-Z undoes');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(document.strokes, hasLength(1), reason: 'Ctrl-Shift-Z redoes');

    // Back to Minik: the system is told there is nothing to undo.
    await app.updateSettings(app.settings.copyWith(ageMode: AgeMode.little));
    await tester.pumpAndSettle();
    expect(UndoManager.client, isNull);
    expect(undoCalls.last, {'canUndo': false, 'canRedo': false});
  });
}
