import 'dart:math' as math;

import 'package:cobi_paint_mobile/widgets/liveliness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The scale the card is drawn at: 1 when no Transform is in the tree.
double _scaleOf(WidgetTester tester) {
  final transforms = find.descendant(of: find.byType(Liveliness), matching: find.byType(Transform));
  if (transforms.evaluate().isEmpty) return 1;
  return tester.widget<Transform>(transforms.first).transform.getMaxScaleOnAxis();
}

void main() {
  group('pose (council P8, 8 Nov 2026)', () {
    test('starts and ends at rest', () {
      for (final t in [0.0, 1.0]) {
        final pose = livelinessPose(t);
        expect(pose.scale, closeTo(1, 1e-9), reason: 't=$t');
        expect(pose.angle, closeTo(0, 1e-9), reason: 't=$t');
      }
    });

    test('never grows past 3% or tilts past 1.5 degrees', () {
      for (var i = 0; i <= 1000; i++) {
        final pose = livelinessPose(i / 1000);
        expect(pose.scale, inInclusiveRange(1, 1.03 + 1e-9));
        expect(pose.angle.abs(), lessThanOrEqualTo(1.5 * math.pi / 180 + 1e-9));
      }
    });

    test('takes exactly two breaths', () {
      var peaks = 0;
      var last = livelinessPose(0).scale;
      var rising = false;
      for (var i = 1; i <= 2000; i++) {
        final scale = livelinessPose(i / 2000).scale;
        if (scale > last) {
          rising = true;
        } else if (scale < last && rising) {
          peaks++;
          rising = false;
        }
        last = scale;
      }
      expect(peaks, 2);
    });

    test('moves smoothly: no frame jumps more than 0.4% in scale or 0.3 degrees', () {
      const frames = 2000 ~/ 16; // 16 ms frames over the 2 s motion
      var previous = livelinessPose(0);
      for (var i = 1; i <= frames; i++) {
        final pose = livelinessPose(i / frames);
        expect((pose.scale - previous.scale).abs(), lessThan(0.004));
        expect((pose.angle - previous.angle).abs(), lessThan(0.3 * math.pi / 180));
        previous = pose;
      }
    });
  });

  Widget app(LivelinessController controller, {bool enabled = true}) => MaterialApp(
    home: Center(
      child: Liveliness(
        controller: controller,
        enabled: enabled,
        child: const SizedBox(width: 100, height: 100, child: ColoredBox(color: Colors.white)),
      ),
    ),
  );

  testWidgets('play moves the card and it comes back to rest on its own', (tester) async {
    final controller = LivelinessController();
    await tester.pumpWidget(app(controller));
    expect(_scaleOf(tester), 1);

    controller.play();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(_scaleOf(tester), greaterThan(1.01), reason: 'the first breath peaks at 500 ms');

    await tester.pump(const Duration(milliseconds: 1600));
    expect(_scaleOf(tester), 1, reason: 'at rest after 2 s');
  });

  testWidgets('a touch settles the card within 120 ms, without a jump', (tester) async {
    final controller = LivelinessController();
    await tester.pumpWidget(app(controller));
    controller.play();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final before = _scaleOf(tester);
    expect(before, greaterThan(1.01));

    controller.settle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final midway = _scaleOf(tester);
    expect(midway, lessThan(before), reason: 'on the way back');
    expect(midway, greaterThan(1), reason: 'not snapped to rest in one frame');

    await tester.pump(const Duration(milliseconds: 120));
    expect(_scaleOf(tester), 1);
  });

  testWidgets('with Reduce Motion the card never moves; a still ring fades in and out once', (tester) async {
    final controller = LivelinessController();
    await tester.pumpWidget(app(controller, enabled: false));
    expect(find.byKey(Liveliness.ringKey), findsNothing);
    controller.play();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_scaleOf(tester), 1);
    expect(find.descendant(of: find.byType(Liveliness), matching: find.byType(Transform)), findsNothing);
    expect(find.byKey(Liveliness.ringKey), findsOneWidget, reason: 'the ring is at its brightest');
    expect(
      tester.widget<Opacity>(find.ancestor(of: find.byKey(Liveliness.ringKey), matching: find.byType(Opacity))).opacity,
      greaterThan(0.9),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(Liveliness.ringKey), findsNothing, reason: 'gone after 600 ms');
  });

  testWidgets('disposing in the middle of the motion is fine', (tester) async {
    final controller = LivelinessController();
    await tester.pumpWidget(app(controller));
    controller.play();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
