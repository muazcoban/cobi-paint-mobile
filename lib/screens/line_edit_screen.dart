import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/line_smoothing.dart';
import '../widgets/drawing_canvas.dart';

/// Çizgi düzenleme ekranı
/// Kullanıcının açık çizgi uçlarını kapatmasını sağlar
class LineEditScreen extends StatefulWidget {
  final Uint8List processedImage;

  const LineEditScreen({
    super.key,
    required this.processedImage,
  });

  @override
  State<LineEditScreen> createState() => _LineEditScreenState();
}

class _LineEditScreenState extends State<LineEditScreen> {
  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey();

  DrawingTool _currentTool = DrawingTool.pen;
  double _strokeWidth = 3.0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çizgi Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showDiscardDialog(),
        ),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _saveAndReturn,
            child: const Text(
              'Tamam',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas alanı
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: DrawingCanvas(
                key: _canvasKey,
                backgroundImage: widget.processedImage,
                currentTool: _currentTool,
                strokeWidth: _strokeWidth,
                strokeColor: Colors.black,
              ),
            ),
          ),

          // Araç çubuğu
          _buildToolbar(),

          // Kalınlık slider
          _buildStrokeWidthSlider(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Kalem
          _ToolButton(
            icon: Icons.edit,
            label: 'Kalem',
            isSelected: _currentTool == DrawingTool.pen,
            onTap: () => setState(() => _currentTool = DrawingTool.pen),
          ),

          // Silgi
          _ToolButton(
            icon: Icons.auto_fix_high,
            label: 'Silgi',
            isSelected: _currentTool == DrawingTool.eraser,
            onTap: () => setState(() => _currentTool = DrawingTool.eraser),
          ),

          // Ayırıcı
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),

          // Geri al
          _ToolButton(
            icon: Icons.undo,
            label: 'Geri',
            isSelected: false,
            enabled: _canvasKey.currentState?.canUndo ?? false,
            onTap: () {
              _canvasKey.currentState?.undo();
              setState(() {});
            },
          ),

          // Yinele
          _ToolButton(
            icon: Icons.redo,
            label: 'İleri',
            isSelected: false,
            enabled: _canvasKey.currentState?.canRedo ?? false,
            onTap: () {
              _canvasKey.currentState?.redo();
              setState(() {});
            },
          ),

          // Temizle
          _ToolButton(
            icon: Icons.delete_outline,
            label: 'Temizle',
            isSelected: false,
            onTap: () => _showClearDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeWidthSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.line_weight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: _strokeWidth,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: '${_strokeWidth.round()}px',
              onChanged: (value) => setState(() => _strokeWidth = value),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${_strokeWidth.round()}px',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDiscardDialog() {
    final hasChanges = _canvasKey.currentState?.lines.isNotEmpty ?? false;

    if (!hasChanges) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değişiklikleri kaydetmeden çık?'),
        content: const Text('Yaptığınız düzenlemeler kaybolacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog'u kapat
              Navigator.pop(this.context); // Ekranı kapat
            },
            child: const Text(
              'Çık',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm çizimleri sil?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _canvasKey.currentState?.clear();
              setState(() {});
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndReturn() async {
    final canvasState = _canvasKey.currentState;
    if (canvasState == null) return;

    // Eğer değişiklik yapılmamışsa orijinali döndür
    if (canvasState.lines.isEmpty) {
      Navigator.pop(context, widget.processedImage);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final renderedImage = await canvasState.renderToImage();
      if (mounted) {
        Navigator.pop(context, renderedImage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydetme hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

/// Araç butonu widget'ı
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? Colors.grey[400]
        : isSelected
            ? AppTheme.primaryColor
            : Colors.grey[700];

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withAlpha(25) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
