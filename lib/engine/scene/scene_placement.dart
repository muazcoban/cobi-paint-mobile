import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../models/scene.dart';

/// One placement: [piece] sits in [slot].
typedef ScenePlacementStep = ({ScenePiece piece, SceneSlot slot});

/// Which piece sits in which slot, with undo and redo. Every placement is
/// one step; a placed piece never moves, and undo sends it back to the tray.
/// Each piece goes in once and every drop is valid: a piece may take any
/// free slot, even another piece's (council condition 5).
class ScenePlacement extends ChangeNotifier {
  ScenePlacement(this.scene, {required this.big})
      : slots = scene.slotsFor(big: big),
        pieces = scene.piecesFor(big: big);

  final SceneDefinition scene;
  final bool big;
  final List<SceneSlot> slots;
  final List<ScenePiece> pieces;

  final Map<String, SceneSlot> _slotOf = {};
  final List<ScenePlacementStep> _done = [];
  final List<ScenePlacementStep> _undone = [];

  SceneSlot? slotOf(ScenePiece piece) => _slotOf[piece.key];
  bool isPlaced(ScenePiece piece) => _slotOf.containsKey(piece.key);
  bool isFree(SceneSlot slot) => !_slotOf.values.any((s) => s.id == slot.id);

  /// The pieces in the scene, in the order they were placed.
  List<ScenePlacementStep> get placed => List.unmodifiable(_done);

  bool get isEmpty => _done.isEmpty;

  /// Every slot has its piece.
  bool get isComplete => _done.length == slots.length;
  bool get canUndo => _done.isNotEmpty;
  bool get canRedo => _undone.isNotEmpty;

  /// Where a tap sends [piece]: its own slot, or the free slot nearest to it
  /// when another piece took that one. Null once the piece is in the scene.
  SceneSlot? slotForTap(ScenePiece piece) {
    if (isPlaced(piece)) return null;
    final own = slots.firstWhere((s) => s.id == piece.slot);
    return isFree(own) ? own : nearestFree(own.rect.center);
  }

  /// The free slot whose centre is nearest to [point], in scene pixels.
  SceneSlot? nearestFree(Offset point) {
    SceneSlot? best;
    var bestDistance = double.infinity;
    for (final slot in slots) {
      if (!isFree(slot)) continue;
      final d = (slot.rect.center - point).distanceSquared;
      if (d < bestDistance) {
        best = slot;
        bestDistance = d;
      }
    }
    return best;
  }

  /// Puts [piece] in [slot]: one undo step, and the redo history is gone.
  void place(ScenePiece piece, SceneSlot slot) {
    if (isPlaced(piece) || !isFree(slot)) {
      throw StateError('${piece.key} cannot go to slot ${slot.id}');
    }
    _slotOf[piece.key] = slot;
    _done.add((piece: piece, slot: slot));
    _undone.clear();
    notifyListeners();
  }

  /// Takes the last placed piece out of the scene; it goes back to the tray.
  ScenePlacementStep? undo() {
    if (_done.isEmpty) return null;
    final step = _done.removeLast();
    _slotOf.remove(step.piece.key);
    _undone.add(step);
    notifyListeners();
    return step;
  }

  /// Puts the last piece undo took out back in the same slot (Büyük).
  ScenePlacementStep? redo() {
    if (_undone.isEmpty) return null;
    final step = _undone.removeLast();
    _slotOf[step.piece.key] = step.slot;
    _done.add(step);
    notifyListeners();
    return step;
  }
}
