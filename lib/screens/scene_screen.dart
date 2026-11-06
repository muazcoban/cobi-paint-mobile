import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/scene/scene_placement.dart';
import '../l10n/app_localizations.dart';
import '../models/scene.dart';
import '../models/user_settings.dart';
import '../providers/app_provider.dart';
import '../services/haptics.dart';
import '../services/sound_service.dart';
import '../widgets/idle_hint.dart';
import '../widgets/kid_button.dart';
import '../widgets/kid_metrics.dart';
import '../widgets/motion.dart';
import 'coloring_screen.dart';
import 'scene/scene_page.dart';

/// A move longer than this from where the finger came down is a drag; the
/// coloring canvas uses the same slop for a tap (CanvasGestureMachine).
const double _dragSlop = 20;

/// A piece's flight between its tray cell and its slot.
const Duration _flightTime = Duration(milliseconds: 220);

/// The scene mode's rough prototype (council P7): the empty garden and a
/// tray of pieces, nothing else. A tap sends a piece to its own slot, or to
/// the nearest free one; a drag puts it in the free slot nearest the finger.
/// A placed piece stays put and undo sends it back to the tray. There is no
/// colouring here: once every slot has its piece, the scene becomes one page
/// and today's coloring screen opens it. No word is played; in the first
/// observation round a grown-up says the words.
class SceneScreen extends StatefulWidget {
  const SceneScreen({super.key, required this.scene});

  final SceneDefinition scene;

  @override
  State<SceneScreen> createState() => _SceneScreenState();
}

class _Flight {
  _Flight({required this.piece, required this.from, required this.to, required this.controller, required this.fade});

  final ScenePiece piece;
  final Rect from;
  final Rect to;
  final AnimationController controller;

  /// Reduce Motion: the piece fades in where it lands instead of flying.
  final bool fade;
}

/// Where the tray's cells are: cell i owns [pitch] along the tray (its hit
/// area) and shows its picture [cell] square in the middle.
class _TrayGeometry {
  const _TrayGeometry({required this.vertical, required this.pitch, required this.cross, required this.cell});

  final bool vertical;
  final double pitch;
  final double cross;
  final double cell;

  Rect hitRect(int i) => vertical ? Rect.fromLTWH(0, i * pitch, cross, pitch) : Rect.fromLTWH(i * pitch, 0, pitch, cross);

  Rect cellRect(int i) => Rect.fromCenter(center: hitRect(i).center, width: cell, height: cell);

  int? indexAt(Offset local, int count) {
    final along = vertical ? local.dy : local.dx;
    final across = vertical ? local.dx : local.dy;
    if (along < 0 || across < 0 || across > cross) return null;
    final i = (along / pitch).floor();
    return i < count ? i : null;
  }
}

class _SceneScreenState extends State<SceneScreen> with TickerProviderStateMixin {
  final SoundService _sound = SoundService();
  final GlobalKey _bodyKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _trayKey = GlobalKey();

  ScenePlacement? _placement;
  bool? _big;
  _TrayGeometry? _tray;

  // The one finger that holds a piece; others and a palm take nothing (Ç5).
  int? _pointer;
  ScenePiece? _held;
  Offset _downAt = Offset.zero;
  Offset _fingerAt = Offset.zero;
  bool _dragging = false;
  SceneSlot? _target;
  Size? _bodySize;

