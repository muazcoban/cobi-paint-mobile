import 'dart:ui';

/// A word of the scene mode: the English word is the key of its clips
/// (`word_<key>`), [tr] is written as it is spoken at the start of a
/// sentence. Chosen by hand (house, not home), never from the page catalog.
class SceneWord {
  const SceneWord({required this.key, required this.tr, required this.en});

  final String key;
  final String tr;
  final String en;

  /// What a screen reader says: both words in a Turkish app ("Güneş, sun"),
  /// the English word alone elsewhere.
  String label(String languageCode) => languageCode.startsWith('tr') ? '$tr, $en' : _capital(en);

  static String _capital(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// A fixed place in a scene where a piece sits. [rect] is in scene pixels;
/// slots never overlap. Büyük has the [bigOnly] slots too.
class SceneSlot {
  const SceneSlot({required this.id, required this.rect, this.sky = false, this.bigOnly = false});

  final int id;
  final Rect rect;
  final bool sky;
  final bool bigOnly;
}

/// A piece in the tray: its line art at its own slot's size, white inside
/// and transparent outside. A tap sends it to [slot].
class ScenePiece extends SceneWord {
  const ScenePiece({
    required super.key,
    required this.asset,
    required this.slot,
    required super.tr,
    required super.en,
    this.bigOnly = false,
  });

  final String asset;
  final int slot;
  final bool bigOnly;
}

/// One scene: the empty background drawing, its slots and pieces, and the
/// words of the background's regions. Built by tool/scenes/build_scenes.py.
class SceneDefinition {
  const SceneDefinition({
    required this.id,
    required this.size,
    required this.background,
    required this.slots,
    required this.pieces,
    required this.ground,
  });

  final String id;

  /// The side of the square scene in pixels.
  final double size;
  final String background;
  final List<SceneSlot> slots;
  final List<ScenePiece> pieces;
  final List<SceneWord> ground;

  List<SceneSlot> slotsFor({required bool big}) => [for (final s in slots) if (big || !s.bigOnly) s];

  /// The tray's pieces, always in the same order.
  List<ScenePiece> piecesFor({required bool big}) => [for (final p in pieces) if (big || !p.bigOnly) p];

  /// Every clip the scene needs, in both languages: the card's name and each
  /// word (council condition 16).
  List<String> clipPaths() => [
        for (final lang in const ['tr', 'en']) ...[
          'assets/voice/$lang/scene.mp3',
          for (final w in [...pieces, ...ground]) 'assets/voice/$lang/word_${w.key}.mp3',
        ],
      ];
}
