import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import '../region/label_map.dart';
import '../region/region_builder.dart';
import '../render/symmetry.dart';
import 'auto_complete.dart';
import 'page_progress.dart';
import 'sticker.dart';
import 'stroke.dart';

/// A filled region and the page point it was filled from. The point lets a
/// saved fill find its region again if the page or the algorithm changes.
class RegionFill {
  const RegionFill({required this.argb, required this.x, required this.y});

  final int argb;
  final int x;
  final int y;
}

/// Everything the child did to one page: region fills, brush strokes and
/// stickers, with undo and redo. Fills are per region, so a tap never leaks
/// and never leaves white pixels next to the lines.
class ColoringDocument extends ChangeNotifier {
  ColoringDocument(this.map) : _fills = List<RegionFill?>.filled(map.regionCount + 1, null);

  static const int schemaVersion = 2;
  static const int maxHistory = 100;

  final LabelMap map;
  final List<RegionFill?> _fills;
  final List<Stroke> _strokes = [];
  final List<Sticker> _stickers = [];
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

  /// Stickers in the order they were stuck on; later ones lie on top.
  List<Sticker> get stickers => List.unmodifiable(_stickers);
  bool get isEmpty => _strokes.isEmpty && _stickers.isEmpty && _fills.every((f) => f == null);

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

  /// Adds a brush stroke. [completion] is the fill [completionFor] found:
  /// it joins the stroke's undo step, so one finger is one step and undo
  /// takes both away.
  void addStroke(Stroke stroke, {RegionFill? completion}) =>
      _push(_StrokeCommand(stroke, const {}, const {}, completion: completion));

  /// Regions whose automatic completion was undone: left alone for as long
  /// as the page is open, so undo never fights the child.
  final Set<int> _completionUndone = {};

  /// The fill that finishes the region [stroke] stays in once the stroke is
  /// added (see [AutoComplete]), or null. Only a marker stroke on a coloring
  /// page asks; a region with a fill, the background and a region whose
  /// completion was undone never complete.
  RegionFill? completionFor(Stroke stroke) {
    final label = stroke.clipLabel;
    if (stroke.kind != BrushKind.marker || stroke.symmetry != 1 || label <= 0 || label >= _fills.length) return null;
    if (_fills[label] != null || _completionUndone.contains(label)) return null;
    if (label == PageProgress.backgroundLabel(map)) return null;
    final result = AutoComplete.evaluate(map, [..._strokes, stroke], label);
    return result == null ? null : RegionFill(argb: result.argb, x: result.x, y: result.y);
  }

  /// Sticks [stickers] on the page as one step: a finger's trail of stamps
  /// comes off again with one undo.
  void stamp(List<Sticker> stickers) {
    if (stickers.isEmpty) return;
    _push(_StickerCommand(List.of(stickers)));
  }

  /// Eraser stroke: removes brush paint along the path, empties every
  /// region the eraser touched and peels off the stickers it ran over.
  void erase(Stroke stroke, Set<int> touchedLabels) {
    final cleared = <int, RegionFill>{
      for (final l in touchedLabels)
        if (l > 0 && l < _fills.length && _fills[l] != null) l: _fills[l]!,
    };
    final peeled = _stickersUnder(stroke);
    final hasBrushPaint = _strokes.any((s) => s.kind != BrushKind.eraser);
    if (cleared.isEmpty && peeled.isEmpty && !hasBrushPaint) return;
    _push(_StrokeCommand(stroke, cleared, peeled));
  }

