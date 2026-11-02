import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kid_button.dart';

/// One cell of the palette: a colour, the eraser or a custom glyph.
class PaletteItem {
  const PaletteItem.color(this.color, {this.label}) : glyph = null;
  const PaletteItem.glyph(this.glyph, {this.label}) : color = null;

  final Color? color;
  final Widget? glyph;

  /// Spoken by VoiceOver/TalkBack ("red", "eraser").
  final String? label;
}

/// Grid of big colour dots. The cell under the finger when it lifts is the
/// one chosen, so a toddler sliding between dots still gets a colour.
///
/// Cells shrink to fit the space they get (narrow phones, landscape), and
/// drawing and hit-testing use the same rows and columns.
class KidPalette extends StatefulWidget {
  const KidPalette({
    super.key,
    required this.items,
    required this.columns,
    required this.cellSize,
    required this.selectedIndex,
    required this.onSelected,
    this.gap = 12,
  });

  final List<PaletteItem> items;
  final int columns;

  /// Preferred cell size; smaller when the space does not allow it.
  final double cellSize;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double gap;

  @override
  State<KidPalette> createState() => _KidPaletteState();
}

class _KidPaletteState extends State<KidPalette> {
  int? _pointer;
  int? _pressed;
  double _cell = 0;

  int get _rows => (widget.items.length / widget.columns).ceil();
  double get _pitch => _cell + widget.gap;

  int? _cellAt(Offset p) {
    final grid = Rect.fromLTWH(
      0,
      0,
      widget.columns * _pitch - widget.gap,
      _rows * _pitch - widget.gap,
    ).inflate(forgivingSlop);
    if (!grid.contains(p)) return null;
    final col = (p.dx / _pitch).floor().clamp(0, widget.columns - 1);
    final row = (p.dy / _pitch).floor().clamp(0, _rows - 1);
    final index = row * widget.columns + col;
    return index < widget.items.length ? index : null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = widget.gap;
        var cell = widget.cellSize;
        if (constraints.hasBoundedWidth) {
          cell = math.min(cell, (constraints.maxWidth - gap * (widget.columns - 1)) / widget.columns);
        }
        if (constraints.hasBoundedHeight) {
          cell = math.min(cell, (constraints.maxHeight - gap * (_rows - 1)) / _rows);
        }
        _cell = math.max(cell, 24);
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            if (_pointer != null) return;
            _pointer = e.pointer;
            setState(() => _pressed = _cellAt(e.localPosition));
          },
          onPointerMove: (e) {
            if (e.pointer != _pointer) return;
            final cell = _cellAt(e.localPosition);
            if (cell != _pressed) setState(() => _pressed = cell);
          },
          onPointerUp: (e) {
            if (e.pointer != _pointer) return;
            _pointer = null;
            final cell = _cellAt(e.localPosition);
            setState(() => _pressed = null);
            if (cell != null) {
              HapticFeedback.selectionClick();
              widget.onSelected(cell);
            }
          },
          onPointerCancel: (e) {
            if (e.pointer != _pointer) return;
            _pointer = null;
            setState(() => _pressed = null);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var row = 0; row < _rows; row++)
                Padding(
                  padding: EdgeInsets.only(top: row == 0 ? 0 : gap),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var col = 0; col < widget.columns; col++)
                        Padding(
                          padding: EdgeInsets.only(left: col == 0 ? 0 : gap),
                          child: row * widget.columns + col < widget.items.length
                              ? _cellWidget(row * widget.columns + col)
                              : SizedBox.square(dimension: _cell),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _cellWidget(int i) {
    final item = widget.items[i];
    final selected = i == widget.selectedIndex;
    final color = item.color ?? Colors.white;
    final scale = _pressed == i ? 0.9 : (selected ? 1.15 : 1.0);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      onTap: () => widget.onSelected(i),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: _cell,
          height: _cell,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            // A dark rim keeps light colours visible on the cream background.
            border: Border.all(
              color: selected ? const Color(0xFF2D3142) : const Color(0x662D3142),
              width: selected ? 5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: item.glyph != null
              ? Padding(padding: EdgeInsets.all(_cell * 0.2), child: item.glyph)
              : selected
              ? Icon(
                  Icons.check_rounded,
                  color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                  size: _cell * 0.45,
                )
              : null,
        ),
      ),
    );
  }
}
