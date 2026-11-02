import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'motion.dart';

/// Shows an adult-level check before anything that leaves the coloring
/// world: sharing, settings, deleting, purchases, links. Returns true when
/// a grown-up passed it.
///
/// The task is four random digits written as words ("four, seven, two,
/// nine") to tap in order, the pattern Apple shows for kids apps: a child
/// who cannot read cannot pass it (about 1 in 3000 by guessing), and the
/// digits change every time so it cannot be learned by heart. Repeated
/// wrong answers add a growing wait; the gate closes itself when idle.
Future<bool> showParentalGate(BuildContext context, {math.Random? random}) async {
  final passed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ParentalGate(random: random ?? math.Random()),
  );
  return passed ?? false;
}

/// Wrong answers persist across openings within one app run.
int _wrongAnswers = 0;
DateTime? _lockedUntil;

class ParentalGate extends StatefulWidget {
  const ParentalGate({
    super.key,
    required this.random,
    this.idleTimeout = const Duration(seconds: 20),
  });

  final math.Random random;
  final Duration idleTimeout;

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> with SingleTickerProviderStateMixin {
  static const _length = 4;

  late List<int> _target;
  final List<int> _entered = [];
  Timer? _idle;
  Timer? _lockTicker;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _newTask();
    // MediaQuery is not available in initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resetIdle();
    });
    _startLockTicker();
  }

  @override
  void dispose() {
    _idle?.cancel();
    _lockTicker?.cancel();
    _shake.dispose();
    super.dispose();
  }

  void _resetIdle() {
    _idle?.cancel();
    if (MediaQuery.maybeAccessibleNavigationOf(context) ?? false) return;
    _idle = Timer(widget.idleTimeout, () {
      if (mounted) Navigator.of(context).pop(false);
    });
  }

  void _startLockTicker() {
    _lockTicker?.cancel();
    if (_secondsLocked == 0) return;
    _lockTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {});
      if (_secondsLocked == 0) timer.cancel();
    });
  }

  int get _secondsLocked {
    final until = _lockedUntil;
    if (until == null) return 0;
    final left = until.difference(DateTime.now()).inSeconds;
    return left > 0 ? left + 1 : 0;
  }

  void _newTask() {
    final digits = List<int>.generate(9, (i) => i + 1)..shuffle(widget.random);
    _target = digits.take(_length).toList();
    _entered.clear();
  }

  void _press(int digit) {
    _resetIdle();
    if (_secondsLocked > 0) return;
    setState(() {
      _entered.add(digit);
      final i = _entered.length - 1;
      if (_entered[i] != _target[i]) {
        _wrongAnswers++;
        if (_wrongAnswers >= 3) {
          final wait = 30 * (1 << math.min(_wrongAnswers - 3, 2)); // 30, 60, 120 s
          _lockedUntil = DateTime.now().add(Duration(seconds: wait));
          _startLockTicker();
        }
        if (!reduceMotion(context)) _shake.forward(from: 0);
        _newTask();
      } else if (_entered.length == _target.length) {
        _wrongAnswers = 0;
        _lockedUntil = null;
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final words = l10n.gateDigitWords.split(',');
    final task = _target.map((d) => words[d].trim()).join(' · ');
    final theme = Theme.of(context);
    final locked = _secondsLocked;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
      title: Row(
        children: [
          Expanded(child: Text(l10n.gateTitle)),
          IconButton(
            tooltip: l10n.cancel,
            iconSize: 28,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.gateInstruction, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              locked > 0 ? '$locked' : task,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _length; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _entered.length ? theme.colorScheme.primary : Colors.black12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _shake,
              builder: (context, child) => Transform.translate(
                offset: Offset(math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value), 0),
                child: child,
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var d = 1; d <= 9; d++)
                    OutlinedButton(
                      key: ValueKey('gate-digit-$d'),
                      onPressed: locked > 0 ? null : () => _press(d),
                      child: Text('$d', style: const TextStyle(fontSize: 26)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clears the wrong-answer counter; for tests.
@visibleForTesting
void resetParentalGateLock() {
  _wrongAnswers = 0;
  _lockedUntil = null;
}
