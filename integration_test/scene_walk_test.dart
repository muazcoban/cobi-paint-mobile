import 'dart:io';

import 'package:cobi_paint_mobile/data/builtin_scenes.dart';
import 'package:cobi_paint_mobile/l10n/app_localizations.dart';
import 'package:cobi_paint_mobile/main.dart' as app;
import 'package:cobi_paint_mobile/screens/home_screen.dart';
import 'package:cobi_paint_mobile/screens/scene_screen.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Walks the scene prototype on a simulator and asks for a screenshot at
/// each moment (the same `SHOT:name` handshake as store_shots_test.dart).
/// Needs an observation build:
///
///   python3 tool/store/take_screenshots.py <udid> build/scene_shots/se \
///       --test integration_test/scene_walk_test.dart --define COBI_SCENE=observation
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

  Future<void> until(Finder finder, {int seconds = 40}) async {
    for (var i = 0; i < seconds * 10; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await wait(100);
    }
    throw StateError('timed out waiting for $finder');
  }

  // ignore: avoid_print
  void say(String line) => print(line);

  const shooting = bool.fromEnvironment('COBI_SHOTS', defaultValue: true);

  Future<void> shot(String name) async {
    say('SHOT:$name');
    if (!shooting) return wait(800);
    final flag = File('${Directory.systemTemp.path}/cobi_shot_$name.done');
    for (var i = 0; i < 900; i++) {
      if (flag.existsSync()) {
        flag.deleteSync();
        return;
      }
      await wait(100);
    }
    throw StateError('the host did not answer $name');
  }

  testWidgets('scene walk', (tester) async {
    for (final old in Directory.systemTemp.listSync().whereType<File>()) {
      if (old.path.contains('cobi_shot_')) old.deleteSync();
    }
    app.main();
    await until(find.byType(HomeScreen));
    await wait(2500);
    final semantics = tester.ensureSemantics();
    final l10n = AppLocalizations.of(tester.element(find.byType(HomeScreen)))!;
    final lang = Localizations.localeOf(tester.element(find.byType(HomeScreen))).languageCode;

    // The card is last on the grid.
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -3000));
    await wait(1500);
    await shot('scene_00_card');
    await tester.tap(find.text(l10n.scene));
    await until(find.byType(SceneScreen));
    // Six quiet seconds on the empty scene bring the mascot over the sun.
    await wait(7000);
    await shot('scene_01_hint');

    Offset cell(String key) =>
        tester.getCenter(find.bySemanticsLabel(gardenScene.pieces.firstWhere((p) => p.key == key).label(lang)).last);
    final scene = tester.getRect(find.image(AssetImage(gardenScene.background)));
    Offset slot(int id) => scene.topLeft + gardenScene.slots[id].rect.center * (scene.width / gardenScene.size);

    await tester.tap(find.bySemanticsLabel(gardenScene.pieces.first.label(lang)).last);
    await wait(900);
    await shot('scene_02_sun');

    // The house on its way: the free slots show, the nearest one lit.
    final from = cell('house');
    final to = slot(1);
    final gesture = await tester.startGesture(from);
    for (var i = 1; i <= 20; i++) {
      await gesture.moveTo(Offset.lerp(from, to, i / 20 * 0.8)!);
      await wait(30);
    }
    await wait(400);
    await shot('scene_03_drag');
    await gesture.moveTo(to);
    await wait(30);
    await gesture.up();
    await wait(900);

    await tester.tap(find.bySemanticsLabel(gardenScene.pieces[2].label(lang)).last);
    await wait(600);
    await tester.tap(find.bySemanticsLabel(gardenScene.pieces[3].label(lang)).last);
    await wait(400);
    await shot('scene_04_full');

    // The full scene opens in today's coloring screen.
    await until(find.byType(PaintCanvas));
    await wait(2500);
    await shot('scene_05_coloring');
    final paper = tester.getRect(find.byType(PaintCanvas));
    Offset at(double x, double y) => paper.topLeft + Offset(x, y) * (paper.width / gardenScene.size);
    final colours = [for (final name in l10n.colorNames.split(',')) name.trim()];
    for (final (colour, point) in [
      (2, at(852, 162)), // the sun's disc
      (4, at(300, 150)), // the sky
      (3, at(150, 900)), // the grass on the left
      (0, at(150, 620)), // the house's wall
      (4, at(560, 900)), // the river
      (3, at(810, 420)), // the tree's crown
      (6, at(840, 800)), // the tulip's cup
    ]) {
      await tester.tap(find.bySemanticsLabel(colours[colour]));
      await wait(250);
      await tester.tapAt(point);
      await wait(500);
    }
    await wait(1200);
    await shot('scene_06_colored');
    await tester.tap(find.bySemanticsLabel(l10n.home).first);
    await wait(3000);
    semantics.dispose();
    say('DONE');
  });
}
