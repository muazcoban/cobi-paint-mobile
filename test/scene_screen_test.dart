import 'dart:async';
import 'dart:io';

import 'package:cobi_paint_mobile/data/builtin_scenes.dart';
import 'package:cobi_paint_mobile/main.dart';
import 'package:cobi_paint_mobile/models/scene.dart';
import 'package:cobi_paint_mobile/models/user_settings.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/screens/home_screen.dart';
import 'package:cobi_paint_mobile/screens/my_artworks_screen.dart';
import 'package:cobi_paint_mobile/screens/scene_screen.dart';
import 'package:cobi_paint_mobile/services/sound_service.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The scene prototype on the real app: tray, tap and drag, undo, and the
/// way into today's coloring screen. Phone size, English (the test locale).
void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.disabled = true;
    dir = Directory.systemTemp.createTempSync('cobi_scene_test');
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

  void phone(WidgetTester tester) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1125, 2001); // 375 x 667 pt, the iPhone SE
    addTearDown(tester.view.reset);
  }

  Future<AppProvider> openScene(WidgetTester tester, {bool big = false}) async {
    final app = provider();
    await tester.pumpWidget(CobiPaintApp(app: app));
    await settle(tester, () => app.isInitialized, reason: 'the provider read its folders');
    await settle(tester, () => find.text('Animals').evaluate().isNotEmpty, reason: 'the splash went to the home screen');
    if (big) await app.setAgeMode(AgeMode.big);
    await tester.pumpAndSettle();
    // A build without COBI_SCENE has no card; the screen is opened directly.
    unawaited(Navigator.of(tester.element(find.byType(HomeScreen)))
        .push(MaterialPageRoute<void>(builder: (_) => const SceneScreen(scene: gardenScene))));
    await tester.pumpAndSettle();
    return app;
  }

  ScenePiece piece(String key) => gardenScene.pieces.firstWhere((p) => p.key == key);

  Rect canvas(WidgetTester tester) => tester.getRect(find.image(AssetImage(gardenScene.background)));

  /// The slot the piece's picture sits in, or null while it is in the tray.
  int? slotOf(WidgetTester tester, ScenePiece p) {
    final pictures = find.image(AssetImage(p.asset));
    expect(pictures, findsOneWidget, reason: '${p.key}: one picture, no flight under way');
    final at = tester.getRect(pictures).center;
    final scene = canvas(tester);
    if (!scene.contains(at)) return null;
    final point = (at - scene.topLeft) * (gardenScene.size / scene.width);
    return gardenScene.slots.firstWhere((s) => s.rect.contains(point)).id;
  }

  Offset cellOf(WidgetTester tester, ScenePiece p) => tester.getCenter(find.bySemanticsLabel(p.label('en')).last);

  Offset slotCenter(WidgetTester tester, int id) {
    final scene = canvas(tester);
    final rect = gardenScene.slots.firstWhere((s) => s.id == id).rect;
    return scene.topLeft + rect.center * (scene.width / gardenScene.size);
  }

  /// A flight starts on the next frame and lands 220 ms later.
  Future<void> land(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> drag(WidgetTester tester, Offset from, Offset to) async {
    final gesture = await tester.startGesture(from);
    for (var i = 1; i <= 10; i++) {
      await gesture.moveTo(Offset.lerp(from, to, i / 10)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await land(tester);
  }

  testWidgets('Minik: four pieces; a tap sends each to its own slot, then the scene opens for colouring',
      (tester) async {
    phone(tester);
    final handle = tester.ensureSemantics();
    await openScene(tester);
    final pieces = gardenScene.piecesFor(big: false);
    expect(pieces, hasLength(4));
    for (final p in pieces) {
      expect(slotOf(tester, p), isNull, reason: '${p.key} starts in the tray');
    }
    for (final p in pieces) {
      await tester.tap(find.bySemanticsLabel(p.label('en')).last);
      await land(tester);
      expect(slotOf(tester, p), p.slot, reason: p.key);
    }
    // After a moment with the full scene, the composed page opens in the
    // coloring screen, saved as a file in the app's scenes folder.
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the coloring screen opened');
    final page = tester.widget<PaintCanvas>(find.byType(PaintCanvas)).document.map;
    expect(page.regionCount, greaterThan(16));
    final files = Directory('${dir.path}/docs/scenes').listSync().whereType<File>().toList();
    expect(files, hasLength(1));
    expect(files.single.path, endsWith('.png'));
    handle.dispose();
  });

  testWidgets('a coloured scene goes to My Artworks and opens again, even after an update moved the app folder',
      (tester) async {
    phone(tester);
    final app = await openScene(tester);
    for (final p in gardenScene.piecesFor(big: false)) {
      await tester.tap(find.bySemanticsLabel(p.label('en')).last);
      await land(tester);
    }
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the coloring screen opened');
    // Fill the sun's disc.
    final paper = tester.getRect(find.byType(PaintCanvas));
    final sun = gardenScene.slots.first.rect.center;
    await tester.tapAt(paper.topLeft + sun * (paper.width / gardenScene.size));
    await settle(tester, () => app.savedArtworks.isNotEmpty, reason: 'the first fill saved the scene');
    final saved = app.savedArtworks.first;
    expect(saved.originalImagePath, contains('/scenes/'));
    final label = tester.widget<PaintCanvas>(find.byType(PaintCanvas)).document.map.labelAt(sun.dx.round(), sun.dy.round());
    await tester.tap(find.bySemanticsLabel('Home'));
    await settle(tester, () => find.byType(HomeScreen).hitTestable().evaluate().isNotEmpty, reason: 'back home');

    // iOS gives the app a new documents folder on every update; the page is
    // found again by its file name.
    final moved = saved.copyWith(
      originalImagePath: '/var/mobile/Containers/Data/Application/OLD/Documents/scenes/${saved.originalImagePath.split('/').last}',
    );
    openArtwork(tester.element(find.byType(HomeScreen)), moved);
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the scene opened again');
    await settle(tester, () => tester.widget<PaintCanvas>(find.byType(PaintCanvas)).document.fillOf(label) != 0,
        reason: 'with its paint');
  });

  testWidgets('a drag puts a piece in the free slot nearest the finger; a tap then finds the nearest free slot',
      (tester) async {
    phone(tester);
    await openScene(tester);
    await drag(tester, cellOf(tester, piece('house')), slotCenter(tester, 0));
    expect(slotOf(tester, piece('house')), 0, reason: 'every drop is valid: the house sits in the sky');
    await tester.tap(find.bySemanticsLabel('Sun').last);
    await land(tester);
    expect(slotOf(tester, piece('sun')), 2, reason: 'its own slot is taken; the tree\'s is nearest');
  });

  testWidgets('a drag let go on its own cell is a tap; let go in the tray or off the scene, the piece goes back',
      (tester) async {
    phone(tester);
    await openScene(tester);
    final tree = piece('tree');
    final cell = cellOf(tester, tree);
    // Out 30 pt and back: a drag that ends on its own cell.
    final gesture = await tester.startGesture(cell);
    await gesture.moveTo(cell + const Offset(0, -30));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveTo(cell + const Offset(4, 0));
    await gesture.up();
    await land(tester);
    expect(slotOf(tester, tree), tree.slot);

    final flower = piece('flower');
    await drag(tester, cellOf(tester, flower), cellOf(tester, piece('sun')));
    expect(slotOf(tester, flower), isNull, reason: 'let go on another cell: back to the tray');
    await drag(tester, cellOf(tester, flower), tester.getCenter(find.bySemanticsLabel('Home')));
    expect(slotOf(tester, flower), isNull, reason: 'let go over the buttons: back to the tray');
  });

  testWidgets('undo sends the last piece back; a placed piece\'s cell does not move it', (tester) async {
    phone(tester);
    await openScene(tester);
    await tester.tap(find.bySemanticsLabel('Sun').last);
    await land(tester);
    await tester.tap(find.bySemanticsLabel('House').last);
    await land(tester);
    // The sun's cell now only lights the sun in the scene.
    await tester.tap(find.bySemanticsLabel('Sun').last);
    await land(tester);
    expect(slotOf(tester, piece('sun')), 0);
    await tester.tap(find.bySemanticsLabel('Undo'));
    await land(tester);
    expect(slotOf(tester, piece('house')), isNull);
    expect(slotOf(tester, piece('sun')), 0);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a second finger takes nothing while the first holds a piece', (tester) async {
    phone(tester);
    await openScene(tester);
    final first = await tester.startGesture(cellOf(tester, piece('sun')), pointer: 1);
    final second = await tester.startGesture(cellOf(tester, piece('house')), pointer: 2);
    await second.up();
    await land(tester);
    expect(slotOf(tester, piece('house')), isNull);
    await first.up();
    await land(tester);
    expect(slotOf(tester, piece('sun')), 0);
  });

  testWidgets('Büyük: six pieces, and redo puts back what undo took', (tester) async {
    phone(tester);
    await openScene(tester, big: true);
    expect(find.bySemanticsLabel('Bird'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Cloud').last);
    await land(tester);
    expect(slotOf(tester, piece('cloud')), 4);
    await tester.tap(find.bySemanticsLabel('Undo'));
    await land(tester);
    expect(slotOf(tester, piece('cloud')), isNull);
    await tester.tap(find.bySemanticsLabel('Redo'));
    await land(tester);
    expect(slotOf(tester, piece('cloud')), 4);
  });

  for (final big in [false, true]) {
    testWidgets('the scene screen meets the tap target, label and contrast guidelines (${big ? 'Büyük' : 'Minik'})',
        (tester) async {
      phone(tester);
      final handle = tester.ensureSemantics();
      await openScene(tester, big: big);
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }

  testWidgets('the scene screen fits an iPad, a landscape phone and a narrow Split View pane', (tester) async {
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    for (final size in const [Size(2064, 2752), Size(1688, 780), Size(640, 2048)]) {
      tester.view.physicalSize = size;
      await openScene(tester, big: size.width == 1688);
      expect(tester.takeException(), isNull, reason: '$size');
      await tester.tap(find.bySemanticsLabel('Sun').last);
      await land(tester);
      expect(slotOf(tester, piece('sun')), 0, reason: '$size');
      await tester.pumpWidget(const SizedBox());
    }
  });
}
