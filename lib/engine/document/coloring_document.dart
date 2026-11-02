import 'package:flutter/foundation.dart';

import '../region/label_map.dart';
import '../region/region_builder.dart';
import 'stroke.dart';

/// A filled region and the page point it was filled from. The point lets a
/// saved fill find its region again if the page or the algorithm changes.
class RegionFill {
  const RegionFill({required this.argb, required this.x, required this.y});

  final int argb;
  final int x;
  final int y;
}

/// Everything the child did to one page: region fills and brush strokes,
/// with undo and redo. Fills are per region, so a tap never leaks and never
/// leaves white pixels next to the lines.
class ColoringDocument extends ChangeNotifier {
  ColoringDocument(this.map) : _fills = List<RegionFill?>.filled(map.regionCount + 1, null);

  static const int schemaVersion = 2;
  static const int maxHistory = 100;

  final LabelMap map;
  final List<RegionFill?> _fills;
  final List<Stroke> _strokes = [];
  final List<_Command> _undo = [];
  final List<_Command> _redo = [];

  // Change tracking for the renderer.
  final Set<int> _dirtyLabels = {};
  bool _fillsReset = false;
  int _strokeRevision = 0;
  int _revision = 0;

  int get revision => _revision;
  int get strokeRevision => _strokeRevision;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  List<Stroke> get strokes => List.unmodifiable(_strokes);
  bool get isEmpty => _strokes.isEmpty && _fills.every((f) => f == null);

  /// ARGB colour of [label], or 0 when it is not filled.
  int fillOf(int label) => label <= 0 || label >= _fills.length ? 0 : (_fills[label]?.argb ?? 0);

  /// Labels whose fill changed since the last call, or null when every
  /// region has to be redrawn (clear, restore).
  Set<int>? takeDirtyLabels() {
    if (_fillsReset) {
      _fillsReset = false;
      _dirtyLabels.clear();
      return null;
    }
    final labels = Set<int>.of(_dirtyLabels);
    _dirtyLabels.clear();
    return labels;
  }

  /// Fills the region under the page point ([x], [y]). Returns the label, or
  /// 0 when nothing changed.
  int fillAt(int x, int y, int argb) {
    final label = map.labelAt(x, y);
    if (label == 0 || fillOf(label) == argb) return 0;
    _push(_FillCommand(label, _fills[label], RegionFill(argb: argb, x: x, y: y)));
    return label;
  }

  void addStroke(Stroke stroke) => _push(_StrokeCommand(stroke, const {}));

  /// Eraser stroke: removes brush paint along the path and empties every
  /// region the eraser touched.
  void erase(Stroke stroke, Set<int> touchedLabels) {
    final cleared = <int, RegionFill>{
      for (final l in touchedLabels)
        if (l > 0 && l < _fills.length && _fills[l] != null) l: _fills[l]!,
    };
    final hasBrushPaint = _strokes.any((s) => s.kind == BrushKind.marker);
    if (cleared.isEmpty && !hasBrushPaint) return;
    _push(_StrokeCommand(stroke, cleared));
  }

  void clear() {
    if (isEmpty) return;
    _push(_ClearCommand(List.of(_fills), List.of(_strokes)));
  }

  void undo() {
    if (_undo.isEmpty) return;
    final command = _undo.removeLast();
    command.revert(this);
    _redo.add(command);
    _changed();
  }

  void redo() {
    if (_redo.isEmpty) return;
    final command = _redo.removeLast();
    command.apply(this);
    _undo.add(command);
    _changed();
  }

  void _push(_Command command) {
    command.apply(this);
    _undo.add(command);
    if (_undo.length > maxHistory) _undo.removeAt(0);
    _redo.clear();
    _changed();
  }

  void _changed() {
    _revision++;
    notifyListeners();
  }

  void _setFill(int label, RegionFill? fill) {
    _fills[label] = fill;
    _dirtyLabels.add(label);
  }

  void _setAll(List<RegionFill?> fills, List<Stroke> strokes) {
    for (var i = 0; i < _fills.length; i++) {
      _fills[i] = i < fills.length ? fills[i] : null;
    }
    _strokes
      ..clear()
      ..addAll(strokes);
    _fillsReset = true;
    _strokeRevision++;
  }

  // Saving --------------------------------------------------------------