  final List<_Flight> _flights = [];
  SceneSlot? _glow;
  Timer? _glowTimer;
  Timer? _hintTimer;
  bool _hint = false;
  bool _hintDone = false;
  Timer? _finishTimer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_sound.preload());
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleHint());
  }

  @override
  void dispose() {
    _glowTimer?.cancel();
    _hintTimer?.cancel();
    _finishTimer?.cancel();
    for (final flight in _flights) {
      flight.controller.dispose();
    }
    _placement?.dispose();
    super.dispose();
  }

  /// A new placement when the screen opens and when the age mode changes
  /// under it (Parents area on a tablet): Minik and Büyük have other slots.
  ScenePlacement _placementFor(bool big) {
    if (_placement == null || _big != big) {
      _placement?.dispose();
      _placement = ScenePlacement(widget.scene, big: big);
      _big = big;
      _pointer = null;
      _held = null;
      _dragging = false;
      _target = null;
    }
    return _placement!;
  }

  // Idle hint -----------------------------------------------------------------

  /// After 6 s without a touch on an empty scene, the mascot shows the first
  /// piece in the tray. Minik only, never with a screen reader, and not again
  /// once the child has placed a piece.
  void _scheduleHint() {
    _hintTimer?.cancel();
    if (!mounted || _hintDone || _big != false || MediaQuery.accessibleNavigationOf(context)) return;
    if (!(_placement?.isEmpty ?? false)) return;
    _hintTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && !_hintDone && (_placement?.isEmpty ?? false)) setState(() => _hint = true);
    });
  }

  void _touched() {
    if (_hint) setState(() => _hint = false);
    _scheduleHint();
  }

  // Geometry ------------------------------------------------------------------

  RenderBox? _box(GlobalKey key) => key.currentContext?.findRenderObject() as RenderBox?;

  /// [rect] in [key]'s coordinates, moved into the body's.
  Rect _toBody(GlobalKey key, Rect rect) {
    final from = _box(key)!;
    final body = _box(_bodyKey)!;
    return body.globalToLocal(from.localToGlobal(rect.topLeft)) & rect.size;
  }

  Rect _slotRect(SceneSlot slot) {
    final scale = _box(_canvasKey)!.size.width / widget.scene.size;
    final r = slot.rect;
    return _toBody(_canvasKey, Rect.fromLTWH(r.left * scale, r.top * scale, r.width * scale, r.height * scale));
  }

  Rect _cellRect(ScenePiece piece) => _toBody(_trayKey, _tray!.cellRect(_placement!.pieces.indexOf(piece)));

  Rect _hitRectGlobal(ScenePiece piece) {
    final hit = _tray!.hitRect(_placement!.pieces.indexOf(piece));
    return _box(_trayKey)!.localToGlobal(hit.topLeft) & hit.size;
  }

  /// The piece under the finger: 1.2 times its cell and a little above the
  /// finger, so the finger does not hide it.
  Rect _heldRect() {
    final size = _tray!.cell * 1.2;
    final finger = _box(_bodyKey)!.globalToLocal(_fingerAt);
    return Rect.fromCenter(center: finger - Offset(0, size * 0.6), width: size, height: size);
  }

  /// The free slot nearest the finger, while the finger is over the scene.
  SceneSlot? _dropSlot(Offset global) {
    final canvas = _box(_canvasKey);
    if (canvas == null) return null;
    final local = canvas.globalToLocal(global);
    if (!(Offset.zero & canvas.size).contains(local)) return null;
    return _placement!.nearestFree(local * (widget.scene.size / canvas.size.width));
  }

  // Tray pointer --------------------------------------------------------------

  void _trayDown(PointerDownEvent e) {
    if (_pointer != null || _leaving) return;
    final i = _tray?.indexAt(e.localPosition, _placement!.pieces.length);
    if (i == null) return;
    _pointer = e.pointer;
    _held = _placement!.pieces[i];
    _downAt = e.position;
    _fingerAt = e.position;
    _dragging = false;
  }

  void _trayMove(PointerMoveEvent e) {
    if (e.pointer != _pointer || _held == null) return;
    _fingerAt = e.position;
    if (!_dragging) {
      // A placed piece's cell only shows where the piece is; it never drags.
      if (_placement!.isPlaced(_held!) || (e.position - _downAt).distance <= _dragSlop) return;
      _dragging = true;
    }
    setState(() => _target = _dropSlot(e.position));
  }

  void _trayUp(PointerUpEvent e) {
    if (e.pointer != _pointer) return;
    final piece = _held;
    final dragging = _dragging;
    final from = dragging ? _heldRect() : null;
    _releaseHold();
    if (piece == null) return;
    if (!dragging) {
      _tapPiece(piece);
    } else if (_hitRectGlobal(piece).inflate(forgivingSlop).contains(e.position)) {
      // Let go on its own cell or within 12 pt of it: that was a tap (Ç4).
      _tapPiece(piece, from: from);
    } else {
      final slot = _dropSlot(e.position);
      if (slot != null) {
        _place(piece, slot, from: from!);
      } else {
        // Anywhere else in the tray or off the scene: quietly back home.
        _fly(piece, from: from!, to: _cellRect(piece));
      }
    }
  }

  void _trayCancel(PointerCancelEvent e) {
    if (e.pointer != _pointer) return;
    final piece = _held;
    final from = _dragging ? _heldRect() : null;
    _releaseHold();
    if (piece != null && from != null) _fly(piece, from: from, to: _cellRect(piece));
  }

  void _releaseHold() {
    setState(() {
      _pointer = null;
      _held = null;
      _dragging = false;
      _target = null;
    });
  }

  // Actions -------------------------------------------------------------------

  /// A tap on a piece in the tray (or a screen reader's activation): it goes
  /// to its own slot, or the nearest free one. A placed piece's cell lights
  /// the piece in the scene for 0.6 s instead; no word, no move.
  void _tapPiece(ScenePiece piece, {Rect? from}) {
    if (_leaving) return;
    final placement = _placement!;
    final placedIn = placement.slotOf(piece);
    if (placedIn != null) {
      _showGlow(placedIn);
      return;
    }
    final slot = placement.slotForTap(piece);
    if (slot != null) _place(piece, slot, from: from ?? _cellRect(piece));
  }

  void _place(ScenePiece piece, SceneSlot slot, {required Rect from}) {
    _placement!.place(piece, slot);
    _hintDone = true;
    _hintTimer?.cancel();
    _hint = false;
    unawaited(_sound.playFillSound());
    Haptics.light();
    _fly(piece, from: from, to: _slotRect(slot));
    _afterPlacement();
  }

  void _undo() {
    if (_leaving) return;
    final step = _placement?.undo();
    if (step == null) return;
    _finishTimer?.cancel();
    unawaited(_sound.playUndoSound());
    _fly(step.piece, from: _slotRect(step.slot), to: _cellRect(step.piece));
  }

  void _redo() {
    if (_leaving) return;
    final step = _placement?.redo();
    if (step == null) return;
    unawaited(_sound.playFillSound());
    Haptics.light();
    _fly(step.piece, from: _cellRect(step.piece), to: _slotRect(step.slot));
    _afterPlacement();
  }

  void _fly(ScenePiece piece, {required Rect from, required Rect to}) {
    for (final old in _flights.where((f) => f.piece == piece).toList()) {
      _flights.remove(old);
      old.controller.dispose();
    }
    final fade = reduceMotion(context);
    final controller = AnimationController(vsync: this, duration: _flightTime);
    final flight = _Flight(piece: piece, from: fade ? to : from, to: to, controller: controller, fade: fade);
    controller.addStatusListener((status) {
      if (status != AnimationStatus.completed || !_flights.contains(flight)) return;
      setState(() => _flights.remove(flight));
      controller.dispose();
    });
    setState(() => _flights.add(flight));
    unawaited(controller.forward());
  }

  bool _inFlight(ScenePiece piece) => _flights.any((f) => f.piece == piece);

  void _showGlow(SceneSlot slot) {
    unawaited(_sound.playClickSound());
    _glowTimer?.cancel();
    setState(() => _glow = slot);
    _glowTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _glow = null);
    });
  }

  /// Every slot has its piece: the child sees the full scene for a moment,
  /// then it opens for colouring. An undo in between stops that.
  void _afterPlacement() {
    if (!_placement!.isComplete) return;
    _finishTimer?.cancel();
    _finishTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted && (_placement?.isComplete ?? false)) unawaited(_openColoring());
    });
  }

  Future<void> _openColoring() async {
    if (_leaving) return;
    // Undo and the tray stop here: the page is made from the scene as it is.
    setState(() => _leaving = true);
    final app = context.read<AppProvider>();
    final navigator = Navigator.of(context);
    try {
      final bytes = await composeScenePage(_placement!);
      final at = DateTime.now();
      final file = await app.storageService.writeScenePage('${widget.scene.id}_${at.millisecondsSinceEpoch}', bytes);
      if (!mounted) return;
      final page = scenePageImage(widget.scene, file, at);
      unawaited(navigator.pushReplacement(PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => ColoringScreen(image: page),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      )));
    } catch (e) {
      // The scene stays on screen; nothing is lost.
      debugPrint('Scene page could not be made: $e');
      if (mounted) setState(() => _leaving = false);
    }
  }

  void _goHome() {
    if (_leaving) return;
    _leaving = true;
    _finishTimer?.cancel();
    unawaited(_sound.playClickSound());
    Navigator.of(context).pop();
  }

  // Layout --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final big = context.select<AppProvider, AgeMode>((p) => p.settings.ageMode) == AgeMode.big;
    _placementFor(big);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              if (_bodySize != null && _bodySize != size && _held != null) {
                // The window changed under a drag: the piece stays in its cell.
                _pointer = null;
                _held = null;
                _dragging = false;
                _target = null;
              }
              _bodySize = size;
              final m = KidMetrics(size, big);
              final wide = size.width > size.height * 1.1;
              return Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _touched(),
                child: Stack(
                  key: _bodyKey,
                  children: [
                    Positioned.fill(child: wide ? _wideLayout(m, big) : _tallLayout(m, big)),
                    Positioned.fill(child: _overlay()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _tallLayout(KidMetrics m, bool big) {
    final controls = _controls(m, big);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(children: [controls.first, const Spacer(), ..._spaced(controls.skip(1), m.gap, vertical: false)]),
        ),
        Expanded(child: Padding(padding: const EdgeInsets.all(12), child: _canvas())),
        Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), child: _trayWidget(m, big, vertical: false)),
      ],
    );
  }

  Widget _wideLayout(KidMetrics m, bool big) {
    final controls = _controls(m, big);
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [controls.first, const Spacer(), ..._spaced(controls.skip(1), m.gap, vertical: true)]),
        ),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: _canvas())),
        Padding(padding: const EdgeInsets.all(12), child: _trayWidget(m, big, vertical: true)),
      ],
    );
  }

  List<Widget> _spaced(Iterable<Widget> items, double gap, {required bool vertical}) => [
        for (final (i, item) in items.indexed) ...[
          if (i > 0) SizedBox(width: vertical ? 0 : gap, height: vertical ? gap : 0),
          item,
        ],
      ];

  /// Home and undo, plus redo in Büyük. The bucket and the brush come with
  /// colouring, in the coloring screen the scene opens in.
  List<Widget> _controls(KidMetrics m, bool big) {
    final l10n = AppLocalizations.of(context)!;
    final placement = _placement!;
    return [
      KidButton(
        icon: Icons.home_rounded,
        size: m.primary,
        color: const Color(0xFFFFD54F),
        semanticLabel: l10n.home,
        onTap: _goHome,
      ),
      KidButton(
        icon: Icons.undo_rounded,
        size: m.primary,
        semanticLabel: l10n.undo,
        enabled: placement.canUndo && !_leaving,
        onTap: _undo,
      ),
      if (big)
        KidButton(
          icon: Icons.redo_rounded,
          size: m.primary,
          semanticLabel: l10n.redo,
          enabled: placement.canRedo && !_leaving,
          onTap: _redo,
        ),
    ];
  }

  Widget _canvas() {
    final placement = _placement!;
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = constraints.maxWidth / widget.scene.size;
                Rect scaled(Rect r) => Rect.fromLTWH(r.left * scale, r.top * scale, r.width * scale, r.height * scale);
                return Semantics(
                  container: true,
                  label: l10n.sceneLabel,
                  child: Stack(
                    key: _canvasKey,
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.scene.background,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.medium,
                        excludeFromSemantics: true,
                      ),
                      // The slots show only while a piece is dragged.
                      if (_dragging)
                        for (final slot in placement.slots)
                          if (placement.isFree(slot))
                            Positioned.fromRect(rect: scaled(slot.rect), child: _SlotFrame(lit: slot == _target)),
                      for (final step in placement.placed)
                        if (!_inFlight(step.piece))
                          Positioned.fromRect(
                            rect: scaled(step.slot.rect),
                            child: Semantics(
                              image: true,
                              label: step.piece.label(lang),
                              child: Image.asset(
                                step.piece.asset,
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.medium,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ),
                      if (_glow != null)
                        Positioned.fromRect(rect: scaled(_glow!.rect).inflate(4), child: const _GlowRing()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// One row of pieces under the scene (one column beside it in a wide
  /// window). Minik's cells keep the palette's 70 pt with the whole pitch as
  /// the hit area; Büyük's six share the width like the palette's columns.
  Widget _trayWidget(KidMetrics m, bool big, {required bool vertical}) {
    final pieces = _placement!.pieces;
    final lang = Localizations.localeOf(context).languageCode;
    return LayoutBuilder(
      builder: (context, constraints) {
        final along = vertical ? constraints.maxHeight : constraints.maxWidth;
        final pitch = along / pieces.length;
        final cell = math.min(pitch, math.max(44.0, math.min(m.cell, pitch - m.gap)));
        final cross = math.min(pitch, cell + m.gap * 1.5);
        final geometry = _TrayGeometry(vertical: vertical, pitch: pitch, cross: cross, cell: cell);
        _tray = geometry;
        final cells = [
          for (final piece in pieces)
            SizedBox(
              width: vertical ? cross : pitch,
              height: vertical ? pitch : cross,
              child: Center(child: _cell(piece, cell, lang)),
            ),
        ];
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _trayDown,
          onPointerMove: _trayMove,
          onPointerUp: _trayUp,
          onPointerCancel: _trayCancel,
          child: SizedBox(
            key: _trayKey,
            width: vertical ? cross : along,
            height: vertical ? along : cross,
            child: vertical ? Column(children: cells) : Row(children: cells),
          ),
        );
      },
    );
  }

  Widget _cell(ScenePiece piece, double size, String lang) {
    final placed = _placement!.isPlaced(piece);
    final away = _inFlight(piece) || (_dragging && _held == piece);
    final radius = BorderRadius.circular(size * 0.22);
    return Semantics(
      button: true,
      label: piece.label(lang),
      onTap: () => _tapPiece(piece),
      child: SizedBox.square(
        dimension: size,
        child: placed
            // The piece is in the scene: a faint dashed frame, never grey
            // or locked.
            ? CustomPaint(painter: _DashedFrame(radius: size * 0.22))
            : DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: radius,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: away
                    ? null
                    : Padding(
                        padding: EdgeInsets.all(size * 0.1),
                        child: Image.asset(piece.asset, filterQuality: FilterQuality.medium, excludeFromSemantics: true),
                      ),
              ),
      ),
    );
  }

  Widget _overlay() {
    final ready = _box(_bodyKey) != null && _tray != null;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          children: [
            for (final flight in _flights)
              AnimatedBuilder(
                key: ObjectKey(flight),
                animation: flight.controller,
                builder: (context, child) {
                  final t = flight.controller.value;
                  return Positioned.fromRect(
                    rect: Rect.lerp(flight.from, flight.to, Curves.easeOutCubic.transform(t))!,
                    child: Opacity(opacity: flight.fade ? t : 1, child: child),
                  );
                },
                child: Image.asset(flight.piece.asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
              ),
            if (ready && _dragging && _held != null)
              Positioned.fromRect(
                rect: _heldRect(),
                child: Image.asset(_held!.asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
              ),
            if (ready && _hint)
              Positioned.fromRect(
                rect: Rect.fromCenter(center: _cellRect(_placement!.pieces.first).center, width: 140, height: 140),
                child: const IdleHint(at: Offset(0.5, 0.5)),
              ),
          ],
        ),
      ),
    );
  }
}

/// A free slot while a piece is dragged; the one the piece would take is lit.
class _SlotFrame extends StatelessWidget {
  const _SlotFrame({required this.lit});

  final bool lit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: lit ? const Color(0x33FFD54F) : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lit ? const Color(0xFFFFB300) : const Color(0x557D8297), width: lit ? 4 : 2),
      ),
    );
  }
}

/// The still ring around a placed piece whose tray cell was tapped.
class _GlowRing extends StatelessWidget {
  const _GlowRing();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x22FFD54F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFB300), width: 5),
      ),
    );
  }
}

class _DashedFrame extends CustomPainter {
  _DashedFrame({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0B3C6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final outline = Path()..addRRect(RRect.fromRectAndRadius((Offset.zero & size).deflate(2), Radius.circular(radius)));
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 6, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedFrame old) => old.radius != radius;
}
