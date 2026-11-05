import 'dart:ui';

/// Fill taps a region; marker, eraser and sticker follow the finger (the
/// sticker tool stamps a trail of pictures along the way).
enum CanvasTool { fill, marker, eraser, sticker }

/// What the canvas should do in response to raw pointer events.
class CanvasGestureCallbacks {
  const CanvasGestureCallbacks({
    required this.onFill,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
    required this.onStrokeEnd,
    required this.onStrokeCancel,
    required this.onTransformStart,
    required this.onTransformUpdate,
    required this.onTransformEnd,
  });

  final void Function(Offset position) onFill;
  final void Function(Offset position) onStrokeStart;
  final void Function(Offset position) onStrokeUpdate;
  final void Function() onStrokeEnd;
  final void Function() onStrokeCancel;
  final void Function(Offset focal) onTransformStart;

  /// [scale] is relative to the transform start.
  final void Function(Offset focal, double scale) onTransformUpdate;
  final void Function() onTransformEnd;
}

enum _State { idle, fillPending, strokePending, stroking, transforming, ignoring }

/// Turns raw pointer events into fill taps, brush strokes and pinch/pan,
/// tuned for a three-year-old:
///
/// * Without zoom (Minik mode) a fill happens on finger down, so the result
///   is instant, and every extra finger or palm is ignored.
/// * A finger may slide up to [tapSlop] and still count as a tap.
/// * A stroke shows at once but only becomes permanent after [strokeSlop]
///   of movement or [strokeDelay]; a second finger inside
///   [secondFingerWindow] turns it into a pinch instead (zoom modes only).
/// * A cancelled pointer (system gesture, palm rejection) never commits.
/// * A pen (Apple Pencil) wins over a palm or finger that landed first, and
///   while it draws every other touch is ignored, so a hand resting on the
///   screen neither steals nor pinches the pen's line.
///
/// Listener-based on purpose: it stays out of Flutter's gesture arena, so
/// there is no pan slop that swallows the start of a stroke.
class CanvasGestureMachine {
  CanvasGestureMachine({
    required this.callbacks,
    this.tool = CanvasTool.fill,
    this.allowTransform = false,
    this.tapSlop = 20,
    this.strokeSlop = 8,
    this.strokeDelay = const Duration(milliseconds: 120),
    this.secondFingerWindow = const Duration(milliseconds: 150),
  });

  final CanvasGestureCallbacks callbacks;
  CanvasTool tool;
  bool allowTransform;
  final double tapSlop;
  final double strokeSlop;
  final Duration strokeDelay;
  final Duration secondFingerWindow;

  _State _state = _State.idle;
  final Map<int, Offset> _pointers = {};
  int? _primary;
  bool _primaryIsStylus = false;
  Offset _downPosition = Offset.zero;
  Duration _downTime = Duration.zero;

  // Transform tracking.
  int? _first;
  int? _second;
  double _startDistance = 1;

  bool get isIdle => _state == _State.idle;

  /// [stylus] marks a pen; see the class comment for how it outranks touch.
  void pointerDown(int pointer, Offset position, Duration time, {bool stylus = false}) {
    final isFirst = _pointers.isEmpty;
    final penDrawing = _primaryIsStylus && _primary != null && _pointers.containsKey(_primary);
    _pointers[pointer] = position;

    if (isFirst) {
      _begin(pointer, position, time, stylus);
      return;
    }

    if (stylus && !penDrawing && _state != _State.transforming) {
      // The pen takes over from a palm or finger that landed first: what that
      // touch started is dropped and the pen starts afresh.
      if (_state == _State.strokePending || _state == _State.stroking) callbacks.onStrokeCancel();
      _begin(pointer, position, time, true);
      return;
    }
    if (penDrawing) return; // A palm or finger next to the pen does nothing.

    if (!allowTransform) return; // Minik mode: extra fingers and palms do nothing.
    final early = time - _downTime <= secondFingerWindow;
    switch (_state) {
      case _State.strokePending when early:
        callbacks.onStrokeCancel();
        _startTransform(_primary!, pointer);
      case _State.fillPending:
        _startTransform(_primary!, pointer);
      default:
        break; // A finger or palm landing mid-stroke is ignored.
    }
  }

