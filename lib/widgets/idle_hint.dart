import 'package:flutter/material.dart';

import 'motion.dart';

/// A soft pulsing ring with the mascot, laid over the canvas at the spot a
/// child could tap. It only shows; it never paints, saves or counts as the
/// child's work. Static when Reduce Motion is on.
class IdleHint extends StatefulWidget {
  const IdleHint({super.key, required this.at});

  /// Where to point, as a fraction of the canvas (0..1 on each axis).
  final Offset at;

  @override
  State<IdleHint> createState() => _IdleHintState();
}

class _IdleHintState extends State<IdleHint> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (reduceMotion(context)) {
        _pulse.value = 0.5;
      } else {
        _pulse.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Align(
          alignment: Alignment(widget.at.dx * 2 - 1, widget.at.dy * 2 - 1),
          child: SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => Container(
                    width: 70 + 50 * _pulse.value,
                    height: 70 + 50 * _pulse.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.35 - 0.2 * _pulse.value),
                      border: Border.all(color: const Color(0xFFFFB300), width: 4),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: ClipOval(child: Image.asset('assets/images/app_icon.png', width: 56, height: 56)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
