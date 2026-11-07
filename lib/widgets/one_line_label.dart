import 'package:flutter/widgets.dart';

/// A short label that must stay whole: a card's name or a screen's title.
/// It keeps to one line and is never cut off with an ellipsis or broken in
/// the middle of a word. At the largest Dynamic Type sizes it shrinks just
/// enough to fit its space; at the usual sizes it is exactly the Text it
/// wraps.
class OneLineLabel extends StatelessWidget {
  const OneLineLabel(this.text, {super.key, this.style, this.center = false});

  final String text;
  final TextStyle? style;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: center ? Alignment.center : AlignmentDirectional.centerStart,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        textAlign: center ? TextAlign.center : null,
        style: style,
      ),
    );
  }
}
