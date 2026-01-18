import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/coloring_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class ColorPalette extends StatelessWidget {
  final double width;

  const ColorPalette({
    super.key,
    this.width = 70,
  });

  @override
  Widget build(BuildContext context) {
    // Panel genişliğine göre kaç sütun olacağını hesapla
    final int crossAxisCount = width >= 120 ? 2 : 1;
    final double itemSize = crossAxisCount == 2 ? (width - 32) / 2 : 50;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Consumer<ColoringProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Selected color indicator
              Container(
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      width: itemSize,
                      height: itemSize,
                      decoration: BoxDecoration(
                        color: provider.selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black26,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: provider.selectedColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.selected,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Color picker button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: GestureDetector(
                  onTap: () => _showColorPicker(context, provider),
                  child: Container(
                    width: itemSize,
                    height: itemSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const SweepGradient(
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.cyan,
                          Colors.blue,
                          Colors.purple,
                          Colors.red,
                        ],
                      ),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Icon(
                      Icons.colorize,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const Divider(),
              // Color grid
              Expanded(
                child: crossAxisCount == 1
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          for (int i = 0; i < AppTheme.colorPalette.length; i += 1)
                            _ColorButton(
                              color: AppTheme.colorPalette[i],
                              isSelected: provider.selectedColor == AppTheme.colorPalette[i],
                              size: itemSize,
                              onTap: () {
                                provider.setSelectedColor(AppTheme.colorPalette[i]);
                                SoundService().playColorSelectSound();
                              },
                            ),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: AppTheme.colorPalette.length,
                        itemBuilder: (context, index) {
                          return _ColorButton(
                            color: AppTheme.colorPalette[index],
                            isSelected: provider.selectedColor == AppTheme.colorPalette[index],
                            size: itemSize,
                            onTap: () {
                              provider.setSelectedColor(AppTheme.colorPalette[index]);
                              SoundService().playColorSelectSound();
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showColorPicker(BuildContext context, ColoringProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    Color selectedColor = provider.selectedColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setSelectedColor(selectedColor);
              SoundService().playColorSelectSound();
              Navigator.pop(context);
            },
            child: Text(l10n.select),
          ),
        ],
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.black12,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }
}
