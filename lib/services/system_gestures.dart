import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS system edge gestures while a child colours: when deferred, a swipe
/// from the top or bottom edge first only shows the indicator, and only a
/// second swipe opens Control Center or leaves the app.
/// Native side: KidFlutterViewController in ios/Runner/AppDelegate.swift.
/// Android keeps the child in the app with immersive mode instead.
abstract final class SystemGestures {
  static const _channel = MethodChannel('cobi_paint/system_gestures');

  static int _deferrals = 0;

  /// The platform check; tests set it.
  @visibleForTesting
  static bool? debugIsIOS;

  static bool get _isIOS => debugIsIOS ?? (!kIsWeb && Platform.isIOS);

  /// How many open screens ask for deferred edges; for tests.
  @visibleForTesting
  static int get deferrals => _deferrals;

  @visibleForTesting
  static void debugReset() => _deferrals = 0;

  /// Screens ask in pairs: true when they open, false when they close. The
  /// edges stay deferred while any screen asks, so a screen that replaces
  /// another (the scene opening its page) never loses the deferral to the
  /// old screen's dispose, which comes after the new screen's initState.
  static Future<void> deferEdgeGestures(bool defer) async {
    final before = _deferrals;
    _deferrals = math.max(0, _deferrals + (defer ? 1 : -1));
    if ((before > 0) == (_deferrals > 0) || !_isIOS) return;
    try {
      await _channel.invokeMethod<void>('deferEdgeGestures', _deferrals > 0);
    } on PlatformException catch (e) {
      debugPrint('Edge gestures unchanged: $e');
    } on MissingPluginException {
      // An older native shell without the channel: nothing to defer.
    }
  }
}
