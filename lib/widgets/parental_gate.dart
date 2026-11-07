import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/voice_service.dart';
import 'motion.dart';

/// Shows an adult-level check before anything that leaves the coloring
/// world: sharing, settings, deleting, purchases, links. Returns true when
/// a grown-up passed it.
///
/// The task is a multiplication with a two-digit answer (2-9 x 2-9, product
/// at least 10) entered as two digits: a grown-up task in any language, and
/// a child who matches shapes cannot pass it by tapping what is on screen.
/// The factors change every time so it cannot be learned by heart. From the
/// third wrong answer on, the gate locks for 30, 60 and then 120 seconds; it
/// closes itself after 20 seconds without a tap.
Future<bool> showParentalGate(BuildContext context, {math.Random? random}) async {
  // Apple's Kids guidance: tell a child who cannot read to fetch a grown-up.
  unawaited(VoiceService().say(
    'gate',
    languageCode: Localizations.localeOf(context).languageCode,
    screenReader: MediaQuery.accessibleNavigationOf(context),
  ));
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
  // A multiplication with a two-digit answer (2-9 x 2-9, product >= 10):
  // a grown-up task in any language, and a child who matches shapes cannot
  // pass it by tapping what is on screen.
  late int _a;
  late int _b;
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
    do {
      _a = 2 + widget.random.nextInt(8);
      _b = 2 + widget.random.nextInt(8);
    } while (_a * _b < 10);
    _entered.clear();
  }

  void _press(int digit) {
    _resetIdle();
    if (_secondsLocked > 0) return;
    setState(() {
      _entered.add(digit);
      if (_entered.length < 2) return;
      if (_entered[0] * 10 + _entered[1] != _a * _b) {
        _wrongAnswers++;
        if (_wrongAnswers >= 3) {
          final wait = 30 * (1 << math.min(_wrongAnswers - 3, 2)); // 30, 60, 120 s
          _lockedUntil = DateTime.now().add(Duration(seconds: wait));
          _startLockTicker();
        }
        if (!reduceMotion(context)) _shake.forward(from: 0);
        _newTask();
      } else {
        _wrongAnswers = 0;
        _lockedUntil = null;
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final task = '$_a × $_b = ?';
    final theme = Theme.of(context);
    final locked = _secondsLocked;

    // The keypad keeps its size; its digits grow with the text size only as
    // far as they fit their 64 pt keys. The rest follows the text size up
    // to the app's 200% cap, and the dialog scrolls when that no longer fits
    // a small phone.
    final textScaler = MediaQuery.textScalerOf(context);
    return AlertDialog(
      scrollable: true,
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
              key: const ValueKey('gate-task'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 2; i++)
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final row in const [[1, 2, 3], [4, 5, 6], [7, 8, 9], [0]])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          // The lone zero sits under the middle column.
                          if (row.length == 1) const Spacer(),
                          for (final d in row)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: SizedBox(
                                  height: 64,
                                  child: OutlinedButton(
                                  key: ValueKey('gate-digit-$d'),
                                  // Dark digits: the theme's coral on the tinted dialog
                                  // measured 2.2:1, below the 3:1 HIG minimum.
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF2D3142),
                                    side: const BorderSide(color: Color(0x662D3142)),
                                  ),
                                    onPressed: locked > 0 ? null : () => _press(d),
                                    child: Text(
                                      '$d',
                                      textScaler: textScaler.clamp(maxScaleFactor: 1.5),
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (row.length == 1) const Spacer(),
                        ],
                      ),
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
