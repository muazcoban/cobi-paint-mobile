import 'dart:math' as math;

import 'package:cobi_paint_mobile/l10n/app_localizations.dart';
import 'package:cobi_paint_mobile/widgets/kid_button.dart';
import 'package:cobi_paint_mobile/widgets/kid_palette.dart';
import 'package:cobi_paint_mobile/widgets/parental_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('forgiving tap', () {
    testWidgets('a finger that wanders and lifts near the button still taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(KidButton(icon: Icons.home, onTap: () => taps++)));
      final center = tester.getCenter(find.byType(KidButton));

      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(60, 0)); // far beyond Flutter's 18 lp tap slop
      await gesture.moveTo(center + const Offset(30, 20)); // back within the button
      await gesture.up();

      expect(taps, 1);
    });

    testWidgets('lifting well outside the button does not tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(KidButton(icon: Icons.home, onTap: () => taps++)));
      final center = tester.getCenter(find.byType(KidButton));

      final gesture = await tester.startGesture(center);
      await gesture.moveTo(center + const Offset(120, 0));
      await gesture.up();

      expect(taps, 0);
    });
  });

  testWidgets('the palette picks the dot under the lifted finger', (tester) async {
    int? picked;
    await tester.pumpWidget(_app(KidPalette(
      items: const [
        PaletteItem.color(Colors.red),
        PaletteItem.color(Colors.green),
        PaletteItem.color(Colors.blue),
      ],
      columns: 3,
      cellSize: 70,
      selectedIndex: 0,
      onSelected: (i) => picked = i,
    )));
    final topLeft = tester.getTopLeft(find.byType(KidPalette));

    final gesture = await tester.startGesture(topLeft + const Offset(35, 35)); // red
    await gesture.moveTo(topLeft + const Offset(35 + 2 * 82, 35)); // slide to blue
    await gesture.up();

    expect(picked, 2);
  });

  for (final width in [375.0 - 24, 393.0 - 24]) {
    testWidgets('on a ${width + 24} pt wide phone every palette cell, the eraser included, is reachable', (tester) async {
      int? picked;
      await tester.pumpWidget(_app(SizedBox(
        width: width,
        child: Center(
          child: KidPalette(
            items: [for (var i = 0; i < 9; i++) const PaletteItem.color(Colors.red), const PaletteItem.glyph(EraserGlyph())],
            columns: 5,
            cellSize: 70,
            selectedIndex: 0,
            onSelected: (i) => picked = i,
          ),
        ),
      )));
      final box = tester.getRect(find.byType(KidPalette));
      expect(box.width, lessThanOrEqualTo(width));

      // Centre of each cell in a 5 x 2 grid that fills the palette's box.
      final pitchX = (box.width + 12) / 5;
      final pitchY = (box.height + 12) / 2;
      for (var i = 0; i < 10; i++) {
        final center = box.topLeft + Offset((i % 5) * pitchX + (pitchX - 12) / 2, (i ~/ 5) * pitchY + (pitchY - 12) / 2);
        await tester.tapAt(center);
        expect(picked, i, reason: 'cell $i');
      }
    });
  }

  group('parental gate', () {
    setUp(resetParentalGateLock);

    // Same seed and same shuffle as the gate, so the test knows the task.
    List<int> taskFor(int seed) => (List<int>.generate(9, (i) => i + 1)..shuffle(math.Random(seed))).take(4).toList();

    Future<bool?> openGate(WidgetTester tester, int seed) async {
      bool? result;
      await tester.pumpWidget(_app(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async => result = await showParentalGate(context, random: math.Random(seed)),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('tapping the written numbers in order lets a grown-up in', (tester) async {
      bool? result;
      await tester.pumpWidget(_app(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async => result = await showParentalGate(context, random: math.Random(7)),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      for (final d in taskFor(7)) {
        await tester.tap(find.byKey(ValueKey('gate-digit-$d')));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('a wrong number starts over with a new task', (tester) async {
      await openGate(tester, 7);
      final task = taskFor(7);
      final wrong = List<int>.generate(9, (i) => i + 1).firstWhere((d) => d != task.first);

      await tester.tap(find.byKey(ValueKey('gate-digit-$wrong')));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ParentalGate), findsOneWidget, reason: 'the gate stays shut');
    });

    testWidgets('closing the gate answers no', (tester) async {
      bool? result;
      await tester.pumpWidget(_app(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async => result = await showParentalGate(context, random: math.Random(1)),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
