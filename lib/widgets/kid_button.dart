import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Extra margin around a control in which a lifted finger still counts.
const double forgivingSlop = 12;

/// Fires [onTap] when the finger that went down on the child lifts anywhere
/// within [forgivingSlop] of it, however far it wandered in between.
/// Flutter's own tap recognizer gives up after 18 lp of movement, which a
/// three-year-old's tap often exceeds.
class ForgivingTap extends StatefulWidget {
  const ForgivingTap({
    super.key,
    required this.child,
    required this.onTap,
    this.onPressedChanged,
  });

  final Widget child;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onPressedChanged;

  @override
  State<ForgivingTap> createState() => _ForgivingTapState();
}

class _ForgivingTapState extends State<ForgivingTap> {
  int? _pointer;

  void _down(PointerDownEvent e) {
    if (_pointer != null || widget.onTap == null) return;
    _pointer = e.pointer;
    widget.onPressedChanged?.call(true);
  }

  void _up(PointerUpEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    widget.onPressedChanged?.call(false);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final area = (Offset.zero & box.size).inflate(forgivingSlop);
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
  });

  final IconData? icon;

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
                HapticFeedback.selectionClick();
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
              child: Center(
                child: SizedBox.square(
                  dimension: widget.size * 0.56,
                  child: widget.child ?? Icon(widget.icon, size: widget.size * 0.5, color: widget.iconColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    final body = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w * 0.95, height: w * 0.45), Radius.circular(w * 0.08));
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