  Map<String, Object?> toJson() => {
        'schema': schemaVersion,
        'labelAlgorithm': RegionBuilder.algorithmVersion,
        'fills': [
          for (var l = 1; l < _fills.length; l++)
            if (_fills[l] != null) {'l': l, 'c': _fills[l]!.argb, 'x': _fills[l]!.x, 'y': _fills[l]!.y},
        ],
        'strokes': [for (final s in _strokes) s.toJson()],
      };

  /// Loads a saved document. History starts empty.
  void restore(Map<String, Object?> json) {
    final sameAlgorithm = json['labelAlgorithm'] == RegionBuilder.algorithmVersion;
    final fills = List<RegionFill?>.filled(_fills.length, null);
    final rawFills = json['fills'];
    if (rawFills is List) {
      for (final raw in rawFills.whereType<Map>()) {
        final x = (raw['x'] as num?)?.toInt() ?? -1;
        final y = (raw['y'] as num?)?.toInt() ?? -1;
        final argb = (raw['c'] as num?)?.toInt() ?? 0;
        var label = (raw['l'] as num?)?.toInt() ?? 0;
        // A different algorithm may number regions differently: find the
        // region again from the point it was filled at.
        if (!sameAlgorithm || label <= 0 || label >= fills.length) label = map.labelAt(x, y);
        if (label > 0 && argb != 0) fills[label] = RegionFill(argb: argb, x: x, y: y);
      }
    }
    final rawStrokes = json['strokes'];
    final strokes = <Stroke>[
      if (rawStrokes is List)
        for (final raw in rawStrokes)
          if (Stroke.fromJson(raw) case final stroke?) stroke,
    ];
    _setAll(fills, strokes);
    _undo.clear();
    _redo.clear();
    _changed();
  }

  /// Converts a version 1 artwork (one colour per pixel index) to region
  /// fills: a region takes a colour when that colour covers at least half of
  /// it. Pencil marks thinner than that are dropped.
  void restoreLegacyPixels(Map<String, int> pixelColors) {
    final votes = <int, Map<int, int>>{};
    final samples = <int, int>{};
    for (final entry in pixelColors.entries) {
      final index = int.tryParse(entry.key);
      if (index == null || index < 0 || index >= map.labels.length) continue;
      final label = map.labels[index];
      if (label == 0) continue;
      final perColor = votes.putIfAbsent(label, () => {});
      perColor[entry.value] = (perColor[entry.value] ?? 0) + 1;
      samples.putIfAbsent(label, () => index);
    }
    final fills = List<RegionFill?>.filled(_fills.length, null);
    votes.forEach((label, perColor) {
      final best = perColor.entries.reduce((a, b) => a.value >= b.value ? a : b);
      if (best.value * 2 >= map.region(label).area) {
        final index = samples[label]!;
        fills[label] = RegionFill(argb: best.key, x: index % map.width, y: index ~/ map.width);
      }
    });
    _setAll(fills, const []);
    _undo.clear();
    _redo.clear();
    _changed();
  }
}

sealed class _Command {
  void apply(ColoringDocument doc);
  void revert(ColoringDocument doc);
}

class _FillCommand implements _Command {
  _FillCommand(this.label, this.before, this.after);

  final int label;
  final RegionFill? before;
  final RegionFill? after;

  @override
  void apply(ColoringDocument doc) => doc._setFill(label, after);

  @override
  void revert(ColoringDocument doc) => doc._setFill(label, before);
}

/// A brush stroke; for the eraser also the region fills it removed.
class _StrokeCommand implements _Command {
  _StrokeCommand(this.stroke, this.clearedFills);

  final Stroke stroke;
  final Map<int, RegionFill> clearedFills;

  @override
  void apply(ColoringDocument doc) {
    doc._strokes.add(stroke);
    doc._strokeRevision++;
    for (final label in clearedFills.keys) {
      doc._setFill(label, null);
    }
  }

  @override
  void revert(ColoringDocument doc) {
    doc._strokes.removeLast();
    doc._strokeRevision++;
    clearedFills.forEach(doc._setFill);
  }
}

class _ClearCommand implements _Command {
  _ClearCommand(this.fills, this.strokes);

  final List<RegionFill?> fills;
  final List<Stroke> strokes;

  @override
  void apply(ColoringDocument doc) => doc._setAll(const [], const []);

  @override
  void revert(ColoringDocument doc) => doc._setAll(fills, strokes);
}
