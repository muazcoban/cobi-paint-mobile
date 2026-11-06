import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/render/symmetry.dart';
import '../services/haptics.dart';

/// Extra margin around a control in which a lifted finger still counts.
const double forgivingSlop = 12;

/// Fires [onTap] when the finger that went down on the child lifts anywhere
/// within [forgivingSlop] of it, however far it wandered in between.
/// Flutter's own tap recognizer gives up after 18 lp of movement, which a
/// three-year-old's tap often exceeds.
///
/// A finger that scrolled the list the child sits in is a scroll, not a
/// tap: if any scrollable around the child moved more than [forgivingSlop]
/// between down and up, nothing fires. Pointer events keep the position the
/// child had at pointer down, so without this a short swipe on a card
/// opened it.
class ForgivingTap extends StatefulWidget {
  const ForgivingTap({super.key, required this.child, required this.onTap, this.onPressedChanged, this.maxHold});

  final Widget child;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onPressedChanged;

  /// When set, a press held longer than this is not a tap (it was a long
  /// press handled elsewhere).
  final Duration? maxHold;

  @override
  State<ForgivingTap> createState() => _ForgivingTapState();
}

class _ForgivingTapState extends State<ForgivingTap> {
  int? _pointer;
  Duration _downAt = Duration.zero;
  List<(ScrollPosition, double)> _downScroll = const [];

  /// Every scrollable around the child with its offset now.
  List<(ScrollPosition, double)> _scrollOffsets() {
    final offsets = <(ScrollPosition, double)>[];
    var scrollable = context.findAncestorStateOfType<ScrollableState>();
    while (scrollable != null) {
      offsets.add((scrollable.position, scrollable.position.pixels));
      scrollable = scrollable.context.findAncestorStateOfType<ScrollableState>();
    }
    return offsets;
  }

  void _down(PointerDownEvent e) {
    if (_pointer != null || widget.onTap == null) return;
    _pointer = e.pointer;
    _downAt = e.timeStamp;
    _downScroll = _scrollOffsets();
    widget.onPressedChanged?.call(true);
  }

  void _up(PointerUpEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    widget.onPressedChanged?.call(false);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    if (_downScroll.any((s) => (s.$1.pixels - s.$2).abs() > forgivingSlop)) return;
    final area = (Offset.zero & box.size).inflate(forgivingSlop);
    final maxHold = widget.maxHold;
    if (maxHold != null && e.timeStamp - _downAt > maxHold) return;
    if (area.contains(e.localPosition)) widget.onTap?.call();
  }

  void _cancel(PointerCancelEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    widget.onPressedChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: _cancel,
      child: widget.child,
    );
  }
}

/// Big round button for small fingers: no text, a clear selected state, a
/// squish on press and a haptic tick.
class KidButton extends StatefulWidget {
  const KidButton({
    super.key,
    this.icon,
    this.child,
    required this.onTap,
    this.size = 82,
    this.color = Colors.white,
    this.iconColor = const Color(0xFF2D3142),
    this.selected = false,
    this.enabled = true,
    this.semanticLabel,
    this.badgeColor,
    this.badgeRainbow = false,
  });

  final IconData? icon;

  /// Small dot in the corner showing e.g. the colour a tool will paint with;
  /// the icon itself stays dark so it is always readable.
  final Color? badgeColor;

  /// A rainbow dot instead of one colour (the rainbow brush).
  final bool badgeRainbow;

  /// Custom glyph used instead of [icon].
  final Widget? child;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final Color iconColor;
  final bool selected;
  final bool enabled;

  /// Read out by screen readers; the child never sees it.
  final String? semanticLabel;

  @override
  State<KidButton> createState() => _KidButtonState();
}

