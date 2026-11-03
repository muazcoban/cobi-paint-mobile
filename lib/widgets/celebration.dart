import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Short confetti burst over the whole screen when a picture is finished.
/// Skipped when the system asks for reduced motion.
Future<void> showCelebration(BuildContext context, {Duration duration = const Duration(milliseconds: 1400)}) async {
  if (reduceMotion(context)) return;
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  final done = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => IgnorePointer(
      child: _Confetti(
        duration: duration,
        onDone: () {
          entry.remove();
          if (!done.isCompleted) done.complete();
        },
      ),
    ),
  );
  overlay.insert(entry);
  return done.future;
}

class _Confetti extends StatefulWidget {
  const _Confetti({required this.duration, required this.onDone});

  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  static const _colors = [
    Color(0xFFE53935), Color(0xFFFB8C00), Color(0xFFFDD835), Color(0xFF43A047),
    Color(0xFF1E88E5), Color(0xFF8E24AA), Color(0xFFEC407A),
  ];

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _pieces = List.generate(70, (i) {
      return _Piece(
        x: random.nextDouble(),
        delay: random.nextDouble() * 0.35,
        speed: 0.8 + random.nextDouble() * 0.6,
        sway: (random.nextDouble() - 0.5) * 0.12,
        spin: (random.nextDouble() - 0.5) * 12,
        size: 8 + random.nextDouble() * 10,
        color: _colors[i % _colors.length],
        round: random.nextBool(),
      );
    });
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ConfettiPainter(_controller, _pieces),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.sway,
    required this.spin,
    required this.size,
    required this.color,
    required this.round,
  });

  final double x;
  final double delay;
  final double speed;
  final double sway;
  final double spin;
  final double size;
  final Color color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress, this.pieces) : super(repaint: progress);

  final Animation<double> progress;
  final List<_Piece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = -0.1 + local * p.speed * 1.2;
      final x = p.x + math.sin(local * math.pi * 3) * p.sway;
      final opacity = local > 0.85 ? (1 - local) / 0.15 : 1.0;
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(local * p.spin);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}
