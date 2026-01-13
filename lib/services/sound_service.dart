import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing fun sound effects in the app
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
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

  /// Play a pop sound when filling an area
  Future<void> playFillSound() async {
    await _playSound('pop');
  }

  /// Play a splash sound for larger fills
  Future<void> playSplashSound() async {
    await _playSound('splash');
  }

  /// Play a swoosh sound for drawing
  Future<void> playDrawSound() async {
    await _playSound('swoosh');
  }

  /// Play a click sound for UI interactions
  Future<void> playClickSound() async {
    await _playSound('click');
  }

  /// Play a success sound for completed actions
  Future<void> playSuccessSound() async {
    await _playSound('success');
  }

  /// Play an undo sound
  Future<void> playUndoSound() async {
    await _playSound('undo');
  }

  /// Play a color select sound
  Future<void> playColorSelectSound() async {
    await _playSound('color_select');
  }

  Future<void> _playSound(String soundName) async {
    if (!_soundEnabled) return;

    try {
      await _player.setVolume(_volume);
      // Use bundled asset sounds
      await _player.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      // Fallback: generate simple tone if asset not found
      if (kDebugMode) {
        print('Sound asset not found: $soundName, using fallback');
      }
      await _playFallbackTone(soundName);
    }
  }

  Future<void> _playFallbackTone(String soundType) async {
    // Fallback: silently fail if sound asset not found
    // This prevents crashes in offline mode and when assets are missing
    // Sound files should be added to assets/sounds/ folder:
    // - pop.mp3, splash.mp3, swoosh.mp3, click.mp3
    // - success.mp3, undo.mp3, color_select.mp3
    if (kDebugMode) {
      print('Sound asset missing: $soundType.mp3 - Add to assets/sounds/');
    }
    // Do nothing - silent fallback is better than network-dependent fallback
  }

  void dispose() {
    _player.dispose();
  }
}
