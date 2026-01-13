import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/coloring_image.dart';
import '../providers/app_provider.dart';
import '../services/image_processing_service.dart';
import '../theme/app_theme.dart';
import 'coloring_screen.dart';
import 'pro_screen.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageProcessingService _imageProcessingService = ImageProcessingService();

  bool _isProcessing = false;
  Uint8List? _originalImage;
  Uint8List? _processedImage;

  // Processing parameters
  int _edgeThreshold = 30;
  int _lineThickness = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İçe Aktar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final canImport = provider.settings.canImportToday();
          // Temporarily commented out - used with import limit card
          // final remaining = provider.settings.getRemainingImports();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Import limit info - temporarily hidden for initial launch
                // TODO: Uncomment when ready to enable in-app purchases
                // _ImportLimitCard(
                //   remaining: remaining,
                //   isPro: provider.settings.isPro,
                //   canImport: canImport,
                // ),
                // const SizedBox(height: 20),

                // Select image button
                if (_originalImage == null) ...[
                  _SelectImageCard(
                    canImport: canImport,
                    onSelectFromGallery: canImport ? _selectFromGallery : null,
                    onSelectFromCamera: canImport ? _selectFromCamera : null,
                    onUpgradeToPro: () => _navigateToProScreen(context),
                  ),
                ] else ...[
                  // Preview section
                  _PreviewSection(
                    originalImage: _originalImage!,
                    processedImage: _processedImage,
                    isProcessing: _isProcessing,
                  ),
                  const SizedBox(height: 20),

                  // Processing options
                  if (!_isProcessing && _processedImage != null) ...[
                    _ProcessingOptions(
                      edgeThreshold: _edgeThreshold,
                      lineThickness: _lineThickness,
                      onEdgeThresholdChanged: (value) {
                        setState(() => _edgeThreshold = value.round());
                        _reprocessImage();
                      },
                      onLineThicknessChanged: (value) {
                        setState(() => _lineThickness = value.round());
                        _reprocessImage();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _resetSelection,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Yeniden Seç'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _saveAndStartColoring(provider),
                            icon: const Icon(Icons.palette),
                            label: const Text('Boyamaya Başla'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],

                const SizedBox(height: 30),

                // Imported images list
                if (provider.importedImages.isNotEmpty) ...[
                  const Text(
                    'Daha Önce İçe Aktarılanlar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: provider.importedImages.length,
                    itemBuilder: (context, index) {
                      final image = provider.importedImages[index];
                      return _ImportedImageTile(
                        image: image,
                        onTap: () => _openColoringScreen(image),
                        onDelete: () => _deleteImportedImage(provider, image),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _originalImage = bytes;
          _processedImage = null;
        });
        await _processImage(bytes);
      }
    } catch (e) {
      _showError('Resim seçilemedi: $e');
    }
  }

  Future<void> _selectFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _originalImage = bytes;
          _processedImage = null;
        });
        await _processImage(bytes);
      }
    } catch (e) {
      _showError('Resim çekilemedi: $e');
    }
  }

  Future<void> _processImage(Uint8List imageData) async {
    setState(() => _isProcessing = true);

    try {
      final processed = await _imageProcessingService.convertToColoringPage(
        imageData,
        edgeThreshold: _edgeThreshold,
        lineThickness: _lineThickness,
      );

      setState(() {
        _processedImage = processed;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('Resim işlenemedi: $e');
    }
  }

  Future<void> _reprocessImage() async {
    if (_originalImage == null) return;
    await _processImage(_originalImage!);
  }

  void _resetSelection() {
    setState(() {
      _originalImage = null;
      _processedImage = null;
      _edgeThreshold = 30;
      _lineThickness = 2;
    });
  }

  Future<void> _saveAndStartColoring(AppProvider provider) async {
    if (_processedImage == null) return;

    try {
      // Save the processed image
      final imagePath = await provider.storageService.saveImportedImage(_processedImage!);

      // Create image metadata
      final uuid = const Uuid();
      final image = ColoringImage(
        id: uuid.v4(),
        name: 'İçe Aktarılan ${DateTime.now().day}.${DateTime.now().month}',
        category: 'import',
        imagePath: imagePath,
        isImported: true,
        createdAt: DateTime.now(),
      );

      // Save metadata and increment count
      await provider.addImportedImage(image);
      await provider.incrementImportCount();

      // Open coloring screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ColoringScreen(image: image),
          ),
        );
      }
    } catch (e) {
      _showError('Kaydetme hatası: $e');
    }
  }

  void _openColoringScreen(ColoringImage image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColoringScreen(image: image),
      ),
    );
  }

  void _deleteImportedImage(AppProvider provider, ColoringImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Silmek istediğinize emin misiniz?'),
        content: const Text('Bu resim kalıcı olarak silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.removeImportedImage(image.id);
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

  void _navigateToProScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProScreen()),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _ImportLimitCard extends StatelessWidget {
  final int remaining;
  final bool isPro;
  final bool canImport;

  const _ImportLimitCard({
    required this.remaining,
    required this.isPro,
    required this.canImport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPro
            ? Colors.amber.withOpacity(0.1)
            : canImport
                ? AppTheme.primaryColor.withOpacity(0.1)
                : AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPro
              ? Colors.amber
              : canImport
                  ? AppTheme.primaryColor
                  : AppTheme.errorColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPro
                  ? Colors.amber
                  : canImport
                      ? AppTheme.primaryColor
                      : AppTheme.errorColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPro ? Icons.star : Icons.photo_library,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro
                      ? 'Pro Üye'
                      : canImport
                          ? 'İçe Aktarma Hakkı'
                          : 'Limit Doldu',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPro
                      ? 'Sınırsız içe aktarma hakkınız var!'
                      : canImport
                          ? 'Bugün $remaining hak kaldı'
                          : 'Yarın tekrar deneyin veya Pro olun',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectImageCard extends StatelessWidget {
  final bool canImport;
  final VoidCallback? onSelectFromGallery;
  final VoidCallback? onSelectFromCamera;
  final VoidCallback onUpgradeToPro;

  const _SelectImageCard({
    required this.canImport,
    this.onSelectFromGallery,
    this.onSelectFromCamera,
    required this.onUpgradeToPro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 80,
            color: canImport ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
          const SizedBox(height: 20),
          Text(
            canImport
                ? 'Bir resim seçin'
                : 'Günlük limit doldu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: canImport ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canImport
                ? 'Seçtiğiniz resim boyama için\nsiyah-beyaz çizgiye dönüştürülecek'
                : 'Pro üye olarak sınırsız içe aktarın',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (canImport) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSelectFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSelectFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: onUpgradeToPro,
              icon: const Icon(Icons.star),
              label: const Text('Pro\'ya Yükselt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final Uint8List originalImage;
  final Uint8List? processedImage;
  final bool isProcessing;

  const _PreviewSection({
    required this.originalImage,
    this.processedImage,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ImagePreview(
                  title: 'Orijinal',
                  imageData: originalImage,
                ),
              ),
              Expanded(
                child: isProcessing
                    ? const _LoadingPreview()
                    : processedImage != null
                        ? _ImagePreview(
                            title: 'Boyama için',
                            imageData: processedImage!,
                          )
                        : const _ErrorPreview(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String title;
  final Uint8List imageData;

  const _ImagePreview({
    required this.title,
    required this.imageData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageData,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _LoadingPreview extends StatelessWidget {
  const _LoadingPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            'İşleniyor...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPreview extends StatelessWidget {
  const _ErrorPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 40,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Hata oluştu',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingOptions extends StatelessWidget {
  final int edgeThreshold;
  final int lineThickness;
  final ValueChanged<double> onEdgeThresholdChanged;
  final ValueChanged<double> onLineThicknessChanged;

  const _ProcessingOptions({
    required this.edgeThreshold,
    required this.lineThickness,
    required this.onEdgeThresholdChanged,
    required this.onLineThicknessChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ayarlar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Text('Kenar Hassasiyeti: $edgeThreshold'),
          Slider(
            value: edgeThreshold.toDouble(),
            min: 10,
            max: 100,
            divisions: 18,
            onChanged: onEdgeThresholdChanged,
          ),
          Text('Çizgi Kalınlığı: $lineThickness'),
          Slider(
            value: lineThickness.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: onLineThicknessChanged,
          ),
        ],
      ),
    );
  }
}

class _ImportedImageTile extends StatelessWidget {
  final ColoringImage image;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ImportedImageTile({
    required this.image,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(image.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.backgroundColor,
                child: const Icon(Icons.error_outline),
              );
            },
          ),
        ),
      ),
    );
  }
}
