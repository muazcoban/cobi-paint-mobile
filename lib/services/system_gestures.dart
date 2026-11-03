import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS system edge gestures while a child colours: when deferred, a swipe
/// from the top or bottom edge first only shows the indicator, and only a
/// second swipe opens Control Center or leaves the app.
/// Native side: KidFlutterViewController in ios/Runner/AppDelegate.swift.
/// Android keeps the child in the app with immersive mode instead.
abstract final class SystemGestures {
  static const _channel = MethodChannel('cobi_paint/system_gestures');

  static Future<void> deferEdgeGestures(bool defer) async {
    if (kIsWeb || !Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>('deferEdgeGestures', defer);
    } on PlatformException catch (e) {
      debugPrint('Edge gestures unchanged: $e');
    } on MissingPluginException {
      // An older native shell without the channel: nothing to defer.
    }
  }
}
