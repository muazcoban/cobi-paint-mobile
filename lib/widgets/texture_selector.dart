import 'package:flutter/material.dart';
import '../utils/paint_textures.dart';
import '../theme/app_theme.dart';

/// Doku seçimi widget'ı
class TextureSelector extends StatelessWidget {
  final PaintTexture selectedTexture;
  final ValueChanged<PaintTexture> onTextureChanged;

  const TextureSelector({
    super.key,
    required this.selectedTexture,
    required this.onTextureChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doku',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PaintTexture.values.map((texture) {
            final isSelected = texture == selectedTexture;
            return GestureDetector(
              onTap: () => onTextureChanged(texture),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      texture.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      texture.displayName,
                      style: TextStyle(
                        fontSize: 8,
                        color: isSelected ? AppTheme.primaryColor : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Kompakt doku seçimi (floating bar için)
class TextureSelectorCompact extends StatelessWidget {
  final PaintTexture selectedTexture;
  final ValueChanged<PaintTexture> onTextureChanged;

  const TextureSelectorCompact({
    super.key,
    required this.selectedTexture,
    required this.onTextureChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: PaintTexture.values.map((texture) {
        final isSelected = texture == selectedTexture;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: () => onTextureChanged(texture),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  texture.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
