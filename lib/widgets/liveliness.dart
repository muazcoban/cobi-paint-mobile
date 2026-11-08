import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The pose of a finished picture while it "comes alive" (council, 8 Nov
/// 2026, P8): the whole card takes two small breaths and sways a little.
/// [t] runs from 0 to 1 over [Liveliness.duration].
///
/// Pure arithmetic, no randomness: every finished page moves the same way,
/// on every device. The scale peaks twice (sin² of a full turn), the sway is
/// two full swings under a sin envelope, so both start and end at rest with
/// a zero slope: no jump at either end.
({double scale, double angle}) livelinessPose(double t) {
  final breath = math.sin(2 * math.pi * t);
  final scale = 1 + maxScaleGain * breath * breath;
  final angle = maxAngle * math.sin(4 * math.pi * t) * math.sin(math.pi * t);
  return (scale: scale, angle: angle);
}

/// The card grows by at most 3%.
const double maxScaleGain = 0.03;

/// The card tilts by at most 1.5° (radians). With the 3% a 351 pt card
/// overflows its 12 pt slot by 10 pt at most, so it never covers a button.
const double maxAngle = 1.5 * math.pi / 180;

/// Starts and stops the motion of a [Liveliness] from outside.
class LivelinessController extends ChangeNotifier {
  int _plays = 0;
  int _settles = 0;

  int get plays => _plays;
  int get settles => _settles;

  /// Plays the motion once from the start.
  void play() {
    _plays++;
    notifyListeners();
  }

  /// Brings the card back to rest within [Liveliness.settleDuration]; a
  /// touch anywhere calls this, so a child never waits for the motion.
  void settle() {
    _settles++;
    notifyListeners();
  }
}

/// Wraps the canvas card and moves it with [livelinessPose] when the
/// controller plays. Nothing underneath is redrawn: the child keeps its own
/// repaint boundary and only its raster is transformed.
///
/// With [enabled] false (Reduce Motion) the card never moves and the pose
/// stays the identity, whatever the controller says.
class Liveliness extends StatefulWidget {
  const Liveliness({
    super.key,
    required this.controller,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 2000),
  });

  final LivelinessController controller;
  final Widget child;
  final bool enabled;
  final Duration duration;

  /// How long the card takes to come back to rest after a touch.
  static const settleDuration = Duration(milliseconds: 120);

  /// With Reduce Motion the card keeps still and a ring on its edge fades in
  /// and out once instead, so the finish is still seen (and heard).
  static const ringDuration = Duration(milliseconds: 600);
  static const ringColor = Color(0xFFFFB300);
  static const ringKey = ValueKey('liveliness-ring');

  @override
  State<Liveliness> createState() => _LivelinessState();
}

class _LivelinessState extends State<Liveliness> with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  int _plays = 0;
  int _settles = 0;

  // While settling, the pose goes from where the touch found it to rest.
  bool _settling = false;
  ({double scale, double angle}) _settleFrom = (scale: 1, angle: 0);

  // The still ring of Reduce Motion is running instead of the motion.
  bool _ring = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: widget.duration);
    _plays = widget.controller.plays;
    _settles = widget.controller.settles;
    widget.controller.addListener(_onCommand);
  }

  @override
  void didUpdateWidget(Liveliness oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onCommand);
      _plays = widget.controller.plays;
      _settles = widget.controller.settles;
      widget.controller.addListener(_onCommand);
    }
    if (!widget.enabled && _animation.isAnimating) {
      _animation.stop();
      _animation.value = 0;
      _settling = false;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCommand);
    _animation.dispose();
    super.dispose();
  }

  void _onCommand() {
    final controller = widget.controller;
    if (controller.settles != _settles) {
      _settles = controller.settles;
      _plays = controller.plays;
      _settle();
    } else if (controller.plays != _plays) {
      _plays = controller.plays;
      _play();
    }
  }

  void _play() {
    _settling = false;
    _ring = !widget.enabled;
    _animation
      ..stop()
      ..duration = _ring ? Liveliness.ringDuration : widget.duration
      ..forward(from: 0);
  }

  void _settle() {
    if (!_animation.isAnimating || _ring) return;
    _settleFrom = _pose;
    _settling = true;
    _animation
      ..stop()
      ..duration = Liveliness.settleDuration
      ..forward(from: 0);
  }

  /// The pose right now: at rest, breathing, or on the way back to rest.
  ({double scale, double angle}) get _pose {
    if (_ring || (!_animation.isAnimating && !_settling)) return (scale: 1, angle: 0);
    if (_settling) {
      final k = 1 - Curves.easeOut.transform(_animation.value);
      if (_animation.isCompleted) return (scale: 1, angle: 0);
      return (scale: 1 + (_settleFrom.scale - 1) * k, angle: _settleFrom.angle * k);
    }
    return livelinessPose(_animation.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        if (_ring && _animation.isAnimating) {
          // Opacity rises and falls once over the ring's 600 ms: a fade, not a blink.
          final opacity = math.sin(math.pi * _animation.value).clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.passthrough,
            children: [
              child!,
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child: DecoratedBox(
                      key: Liveliness.ringKey,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Liveliness.ringColor, width: 6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        final pose = _pose;
        if (pose.scale == 1 && pose.angle == 0) return child!;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scaleByDouble(pose.scale, pose.scale, 1, 1)
            ..rotateZ(pose.angle),
          child: child,
        );
      },
    );
  }
}
