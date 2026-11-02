import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../engine/document/coloring_document.dart';
import '../engine/document/page_progress.dart';
import '../engine/region/label_map.dart';
import '../l10n/app_localizations.dart';
import '../models/coloring_image.dart';
import '../models/saved_artwork.dart';
import '../models/user_settings.dart';
import '../providers/app_provider.dart';
import '../services/haptics.dart';
import '../services/sound_service.dart';
import '../services/system_gestures.dart';
import '../widgets/celebration.dart';
import '../widgets/idle_hint.dart';
import '../widgets/kid_button.dart';
import '../widgets/kid_palette.dart';
import '../widgets/paint_canvas.dart';
import 'coloring/artwork_autosaver.dart';

/// Nine clearly different colours for Minik mode; the eraser is the tenth cell.
const littlePalette = <Color>[
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFFFDD835),
  Color(0xFF43A047),
  Color(0xFF1E88E5),
  Color(0xFF8E24AA),
  Color(0xFFEC407A),
  Color(0xFF8D6E63),
  Color(0xFF212121),
];

/// Büyük mode adds lighter, darker and neutral colours.
const bigPalette = <Color>[
  ...littlePalette,
  Color(0xFF4FC3F7),
  Color(0xFFAED581),
  Color(0xFFFFAB91),
  Color(0xFFFFF59D),
  Color(0xFF283593),
  Color(0xFF2E7D32),
  Color(0xFF9E9E9E),
];

/// Brush diameters as a share of the page's shorter side.
const _brushSteps = [0.025, 0.05, 0.09];

/// Control sizes from the toddler research: about 2 cm on a phone where it
/// fits, larger on tablets; Büyük mode trades size for more controls.
class _Metrics {
  _Metrics(Size size, bool big) {
    final tablet = size.shortestSide >= 600;
    primary = big ? (tablet ? 96 : 64) : (tablet ? 116 : 82);
    cell = big ? (tablet ? 88 : 52) : (tablet ? 112 : 70);
    gap = tablet ? 16 : 12;
  }

  late final double primary;
  late final double cell;
  late final double gap;
}

class ColoringScreen extends StatefulWidget {
  final ColoringImage image;
  final SavedArtwork? existingArtwork;

  const ColoringScreen({super.key, required this.image, this.existingArtwork});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> with WidgetsBindingObserver {
  final SoundService _sound = SoundService();

  ColoringDocument? _document;
  ui.Image? _page;
  ArtworkAutosaver? _saver;
  bool _failed = false;
  bool _leaving = false;
  int _revisionAtOpen = 0;

  CanvasTool _tool = CanvasTool.fill;
  bool _celebrated = false;
  Timer? _hintTimer;
  Offset? _hintAt;
  Color _color = littlePalette.first;
  int _brushStep = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A blank page is for drawing, so the brush is in hand from the start.
    if (widget.image.freeDraw) _tool = CanvasTool.marker;
    unawaited(_load());
    unawaited(_sound.preload());
    unawaited(SystemGestures.deferEdgeGestures(true));
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(SystemGestures.deferEdgeGestures(false));
    final saver = _saver;
    final page = _page;
    if (saver != null) {
      // Finish the last save before letting go of the page image.
      unawaited(
        saver.flush().catchError((Object e) => debugPrint('Autosave failed: $e')).whenComplete(() {
          saver.dispose();
          page?.dispose();
        }),
      );
    } else {
      page?.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      unawaited(_flush());
    }
  }

  Future<void> _flush() async {
    try {
      await _saver?.flush();
    } catch (e) {
      debugPrint('Autosave failed: $e');
    }
  }

  Future<void> _load() async {
    try {
      final app = context.read<AppProvider>();
      final bytes = widget.image.isImported
          ? await File(widget.image.imagePath).readAsBytes()
          : (await rootBundle.load(widget.image.imagePath)).buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final page = (await codec.getNextFrame()).image;
      codec.dispose();
      final map = await app.regionService.labelMapFor(bytes);
      if (!mounted) {
        page.dispose();
        return;
      }

      final document = ColoringDocument(map);
      final saver = ArtworkAutosaver(
        document: document,
        page: page,
        image: widget.image,
        app: app,
        existing: widget.existingArtwork,
        delay: const Duration(milliseconds: 400),
      );
      final existing = widget.existingArtwork;
      if (existing != null) {
        if (existing.schema >= 2) {
          final json = await app.storageService.readArtworkDocument(existing.id);
          if (json != null) document.restore(json);
        } else if (existing.coloredRegions.isNotEmpty) {
          // A version 1 drawing: convert it and write it in the new format.
          document.restoreLegacyPixels(existing.coloredRegions);
          saver.markDirty();
        }
      }
      saver.start();
      if (!mounted) {
        saver.dispose();
        page.dispose();
        return;
      }
      setState(() {
        _document = document;
        _page = page;
        _saver = saver;
        _revisionAtOpen = document.revision;
      });
      _scheduleHint(app, document);
    } catch (e) {
      // No error text for the child: a sad face and the home button.
      debugPrint('Coloring page could not be loaded: $e');
      if (mounted) setState(() => _failed = true);
    }
  }