  /// Makes [pointer] the one that paints, fills or pans.
  void _begin(int pointer, Offset position, Duration time, bool stylus) {
    _primary = pointer;
    _primaryIsStylus = stylus;
    _downPosition = position;
    _downTime = time;
    switch (tool) {
      case CanvasTool.fill:
        if (allowTransform) {
          _state = _State.fillPending;
        } else {
          callbacks.onFill(position);
          _state = _State.ignoring;
        }
      case CanvasTool.marker:
      case CanvasTool.eraser:
      case CanvasTool.sticker:
        callbacks.onStrokeStart(position);
        _state = _State.strokePending;
    }
  }

  void pointerMove(int pointer, Offset position, Duration time) {
    if (!_pointers.containsKey(pointer)) return;
    _pointers[pointer] = position;

    switch (_state) {
      case _State.fillPending when pointer == _primary:
        if ((position - _downPosition).distance > tapSlop) {
          // A long slide while zoom is on pans the page instead of filling.
          _first = pointer;
          _second = null;
          _state = _State.transforming;
          callbacks.onTransformStart(position);
        }
      case _State.strokePending when pointer == _primary:
        callbacks.onStrokeUpdate(position);
        if ((position - _downPosition).distance > strokeSlop || time - _downTime > strokeDelay) {
          _state = _State.stroking;
        }
      case _State.stroking when pointer == _primary:
        callbacks.onStrokeUpdate(position);
      case _State.transforming when pointer == _first || pointer == _second:
        callbacks.onTransformUpdate(_focal(), _scale());
      default:
        break;
    }
  }

  void pointerUp(int pointer, Offset position, Duration time) {
    if (!_pointers.containsKey(pointer)) return;
    _pointers[pointer] = position;

    if (pointer == _primary || pointer == _first || pointer == _second) {
      switch (_state) {
        case _State.fillPending:
          // Generous: the region under the finger-down point is filled.
          callbacks.onFill(_downPosition);
          _state = _State.ignoring;
        case _State.strokePending:
        case _State.stroking:
          if (pointer == _primary) {
            callbacks.onStrokeUpdate(position);
            callbacks.onStrokeEnd();
            _state = _State.ignoring;
          }
        case _State.transforming:
          callbacks.onTransformEnd();
          _state = _State.ignoring;
        default:
          break;
      }
    }
    _remove(pointer);
  }

  void pointerCancel(int pointer) {
    if (!_pointers.containsKey(pointer)) return;
    if (pointer == _primary && (_state == _State.strokePending || _state == _State.stroking)) {
      callbacks.onStrokeCancel();
      _state = _State.ignoring;
    } else if (_state == _State.transforming && (pointer == _first || pointer == _second)) {
      callbacks.onTransformEnd();
      _state = _State.ignoring;
    } else if (pointer == _primary && _state == _State.fillPending) {
      _state = _State.ignoring;
    }
    _remove(pointer);
  }

  void _remove(int pointer) {
    _pointers.remove(pointer);
    if (_pointers.isEmpty) {
      _state = _State.idle;
      _primary = null;
      _primaryIsStylus = false;
      _first = null;
      _second = null;
    }
  }

  void _startTransform(int first, int second) {
    _first = first;
    _second = second;
    _startDistance = (_pointers[first]! - _pointers[second]!).distance;
    if (_startDistance < 1) _startDistance = 1;
    _state = _State.transforming;
    callbacks.onTransformStart(_focal());
  }

  Offset _focal() {
    final a = _pointers[_first];
    final b = _second == null ? null : _pointers[_second];
    if (a == null) return Offset.zero;
    if (b == null) return a;
    return (a + b) / 2;
  }

  double _scale() {
    final a = _pointers[_first];
    final b = _second == null ? null : _pointers[_second];
    if (a == null || b == null) return 1;
    return (a - b).distance / _startDistance;
  }
}
