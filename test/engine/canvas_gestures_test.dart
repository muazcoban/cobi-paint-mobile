import 'package:cobi_paint_mobile/engine/input/canvas_gestures.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what the machine asked the canvas to do.
class _Log {
  final events = <String>[];
  final fills = <Offset>[];
  final scales = <double>[];

  CanvasGestureCallbacks get callbacks => CanvasGestureCallbacks(
        onFill: (p) {
          events.add('fill');
          fills.add(p);
        },
        onStrokeStart: (_) => events.add('strokeStart'),
        onStrokeUpdate: (_) => events.add('strokeUpdate'),
        onStrokeEnd: () => events.add('strokeEnd'),
        onStrokeCancel: () => events.add('strokeCancel'),
        onTransformStart: (_) => events.add('transformStart'),
        onTransformUpdate: (_, s) {
          events.add('transformUpdate');
          scales.add(s);
        },
        onTransformEnd: () => events.add('transformEnd'),
      );
}

Duration ms(int v) => Duration(milliseconds: v);

void main() {
  group('Minik mode (no zoom)', () {
    test('a fill happens on finger down, before the finger lifts', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks);

      machine.pointerDown(1, const Offset(50, 50), ms(0));
      expect(log.events, ['fill']);
      machine.pointerUp(1, const Offset(52, 51), ms(80));
      expect(log.events, ['fill']);
    });

    test('a palm or second finger does nothing while the first finger is down', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks);

      machine.pointerDown(1, const Offset(50, 50), ms(0));
      machine.pointerDown(2, const Offset(200, 300), ms(20));
      machine.pointerMove(2, const Offset(260, 320), ms(40));
      machine.pointerUp(2, const Offset(260, 320), ms(60));
      machine.pointerUp(1, const Offset(50, 50), ms(80));

      expect(log.events, ['fill']);
      expect(machine.isIdle, isTrue);
    });

    test('a stroke keeps going when a second finger lands', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks, tool: CanvasTool.marker);

      machine.pointerDown(1, const Offset(10, 10), ms(0));
      machine.pointerDown(2, const Offset(100, 100), ms(30));
      machine.pointerMove(1, const Offset(40, 10), ms(60));
      machine.pointerUp(1, const Offset(60, 10), ms(90));

      expect(log.events, isNot(contains('strokeCancel')));
      expect(log.events.last, 'strokeEnd');
    });
  });

  group('Büyük mode (zoom allowed)', () {
    test('a tap that slides less than the tap slop still fills where it started', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks, allowTransform: true);

      machine.pointerDown(1, const Offset(50, 50), ms(0));
      machine.pointerMove(1, const Offset(65, 58), ms(50)); // 17 lp
      machine.pointerUp(1, const Offset(65, 58), ms(90));

      expect(log.events, ['fill']);
      expect(log.fills.single, const Offset(50, 50));
    });

    test('two fingers pinch instead of filling', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks, allowTransform: true);

      machine.pointerDown(1, const Offset(100, 100), ms(0));
      machine.pointerDown(2, const Offset(200, 100), ms(40));
      machine.pointerMove(2, const Offset(300, 100), ms(80));
      machine.pointerUp(2, const Offset(300, 100), ms(120));
      machine.pointerUp(1, const Offset(100, 100), ms(130));

      expect(log.events, ['transformStart', 'transformUpdate', 'transformEnd']);
      expect(log.scales.single, closeTo(2, 1e-9));
    });

    test('a second finger right after a stroke starts cancels the stroke', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks, tool: CanvasTool.marker, allowTransform: true);

      machine.pointerDown(1, const Offset(100, 100), ms(0));
      machine.pointerDown(2, const Offset(200, 100), ms(100));

      expect(log.events, ['strokeStart', 'strokeCancel', 'transformStart']);
    });

    test('a second finger after the stroke is under way is ignored', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks, tool: CanvasTool.marker, allowTransform: true);

      machine.pointerDown(1, const Offset(100, 100), ms(0));
      machine.pointerMove(1, const Offset(130, 100), ms(60));
      machine.pointerDown(2, const Offset(300, 300), ms(400));
      machine.pointerUp(1, const Offset(150, 100), ms(450));

      expect(log.events, isNot(contains('strokeCancel')));
      expect(log.events.last, 'strokeEnd');
    });
  });

  test('a cancelled pointer never commits a stroke', () {
    final log = _Log();
    final machine = CanvasGestureMachine(callbacks: log.callbacks, tool: CanvasTool.eraser);

    machine.pointerDown(1, const Offset(10, 10), ms(0));
    machine.pointerMove(1, const Offset(50, 10), ms(50));
    machine.pointerCancel(1);

    expect(log.events, ['strokeStart', 'strokeUpdate', 'strokeCancel']);
    expect(machine.isIdle, isTrue);
  });

  test('a stroke starts drawing on finger down, with no slop swallowed', () {
    final log = _Log();
    final machine = CanvasGestureMachine(callbacks: log.callbacks, tool: CanvasTool.marker);

    machine.pointerDown(1, const Offset(10, 10), ms(0));
    expect(log.events, ['strokeStart']);
  });
}
