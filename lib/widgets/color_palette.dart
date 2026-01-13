import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../providers/coloring_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class ColorPalette extends StatelessWidget {
  const ColorPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: provider.selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black26,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: provider.selectedColor.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Seçili',
                      style: TextStyle(fontSize: 10),
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
                    width: 50,
                    height: 50,
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
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    for (int i = 0; i < AppTheme.colorPalette.length; i += 1)
                      _ColorButton(
                        color: AppTheme.colorPalette[i],
                        isSelected: provider.selectedColor == AppTheme.colorPalette[i],
                        onTap: () {
                          provider.setSelectedColor(AppTheme.colorPalette[i]);
                          SoundService().playColorSelectSound();
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showColorPicker(BuildContext context, ColoringProvider provider) {
    Color selectedColor = provider.selectedColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renk Seç'),
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
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setSelectedColor(selectedColor);
              SoundService().playColorSelectSound();
              Navigator.pop(context);
            },
            child: const Text('Seç'),
          ),
        ],
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
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
                    color: color.withOpacity(0.5),
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
