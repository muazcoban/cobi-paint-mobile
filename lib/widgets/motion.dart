import 'dart:ui';

import 'package:flutter/widgets.dart';

/// True when the user asked for less motion. On iOS, Reduce Motion only
/// reaches `accessibilityFeatures.reduceMotion`; MediaQuery's
/// disableAnimations covers Android's animator setting.
bool reduceMotion(BuildContext context) =>
    (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ||
    PlatformDispatcher.instance.accessibilityFeatures.reduceMotion;