  /// After 6 s without a touch on an untouched page, the mascot shows where
  /// a tap would land. Only until the child has made their first few fills,
  /// never with a screen reader, and never on the free drawing page.
  void _scheduleHint(AppProvider app, ColoringDocument document) {
    final mode = context.read<AppProvider>().settings.ageMode;
    if (widget.image.freeDraw || mode != AgeMode.little || !document.isEmpty) return;
    if (app.settings.firstFills >= 3 || MediaQuery.accessibleNavigationOf(context)) return;
    final map = document.map;
    final background = PageProgress.backgroundLabel(map);
    RegionInfo? biggest;
    for (var label = 1; label <= map.regionCount; label++) {
      if (label == background) continue;
      final r = map.region(label);
      if (biggest == null || r.area > biggest.area) biggest = r;
    }
    if (biggest == null) return;
    final at = Offset((biggest.left + biggest.right) / 2 / map.width, (biggest.top + biggest.bottom) / 2 / map.height);
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && (_document?.isEmpty ?? false)) setState(() => _hintAt = at);
    });
  }

  void _hideHint() {
    _hintTimer?.cancel();
    if (_hintAt != null) setState(() => _hintAt = null);
  }

  // Actions ------------------------------------------------------------------

  void _selectTool(CanvasTool tool) {
    if (_tool == tool) return;
    unawaited(_sound.playClickSound());
    setState(() => _tool = tool);
  }

  void _selectPaletteItem(int index, List<Color> colors) {
    if (index < colors.length) {
      unawaited(_sound.playColorSelectSound());
      setState(() {
        _color = colors[index];
        // Picking a colour while erasing means "I want to paint again".
        if (_tool == CanvasTool.eraser) _tool = CanvasTool.fill;
      });
    } else if (index == colors.length) {
      unawaited(_sound.playClickSound());
      setState(() => _tool = CanvasTool.eraser);
    } else {
      unawaited(_sound.playClickSound());
      setState(() => _brushStep = (_brushStep + 1) % _brushSteps.length);
    }
  }

  void _undo() {
    if (_document?.canUndo != true) return;
    unawaited(_sound.playUndoSound());
    _document!.undo();
  }

  void _redo() {
    if (_document?.canRedo != true) return;
    unawaited(_sound.playUndoSound());
    _document!.redo();
  }

  void _onFilled(int label) {
    unawaited(_sound.playFillSound());
    Haptics.light();
    _hideHint();
    final app = context.read<AppProvider>();
    if (app.settings.firstFills < 3) {
      unawaited(app.updateSettings(app.settings.copyWith(firstFills: app.settings.firstFills + 1)));
    }
    final document = _document;
    if (document == null || _celebrated || widget.image.freeDraw) return;
    // The picture is done when every finger-sized area has paint: one short
    // celebration, no star and no counter anywhere.
    if (PageProgress.of(document).isComplete) {
      _celebrated = true;
      _saver?.completed = true;
      unawaited(_sound.playSuccessSound());
      unawaited(showCelebration(context, duration: const Duration(milliseconds: 1100)));
    }
  }

  /// Home: saves, celebrates when something was added, then leaves.
  Future<void> _goHome() async {
    if (_leaving) return;
    _leaving = true;
    final navigator = Navigator.of(context);
    final save = _flush();
    final changed = (_document?.revision ?? 0) != _revisionAtOpen && !(_document?.isEmpty ?? true);
    if (changed && !_celebrated) {
      unawaited(_sound.playSuccessSound());
      await showCelebration(context, duration: const Duration(milliseconds: 1100));
    } else {
      unawaited(_sound.playClickSound());
    }
    await save;
    if (mounted) navigator.pop();
  }

  // Layout -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final mode = context.select<AppProvider, AgeMode>((p) => p.settings.ageMode);
    final big = mode == AgeMode.big;
    return PopScope(
      // No pop without the save: the iOS edge swipe is off on this screen,
      // and Android back or the VoiceOver escape gesture go home the same
      // way as the home button.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_goHome());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF4E6),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final metrics = _Metrics(constraints.biggest, big);
              final wide = constraints.maxWidth > constraints.maxHeight * 1.1;
              return wide ? _wideLayout(metrics, big) : _tallLayout(metrics, big);
            },
          ),
        ),
      ),
    );
  }

  List<Color> _colors(bool big) => big ? bigPalette : littlePalette;

  Widget _tallLayout(_Metrics m, bool big) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _controls(m, big)),
        ),
        Expanded(
          child: Padding(padding: const EdgeInsets.all(12), child: _canvasArea(big)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: _palette(m, big, columns: big ? 6 : 5),
        ),
      ],
    );
  }

  Widget _wideLayout(_Metrics m, bool big) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _controls(m, big)),
        ),
        Expanded(
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: _canvasArea(big)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Center(child: _palette(m, big, columns: big ? 3 : 2)),
        ),
      ],
    );
  }

  /// Home, fill, brush and undo (plus redo in Büyük mode).
  List<Widget> _controls(_Metrics m, bool big) {
    final l10n = AppLocalizations.of(context)!;
    final document = _document;
    final listenable = document ?? const AlwaysStoppedAnimation<double>(0);
    return [
      KidButton(
        icon: Icons.home_rounded,
        size: m.primary,
        color: const Color(0xFFFFD54F),
        semanticLabel: l10n.home,
        onTap: () => unawaited(_goHome()),
      ),
      KidButton(
        icon: Icons.format_color_fill_rounded,
        size: m.primary * 0.96,
        selected: _tool == CanvasTool.fill,
        badgeColor: _color,
        semanticLabel: l10n.fill,
        onTap: () => _selectTool(CanvasTool.fill),
      ),
      KidButton(
        icon: Icons.brush_rounded,
        size: m.primary * 0.96,
        selected: _tool == CanvasTool.marker,
        badgeColor: _color,
        semanticLabel: l10n.marker,
        onTap: () => _selectTool(CanvasTool.marker),
      ),
      ListenableBuilder(
        listenable: listenable,
        builder: (context, _) => KidButton(
          icon: Icons.undo_rounded,
          size: m.primary,
          semanticLabel: l10n.undo,
          enabled: document?.canUndo ?? false,
          onTap: _undo,
        ),
      ),
      if (big)
        ListenableBuilder(
          listenable: listenable,
          builder: (context, _) => KidButton(
            icon: Icons.redo_rounded,
            size: m.primary,
            semanticLabel: l10n.redo,
            enabled: document?.canRedo ?? false,
            onTap: _redo,
          ),
        ),
    ];
  }

  Widget _canvasArea(bool big) {
    final document = _document;
    final page = _page;
    if (_failed) {
      return const Center(child: Icon(Icons.sentiment_dissatisfied_rounded, size: 96, color: Color(0xFFB0B3C6)));
    }
    if (document == null || page == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final map = document.map;
    final side = map.width < map.height ? map.width : map.height;
    // The white card is exactly the page, so every white spot the child
    // sees takes paint; strokes outside a wider card used to vanish.
    return Center(
      child: AspectRatio(
        aspectRatio: map.width / map.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => _hideHint(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Semantics(
                    label: AppLocalizations.of(context)!.canvasLabel,
                    child: PaintCanvas(
                      document: document,
                      page: page,
                      tool: _tool,
                      color: _color,
                      brushSize: side * (big ? _brushSteps[_brushStep] : _brushSteps[1]),
                      stayInside: !widget.image.freeDraw,
                      eraseFills: !widget.image.freeDraw,
                      allowZoom: big,
                      onFilled: _onFilled,
                    ),
                  ),
                  if (_hintAt != null) IdleHint(at: _hintAt!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _palette(_Metrics m, bool big, {required int columns}) {
    final l10n = AppLocalizations.of(context)!;
    final names = l10n.colorNames.split(',');
    final colors = _colors(big);
    final items = <PaletteItem>[
      for (var i = 0; i < colors.length; i++)
        PaletteItem.color(colors[i], label: i < names.length ? names[i].trim() : null),
      PaletteItem.glyph(const EraserGlyph(), label: l10n.eraser),
      if (big)
        PaletteItem.glyph(
          label: l10n.brushSize,
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.35 + _brushStep * 0.3,
              heightFactor: 0.35 + _brushStep * 0.3,
              child: DecoratedBox(
                decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
    ];
    final selectedIndex = _tool == CanvasTool.eraser ? colors.length : colors.indexOf(_color);
    return KidPalette(
      items: items,
      columns: columns,
      cellSize: m.cell,
      gap: m.gap,
      selectedIndex: selectedIndex,
      onSelected: (i) => _selectPaletteItem(i, colors),
    );
  }
}
