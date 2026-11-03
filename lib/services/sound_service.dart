import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing fun sound effects in the app.
///
/// Each sound has its own preloaded low-latency player, so a tap is heard at
/// once and a new sound does not cut off a different one.
class SoundService {
  /// Tests run without the audio plugin; nothing is loaded or played.
  @visibleForTesting
  static bool disabled = false;

  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  static const List<String> _sounds = ['pop', 'splash', 'swoosh', 'click', 'success', 'undo', 'color_select'];

  final Map<String, AudioPlayer> _players = {};
  final Map<String, Future<AudioPlayer?>> _loading = {};
  bool _soundEnabled = true;
  double _volume = 0.7;

  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// Loads every sound ahead of the first tap.
  Future<void> preload() async {
    if (disabled) return;
    await _configureSession();
    await Future.wait(_sounds.map(_player));
  }

  Future<void>? _session;

  /// Sound effects follow the Ring/Silent switch and mix with other audio
  /// (iOS ambient session); on Android they never take audio focus.
  Future<void> _configureSession() {
    return _session ??= AudioPlayer.global
        .setAudioContext(AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
        ))
        .catchError((Object e) => debugPrint('Audio session setup failed: $e'));
  }

  /// Play a pop sound when filling an area
  Future<void> playFillSound() => _playSound('pop');

  /// Play a splash sound for larger fills
  Future<void> playSplashSound() => _playSound('splash');

  /// Play a swoosh sound for drawing
  Future<void> playDrawSound() => _playSound('swoosh');

  /// Play a click sound for UI interactions
  Future<void> playClickSound() => _playSound('click');

  /// Play a success sound for completed actions
  Future<void> playSuccessSound() => _playSound('success');

  /// Play an undo sound
  Future<void> playUndoSound() => _playSound('undo');

  /// Play a color select sound
  Future<void> playColorSelectSound() => _playSound('color_select');

  Future<AudioPlayer?> _player(String name) {
    final ready = _players[name];
    if (ready != null) return Future.value(ready);
    return _loading.putIfAbsent(name, () async {
      try {
        await _configureSession();
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setSource(AssetSource('sounds/$name.mp3'));
        _players[name] = player;
        return player;
      } catch (e) {
        // A missing or broken sound must never break coloring.
        debugPrint('Sound $name could not be loaded: $e');
        return null;
      } finally {
        unawaited(_loading.remove(name));
      }
    });
  }

  Future<void> _playSound(String name) async {
    if (disabled) return;
    if (!_soundEnabled) return;
    try {
      final player = await _player(name);
      if (player == null) return;
      await player.setVolume(_volume);
      await player.stop();
      await player.resume();
    } catch (e) {
      debugPrint('Sound $name could not be played: $e');
    }
  }

  void dispose() {
    for (final player in _players.values) {
      unawaited(player.dispose());
    }
    _players.clear();
  }
}