  /// Stickers the eraser path (and its mirror copies) runs over, by their
  /// place in the list.
  Map<int, Sticker> _stickersUnder(Stroke stroke) {
    if (_stickers.isEmpty || stroke.pointCount == 0) return const {};
    final pts = stroke.points;
    final slop = stroke.size / 2;
    final step = math.max(1.0, stroke.size / 2);
    final samples = <Offset>[Offset(pts[0], pts[1])];
    for (var i = 3; i < pts.length; i += 3) {
      final a = Offset(pts[i - 3], pts[i - 2]);
      final b = Offset(pts[i], pts[i + 1]);
      final n = math.max(1, ((b - a).distance / step).ceil());
      for (var k = 1; k <= n; k++) {
        samples.add(Offset.lerp(a, b, k / n)!);
      }
    }
    final transforms = symmetryTransforms(stroke.symmetry, map.width / 2, map.height / 2);
    bool hit(Sticker sticker) {
      for (final transform in transforms) {
        for (final sample in samples) {
          if (sticker.contains(transformPoint(transform, sample), slop: slop)) return true;
        }
      }
      return false;
    }

    return {
      for (var i = 0; i < _stickers.length; i++)
        if (hit(_stickers[i])) i: _stickers[i],
    };
  }

  void clear() {
    if (isEmpty) return;
    _push(_ClearCommand(List.of(_fills), List.of(_strokes), List.of(_stickers)));
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

  void _setAll(List<RegionFill?> fills, List<Stroke> strokes, List<Sticker> stickers) {
    for (var i = 0; i < _fills.length; i++) {
      _fills[i] = i < fills.length ? fills[i] : null;
    }
    _strokes
      ..clear()
      ..addAll(strokes);
    _stickers
      ..clear()
      ..addAll(stickers);
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
        if (_stickers.isNotEmpty) 'stickers': [for (final s in _stickers) s.toJson()],
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
    final rawStickers = json['stickers'];
    final stickers = <Sticker>[
      if (rawStickers is List)
        for (final raw in rawStickers)
          if (Sticker.fromJson(raw) case final sticker?) sticker,
    ];
    _setAll(fills, strokes, stickers);
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
    _setAll(fills, const [], const []);
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

/// A brush stroke; for the eraser also the region fills it removed and the
/// stickers it peeled off, by their place in the list.
class _StrokeCommand implements _Command {
  _StrokeCommand(this.stroke, this.clearedFills, this.peeledStickers, {this.completion});

  final Stroke stroke;
  final Map<int, RegionFill> clearedFills;
  final Map<int, Sticker> peeledStickers;

  /// The fill that finished the stroke's region, if it did.
  final RegionFill? completion;

  @override
  void apply(ColoringDocument doc) {
    doc._strokes.add(stroke);
    doc._strokeRevision++;
    final done = completion;
    if (done != null) doc._setFill(stroke.clipLabel, done);
    for (final label in clearedFills.keys) {
      doc._setFill(label, null);
    }
    for (final index in peeledStickers.keys.toList()..sort((a, b) => b.compareTo(a))) {
      doc._stickers.removeAt(index);
    }
  }

  @override
  void revert(ColoringDocument doc) {
    doc._strokes.removeLast();
    doc._strokeRevision++;
    if (completion != null) {
      doc._setFill(stroke.clipLabel, null);
      doc._completionUndone.add(stroke.clipLabel);
    }
    clearedFills.forEach(doc._setFill);
    for (final index in peeledStickers.keys.toList()..sort()) {
      doc._stickers.insert(index, peeledStickers[index]!);
    }
  }
}

/// One finger's worth of stickers.
class _StickerCommand implements _Command {
  _StickerCommand(this.stickers);

  final List<Sticker> stickers;

  @override
  void apply(ColoringDocument doc) => doc._stickers.addAll(stickers);

  @override
  void revert(ColoringDocument doc) => doc._stickers.removeRange(doc._stickers.length - stickers.length, doc._stickers.length);
}

class _ClearCommand implements _Command {
  _ClearCommand(this.fills, this.strokes, this.stickers);

  final List<RegionFill?> fills;
  final List<Stroke> strokes;
  final List<Sticker> stickers;

  @override
  void apply(ColoringDocument doc) => doc._setAll(const [], const [], const []);

  @override
  void revert(ColoringDocument doc) => doc._setAll(fills, strokes, stickers);
}
