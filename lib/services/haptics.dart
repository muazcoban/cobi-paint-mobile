import 'package:flutter/services.dart';

/// App-wide haptics. Parents can turn them off in the Parents area: Apple's
/// HIG asks that haptics stay optional and the app works without them.
abstract final class Haptics {
  static bool enabled = true;

  /// A fill landed.
  static void light() {
    if (enabled) HapticFeedback.lightImpact();
  }

  /// A button, card or colour was chosen.
  static void selection() {
    if (enabled) HapticFeedback.selectionClick();
  }
}
