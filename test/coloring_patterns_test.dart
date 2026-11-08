import 'dart:io';

import 'package:cobi_paint_mobile/engine/document/coloring_document.dart';
import 'package:cobi_paint_mobile/engine/document/page_progress.dart';
import 'package:cobi_paint_mobile/engine/region/label_map.dart';
import 'package:cobi_paint_mobile/main.dart';
import 'package:cobi_paint_mobile/models/user_settings.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/services/sound_service.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:cobi_paint_mobile/widgets/kid_button.dart';
import 'package:cobi_paint_mobile/widgets/liveliness.dart';
import 'package:cobi_paint_mobile/widgets/paint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The council decisions of 8 November 2026 on a real page: the bucket's
/// pattern cycle (P9) and the breath of a finished picture (P8), with the
/// real screens, engine and storage in a temporary folder (see app_test).
void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.disabled = true;
    dir = Directory.systemTemp.createTempSync('cobi_patterns_test');
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

  Future<void> openFirstPage(WidgetTester tester, AppProvider app, {int index = 0}) async {
    await tester.pumpWidget(CobiPaintApp(app: app));
    await settle(tester, () => app.isInitialized, reason: 'the provider read its folders');
    await settle(tester, () => find.text('Animals').evaluate().isNotEmpty, reason: 'the home screen');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PressableCard).hitTestable().at(index));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isNotEmpty, reason: 'the page loaded');
    await tester.pumpAndSettle();
  }

  ColoringDocument document(WidgetTester tester) => tester.widget<PaintCanvas>(find.byType(PaintCanvas)).document;

  /// Taps the page at page pixel (x, y): the canvas card is exactly the page.
  Future<void> tapPage(WidgetTester tester, ({int x, int y}) at) async {
    final rect = tester.getRect(find.byType(PaintCanvas));
    final map = document(tester).map;
    final scale = rect.width / map.width;
    await tester.tapAt(rect.topLeft + Offset((at.x + 0.5) * scale, (at.y + 0.5) * scale));
    await tester.pump();
  }

  /// A point well inside [label]: the pixel of the label nearest the middle
  /// of its box whose neighbours 4 px away share the label.
  ({int x, int y}) inside(LabelMap map, int label) {
    final r = map.region(label);
    final cx = (r.left + r.right) ~/ 2, cy = (r.top + r.bottom) ~/ 2;
    ({int x, int y})? best;
    var bestDistance = 1 << 40;
    for (var y = r.top; y <= r.bottom; y += 2) {
      for (var x = r.left; x <= r.right; x += 2) {
        if (map.labelAt(x, y) != label) continue;
        const d = 4;
        if (map.labelAt(x + d, y) != label ||
            map.labelAt(x - d, y) != label ||
            map.labelAt(x, y + d) != label ||
            map.labelAt(x, y - d) != label) {
          continue;
        }
        final distance = (x - cx) * (x - cx) + (y - cy) * (y - cy);
        if (distance < bestDistance) {
          bestDistance = distance;
          best = (x: x, y: y);
        }
      }
    }
    return best!;
  }

  /// The regions a child has to paint for the page to count as finished.
  List<int> toPaint(LabelMap map) {
    final background = PageProgress.backgroundLabel(map);
    final finger = (map.width * 0.1) * (map.height * 0.1);
    return [
      for (var label = 1; label <= map.regionCount; label++)
        if (label != background && map.region(label).area >= finger) label,
    ];
  }

  testWidgets('the bucket cycles its patterns: Minik plain and dots, Büyük four states', (tester) async {
    final app = provider();
    await openFirstPage(tester, app);
    expect(find.bySemanticsLabel('Fill'), findsOneWidget, reason: 'a page opens with the plain bucket in hand');

    await tester.tap(find.bySemanticsLabel('Fill'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Fill: dots'), findsOneWidget, reason: 'the bucket was selected: the tap changes the pattern');

    final doc = document(tester);
    final label = toPaint(doc.map).first;
    await tapPage(tester, inside(doc.map, label));
    expect(doc.regionFill(label)!.pattern, FillPattern.dots);
    expect(doc.regionFill(label)!.argb, 0xFFE53935, reason: 'the ground is the child\'s colour');

    await tester.tap(find.bySemanticsLabel('Fill: dots'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Fill'), findsOneWidget, reason: 'Minik toggles straight back to plain');
    await tapPage(tester, inside(doc.map, label));
    expect(doc.regionFill(label)!.pattern, FillPattern.solid, reason: 'same colour, new pattern: a new fill');
    expect(doc.canUndo, isTrue);

    await app.setAgeMode(AgeMode.big);
    await tester.pumpAndSettle();
    for (final next in ['Fill: dots', 'Fill: stripes', 'Fill: rainbow', 'Fill']) {
      await tester.tap(find.byWidgetPredicate((w) => w is KidButton && (w.semanticLabel ?? '').startsWith('Fill')));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(next), findsOneWidget, reason: 'Büyük cycles through $next');
    }
    await tester.tap(find.bySemanticsLabel('Fill'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Fill: dots'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Fill: stripes'), findsOneWidget);
    await tapPage(tester, inside(doc.map, label));
    expect(doc.regionFill(label)!.pattern, FillPattern.stripes);

    await app.setAgeMode(AgeMode.little);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Fill'), findsOneWidget, reason: 'stripes are not a Minik pattern: back to plain');
    expect(doc.regionFill(label)!.pattern, FillPattern.stripes, reason: 'what is on the page stays');
  });

  testWidgets('a finished picture breathes once, after the reveal, and a touch settles it', (tester) async {
    final app = provider();
    await openFirstPage(tester, app);
    final doc = document(tester);
    final controller = tester.widget<Liveliness>(find.byType(Liveliness)).controller;
    final labels = toPaint(doc.map);
    expect(labels.length, inInclusiveRange(1, 12), reason: 'a level 1 page comes first for a new child');

    for (final label in labels) {
      await tapPage(tester, inside(doc.map, label));
      await tester.pump(const Duration(milliseconds: 30));
    }
    expect(PageProgress.of(doc).isComplete, isTrue);
    expect(controller.plays, 0, reason: 'the breath waits for the 220 ms reveal');
    await tester.pump(const Duration(milliseconds: 260));
    expect(controller.plays, 1);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.descendant(of: find.byType(Liveliness), matching: find.byType(Transform)), findsOneWidget,
        reason: 'the card is moving');

    // Painting on while it breathes: the touch settles the card and paints.
    await tapPage(tester, inside(doc.map, labels.first));
    expect(controller.settles, greaterThanOrEqualTo(1));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.descendant(of: find.byType(Liveliness), matching: find.byType(Transform)), findsNothing);
    await tester.pumpAndSettle();
    expect(controller.plays, 1, reason: 'filling again never repeats the breath');

    // Home from a page goes back to its category; the breath never plays there.
    await tester.tap(find.bySemanticsLabel('Home'));
    await settle(tester, () => find.byType(PaintCanvas).evaluate().isEmpty, reason: 'back in the category');
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsOneWidget);
    expect(controller.plays, 1, reason: 'the way home has its confetti, not the breath');
  });

  testWidgets('a touch right after the last fill means no breath', (tester) async {
    final app = provider();
    await openFirstPage(tester, app);
    final doc = document(tester);
    final controller = tester.widget<Liveliness>(find.byType(Liveliness)).controller;
    final labels = toPaint(doc.map);
    for (final label in labels) {
      await tapPage(tester, inside(doc.map, label));
    }
    expect(PageProgress.of(doc).isComplete, isTrue);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.bySemanticsLabel('Undo'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.plays, 0, reason: 'the child moved on before the reveal ended');
    await tester.pumpAndSettle();
  });
}