class _KidButtonState extends State<KidButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.88 : (widget.selected ? 1.08 : 1.0);
    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      onTap: widget.enabled ? widget.onTap : null,
      child: ForgivingTap(
        onPressedChanged: (pressed) => setState(() => _pressed = pressed),
        onTap: widget.enabled
            ? () {
                Haptics.selection();
                widget.onTap();
              }
            : null,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: widget.enabled ? 1 : 0.35,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.selected ? const Color(0xFF2D3142) : Colors.black12,
                  width: widget.selected ? 4 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: widget.selected ? 0.25 : 0.12),
                    blurRadius: widget.selected ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: SizedBox.square(
                      dimension: widget.size * 0.56,
                      child: widget.child ?? Icon(widget.icon, size: widget.size * 0.5, color: widget.iconColor),
                    ),
                  ),
                  if (widget.badgeColor != null || widget.badgeRainbow)
                    Positioned(
                      right: widget.size * 0.06,
                      bottom: widget.size * 0.06,
                      child: Container(
                        width: widget.size * 0.3,
                        height: widget.size * 0.3,
                        decoration: BoxDecoration(
                          color: widget.badgeRainbow ? null : widget.badgeColor,
                          gradient: widget.badgeRainbow
                              ? const SweepGradient(colors: [
                                  Color(0xFFE53935),
                                  Color(0xFFFB8C00),
                                  Color(0xFFFDD835),
                                  Color(0xFF43A047),
                                  Color(0xFF1E88E5),
                                  Color(0xFF8E24AA),
                                  Color(0xFFE53935),
                                ])
                              : null,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2D3142), width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tile that shrinks while pressed and taps with the same forgiveness as
/// [KidButton]. [onLongPress] is for grown-up actions.
class PressableCard extends StatefulWidget {
  const PressableCard({super.key, required this.child, required this.onTap, this.onLongPress, this.semanticLabel});

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    Widget card = ForgivingTap(
      onPressedChanged: (pressed) => setState(() => _pressed = pressed),
      maxHold: widget.onLongPress == null ? null : const Duration(milliseconds: 450),
      onTap: () {
        Haptics.selection();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
    if (widget.onLongPress != null) {
      card = GestureDetector(onLongPress: widget.onLongPress, child: card);
    }
    return Semantics(button: true, label: widget.semanticLabel, onTap: widget.onTap, child: card);
  }
}

/// One petal and its mirror copies: the icon shows what the mirror does to
/// a stroke, so it explains itself without words. One petal means off.
class MirrorGlyph extends StatelessWidget {
  const MirrorGlyph({super.key, required this.ways, this.color = const Color(0xFF2D3142)});

  /// Copies the mirror makes (see [symmetryWays]).
  final int ways;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _MirrorPainter(ways, color));
}

class _MirrorPainter extends CustomPainter {
  _MirrorPainter(this.ways, this.color);

  final int ways;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    // A leaf pointing up, leaning right of the vertical mirror line: 45
    // degrees makes a four-way mirror a clover, 30 degrees makes a six-way
    // mirror a flower with its petals 60 degrees apart.
    final lean = ways == 4 ? math.pi / 4 : math.pi / 6;
    final leaf = Path()
      ..moveTo(0, -u * 0.06)
      ..quadraticBezierTo(-u * 0.15, -u * 0.26, 0, -u * 0.48)
      ..quadraticBezierTo(u * 0.15, -u * 0.26, 0, -u * 0.06)
      ..close();
    final paint = Paint()..color = color;
    for (final transform in symmetryTransforms(ways, c.dx, c.dy)) {
      canvas.save();
      canvas.transform(transform.storage);
      canvas.translate(c.dx, c.dy);
      canvas.rotate(lean);
      canvas.drawPath(leaf, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MirrorPainter oldDelegate) => oldDelegate.ways != ways || oldDelegate.color != color;
}

/// A pink-and-white eraser block; Material has no eraser a child would know.
class EraserGlyph extends StatelessWidget {
  const EraserGlyph({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _EraserPainter());
}

class _EraserPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas.translate(w / 2, size.height / 2);
    canvas.rotate(-0.6);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.95, height: w * 0.45),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFF48FB1));
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(Rect.fromLTRB(w * 0.12, -w, w, w), Paint()..color = const Color(0xFFE3F2FD));
    canvas.restore();
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.06
        ..color = const Color(0xFF2D3142),
    );
  }

  @override
  bool shouldRepaint(_EraserPainter oldDelegate) => false;
}

/// A puff of dots, the spray brush's mark.
class SprayGlyph extends StatelessWidget {
  const SprayGlyph({super.key, this.color = const Color(0xFF2D3142)});

  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _SprayPainter(color));
}

class _SprayPainter extends CustomPainter {
  _SprayPainter(this.color);

  final Color color;

  /// Dot centres and radii as fractions of the glyph, crowding the middle
  /// the way the brush does.
  static const _dots = <(double, double, double)>[
    (0.50, 0.50, 0.11),
    (0.36, 0.44, 0.08),
    (0.63, 0.40, 0.085),
    (0.45, 0.66, 0.08),
    (0.62, 0.62, 0.07),
    (0.28, 0.58, 0.06),
    (0.52, 0.30, 0.06),
    (0.72, 0.52, 0.055),
    (0.36, 0.76, 0.05),
    (0.20, 0.42, 0.045),
    (0.78, 0.32, 0.045),
    (0.66, 0.78, 0.045),
    (0.24, 0.26, 0.04),
    (0.82, 0.70, 0.035),
    (0.50, 0.86, 0.035),
    (0.14, 0.70, 0.03),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.shortestSide;
    final paint = Paint()..color = color;
    for (final (x, y, r) in _dots) {
      canvas.drawCircle(Offset(x * u, y * u), r * u, paint);
    }
  }

  @override
  bool shouldRepaint(_SprayPainter oldDelegate) => oldDelegate.color != color;
}

/// A short glowing line, the neon brush's mark: a core inside a soft halo.
class NeonGlyph extends StatelessWidget {
  const NeonGlyph({super.key, this.color = const Color(0xFF2D3142)});

  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _NeonPainter(color));
}

class _NeonPainter extends CustomPainter {
  _NeonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.shortestSide;
    final path = Path()
      ..moveTo(u * 0.12, u * 0.64)
      ..cubicTo(u * 0.30, u * 0.08, u * 0.52, u * 1.02, u * 0.88, u * 0.36);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final (width, alpha) in const <(double, double)>[(0.38, 0.12), (0.27, 0.2), (0.18, 0.34)]) {
      canvas.drawPath(
        path,
        paint
          ..strokeWidth = u * width
          ..color = color.withValues(alpha: alpha),
      );
    }
    canvas.drawPath(
      path,
      paint
        ..strokeWidth = u * 0.09
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_NeonPainter oldDelegate) => oldDelegate.color != color;
}
