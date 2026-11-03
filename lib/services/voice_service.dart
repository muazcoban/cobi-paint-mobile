import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Short spoken names for a child who cannot read: a category, a colour, the
/// Draw card, and "ask a grown-up" at the gate.
///
/// Only recorded clips are played, from `assets/voice/{lang}/{key}.mp3` (see
/// tool/voice/README.md for the list to record). A missing clip is silently
/// skipped, so the app works before the recordings exist. One player: a new
/// tap cuts the previous clip. Never speaks while a screen reader is on.
class VoiceService {
  VoiceService._();

  static final VoiceService _instance = VoiceService._();

  factory VoiceService() => _instance;

  AudioPlayer? _player;
  Set<String>? _assets;
  bool enabled = true;

  /// Created on the first clip, so a build without clips (and the tests)
  /// never touches the audio plugin.
  AudioPlayer get _speaker => _player ??= AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);

  Future<void> _loadManifest() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _assets = manifest.listAssets().where((a) => a.startsWith('assets/voice/')).toSet();
    } catch (e) {
      debugPrint('Voice manifest unavailable: $e');
      _assets = {};
    }
  }

  /// Whether any clip is bundled for [languageCode].
  Future<bool> hasVoice(String languageCode) async {
    _assets ?? await _loadManifest();
    return _assets!.any((a) => a.startsWith('assets/voice/$languageCode/'));
  }

  /// Plays `<key>` in [languageCode] if the clip exists; [screenReader]
  /// (VoiceOver/TalkBack) keeps the app quiet so the two voices never overlap.
  Future<void> say(String key, {required String languageCode, bool screenReader = false}) async {
    if (!enabled || screenReader) return;
    _assets ?? await _loadManifest();
    final path = 'assets/voice/$languageCode/$key.mp3';
    if (!_assets!.contains(path)) return;
    try {
      await _speaker.stop();
      await _speaker.play(AssetSource(path.substring('assets/'.length)));
    } catch (e) {
      debugPrint('Voice clip failed: $e');
    }
  }

  Future<void> stop() async => _player?.stop();
}
