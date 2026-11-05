import 'dart:io';
import 'dart:math' as math;

import 'package:cobi_paint_mobile/engine/document/page_progress.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/l10n/app_localizations.dart';
import 'package:cobi_paint_mobile/main.dart' as app;
import 'package:cobi_paint_mobile/screens/home_screen.dart';
import 'package:cobi_paint_mobile/widgets/kid_button.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Walks the real app through the store screenshot moments on a simulator.
/// Every moment prints a line (`SHOT:name` or `BURST:name`) that
/// tool/store/take_screenshots.py answers with `xcrun simctl io screenshot`,
/// so the pictures have the status bar and the exact device size. The
/// language is the simulator's. Never run in CI.
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

  // The host script answers every moment by dropping a file into the app's
  // temporary folder (the simulator's data container is on the Mac), so a
  // slow screenshot never catches a later screen. With
  // --dart-define=COBI_SHOTS=off nobody answers and the walk is a plain smoke
  // test, for example on Android.
  const shooting = bool.fromEnvironment('COBI_SHOTS', defaultValue: true);

  Future<void> answer(String file) async {
    if (!shooting) return wait(800);
    final flag = File('${Directory.systemTemp.path}/$file');
    for (var i = 0; i < 900; i++) {
      if (flag.existsSync()) {
        flag.deleteSync();
        return;
      }
      await wait(100);
    }
    throw StateError('the host did not answer $file');
  }

  Future<void> shot(String name) async {
    say('SHOT:$name');
    await answer('cobi_shot_$name.done');
  }

  Future<void> goHome(WidgetTester tester, AppLocalizations l10n) async {
    for (var i = 0; i < 3 && find.byType(HomeScreen).hitTestable().evaluate().isEmpty; i++) {
      await tester.tap(find.bySemanticsLabel(l10n.home).hitTestable().first);
      await wait(1500);
    }
    await until(find.byType(HomeScreen).hitTestable());
  }

  // A point well inside [label]: the middle of its longest row in the middle
  // half of the region, so a tap never lands on a line.
  Offset inside(LabelMap map, int label) {
    final r = map.region(label);
    final top = r.top + (r.bottom - r.top) ~/ 4;
    final bottom = r.bottom - (r.bottom - r.top) ~/ 4;
    var best = 0;
    var bestX = (r.left + r.right) / 2;
    var bestY = (r.top + r.bottom) / 2;
    for (var y = top; y <= bottom; y += 2) {
      var run = 0;
      for (var x = r.left; x <= r.right + 1; x++) {
        if (x <= r.right && map.labelAt(x, y) == label) {
          run++;
        } else {
          if (run > best) {
            best = run;
            bestX = x - run / 2;
            bestY = y.toDouble();
          }
          run = 0;
        }
      }
    }
    return Offset(bestX, bestY);
  }

  // Screen points of every finger-sized region but the background, biggest
  // first.
  List<Offset> regionTargets(WidgetTester tester) {
    final canvas = tester.widget<PaintCanvas>(find.byType(PaintCanvas));
    final map = canvas.document.map;
    final box = tester.renderObject<RenderBox>(find.byType(PaintCanvas));
    final scale = math.min(box.size.width / map.width, box.size.height / map.height);
    final offset = Offset((box.size.width - map.width * scale) / 2, (box.size.height - map.height * scale) / 2);
    final background = PageProgress.backgroundLabel(map);
    final finger = (map.width * 0.1) * (map.height * 0.1);
    final labels = [
      for (var label = 1; label <= map.regionCount; label++)
        if (label != background && map.region(label).area >= finger) label,
    ]..sort((a, b) => map.region(b).area.compareTo(map.region(a).area));
    return [for (final label in labels) box.localToGlobal(offset + inside(map, label) * scale)];
  }

  Future<void> openFirstPage(WidgetTester tester, String category) async {
    // The home grid builds only the cards on screen: back to the top, then
    // down until the card is there.
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, 3000));
    await wait(1000);
    for (var i = 0; i < 12 && find.text(category).evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -250));
      await wait(500);
    }
    await tester.ensureVisible(find.text(category));
    await wait(600);
    await tester.tap(find.text(category));
    await wait(1500);
    await tester.tap(find.byType(PressableCard).hitTestable().first);
    await until(find.byType(PaintCanvas));
    await wait(2000);
  }

  testWidgets('store screenshots', (tester) async {
    for (final old in Directory.systemTemp.listSync().whereType<File>()) {
      if (old.path.contains('cobi_shot_')) old.deleteSync();
    }
    app.main();
    await until(find.byType(HomeScreen));
    await wait(2500);
    final semantics = tester.ensureSemantics();
    final l10n = AppLocalizations.of(tester.element(find.byType(HomeScreen)))!;
    final colours = [for (final name in l10n.colorNames.split(',')) name.trim()];

    // 1. Home, the top and the end of the list with the newest categories.
    await shot('01_home');
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -3000));
    await wait(2000);
    await shot('01b_home_end');
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, 3000));
    await wait(1500);

    // 2. The parental gate over the home screen.
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await until(find.byKey(const ValueKey('gate-task')));
    await wait(1200);
    await shot('06_gate');
    await tester.tap(find.byIcon(Icons.close_rounded));
    await wait(1500);

    // 3. The marker stays inside the lines: rows over the biggest region.
    await openFirstPage(tester, l10n.food);
    await tester.tap(find.bySemanticsLabel(colours[4]));
    await wait(300);
    final brush = find.byWidgetPredicate((w) => w is KidButton && w.icon == Icons.brush_rounded);
    if (brush.evaluate().isNotEmpty) {
      await tester.tap(brush.first);
      await wait(400);
    }
    final target = regionTargets(tester).first;
    final gesture = await tester.startGesture(target);
    for (var k = 0; k < 6; k++) {
      final dy = (k - 3) * 22.0;
      await gesture.moveTo(target + Offset(-140, dy));
      await wait(30);
      await gesture.moveTo(target + Offset(140, dy + 11));
      await wait(30);
    }
    await gesture.up();
    await wait(1500);
    await shot('03_lines');
    await goHome(tester, l10n);

    // 4. Filling: the first region fills on a tap (02); every finger-sized
    // region a colour finishes the page and brings the confetti (07).
    await openFirstPage(tester, l10n.animals);
    final fill = find.bySemanticsLabel(l10n.fill);
    if (fill.evaluate().isNotEmpty) {
      await tester.tap(fill.first);
      await wait(300);
    }
    const order = [1, 6, 5, 4, 3, 2, 0, 7];
    final targets = regionTargets(tester);
    for (var i = 0; i < targets.length; i++) {
      await tester.tap(find.bySemanticsLabel(colours[order[i % order.length]]));
      await wait(250);
      final last = i == targets.length - 1;
      if (last) {
        say('BURST:07_celebration');
        await answer('cobi_shot_07_celebration.go');
      }
      await tester.tapAt(targets[i]);
      if (last) {
        await answer('cobi_shot_07_celebration.done');
      } else if (i == 0) {
        await wait(900);
        await shot('02_fill');
      } else {
        await wait(450);
      }
    }
    await goHome(tester, l10n);

    // 5. The Draw page: the mirror on, a rainbow wave and a few stickers.
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, 3000));
    await wait(800);
    await tester.tap(find.text(l10n.freeDraw));
    await until(find.byType(PaintCanvas));
    await wait(1800);
    await tester.tap(find.bySemanticsLabel(l10n.mirrorOff));
    await wait(400);
    await tester.tap(find.bySemanticsLabel(l10n.marker));
    await wait(400);
    final page = tester.getRect(find.byType(PaintCanvas));
    for (final row in [0.2, 0.36]) {
      final wave = await tester.startGesture(Offset(page.left + page.width * 0.08, page.top + page.height * row));
      for (var k = 1; k <= 24; k++) {
        final x = page.left + page.width * (0.08 + 0.38 * k / 24);
        final y = page.top + page.height * (row + 0.05 * math.sin(k / 24 * 2 * math.pi));
        await wave.moveTo(Offset(x, y));
        await wait(20);
      }
      await wave.up();
      await wait(500);
    }
    for (final label in [l10n.rainbowBrush, l10n.sprayBrush, l10n.glitterBrush]) {
      await tester.tap(find.bySemanticsLabel(label));
      await wait(400);
    }
    for (final at in [const Offset(0.25, 0.28), const Offset(0.38, 0.12), const Offset(0.14, 0.44)]) {
      await tester.tapAt(Offset(page.left + page.width * at.dx, page.top + page.height * at.dy));
      await wait(500);
    }
    await wait(1200);
    await shot('05_draw');
    await goHome(tester, l10n);

    // 5. The wall of pictures.
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, 3000));
    await wait(800);
    await tester.tap(find.text(l10n.myArtworks));
    await wait(2500);
    await shot('04_artworks');
    semantics.dispose();
    say('DONE');
  });
}
