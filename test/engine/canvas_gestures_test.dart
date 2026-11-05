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

  group('a pen (Apple Pencil)', () {
    test('wins over a palm that landed first, and the palm\'s line goes away', () {
      for (final zoom in [false, true]) {
        final log = _Log();
        final machine = CanvasGestureMachine(callbacks: log.callbacks, tool: CanvasTool.marker, allowTransform: zoom);

        machine.pointerDown(1, const Offset(300, 400), ms(0)); // the palm
        machine.pointerMove(1, const Offset(305, 402), ms(100));
        machine.pointerDown(2, const Offset(50, 50), ms(400), stylus: true);
        machine.pointerMove(2, const Offset(90, 60), ms(420));
        machine.pointerCancel(1); // iPadOS recognises the palm late
        machine.pointerMove(2, const Offset(130, 70), ms(440));
        machine.pointerUp(2, const Offset(140, 70), ms(460));
        machine.pointerUp(1, const Offset(305, 402), ms(480));

        expect(log.events.where((e) => e == 'strokeStart'), hasLength(2), reason: 'zoom $zoom');
        expect(log.events.indexOf('strokeCancel'), lessThan(log.events.lastIndexOf('strokeStart')), reason: 'zoom $zoom');
        expect(log.events.last, 'strokeEnd', reason: 'the pen\'s line is committed (zoom $zoom)');
        expect(log.events, isNot(contains('transformStart')));
        expect(machine.isIdle, isTrue);
      }
    });

    test('a palm landing right after the pen neither pinches nor stops it', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks, tool: CanvasTool.marker, allowTransform: true);

      machine.pointerDown(1, const Offset(50, 50), ms(0), stylus: true);
      machine.pointerDown(2, const Offset(300, 400), ms(30)); // inside the pinch window
      machine.pointerMove(1, const Offset(90, 60), ms(60));
      machine.pointerMove(2, const Offset(320, 420), ms(70));
      machine.pointerUp(1, const Offset(100, 60), ms(90));

      expect(log.events, isNot(contains('strokeCancel')));
      expect(log.events, isNot(contains('transformStart')));
      expect(log.events.last, 'strokeEnd');
    });

    test('draws line after line while the palm stays on the screen', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks, tool: CanvasTool.marker, allowTransform: true);

      machine.pointerDown(1, const Offset(300, 400), ms(0)); // the palm
      for (var k = 0; k < 3; k++) {
        final pen = 10 + k;
        final t0 = 300 + k * 200;
        machine.pointerDown(pen, Offset(50, 50.0 + k * 20), ms(t0), stylus: true);
        machine.pointerMove(pen, Offset(120, 50.0 + k * 20), ms(t0 + 40));
        machine.pointerUp(pen, Offset(130, 50.0 + k * 20), ms(t0 + 80));
      }

      expect(log.events.where((e) => e == 'strokeEnd'), hasLength(3));
    });

    test('does not break into a two-finger pinch', () {
      final log = _Log();
      final machine = CanvasGestureMachine(callbacks: log.callbacks, allowTransform: true);

      machine.pointerDown(1, const Offset(100, 100), ms(0));
      machine.pointerDown(2, const Offset(200, 200), ms(50));
      machine.pointerDown(3, const Offset(150, 300), ms(120), stylus: true);
      machine.pointerMove(2, const Offset(240, 240), ms(150));

      expect(log.events.first, 'transformStart');
      expect(log.events, isNot(contains('fill')));
      expect(log.events, isNot(contains('strokeStart')));
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
