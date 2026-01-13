import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/coloring_image.dart';
import '../models/saved_artwork.dart';
import '../providers/app_provider.dart';
import '../providers/coloring_provider.dart';
import '../services/share_service.dart';
import '../services/image_processing_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/color_palette.dart';
import '../widgets/coloring_canvas.dart';

class ColoringScreen extends StatefulWidget {
  final ColoringImage image;
  final SavedArtwork? existingArtwork;

  const ColoringScreen({
    super.key,
    required this.image,
    this.existingArtwork,
  });

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  final ColoringProvider _coloringProvider = ColoringProvider();
  final ShareService _shareService = ShareService();
  final ImageProcessingService _imageProcessingService = ImageProcessingService();
  final SoundService _soundService = SoundService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isFullScreen = false;
  bool _isPanelCollapsed = false;
  String? _artworkId;

  @override
  void initState() {
    super.initState();
    _artworkId = widget.existingArtwork?.id ?? const Uuid().v4();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);

    try {
      Uint8List imageData;

      if (widget.image.isFromFirebase) {
        // Download from Firebase
        final appProvider = context.read<AppProvider>();
        final data = await appProvider.firebaseService.downloadImage(widget.image.imagePath);
        if (data == null) throw Exception('Failed to download image');
        imageData = data;
      } else if (widget.image.isImported) {
        // Load from local file
        final file = File(widget.image.imagePath);
        imageData = await file.readAsBytes();
      } else {
        // Load from assets
        final byteData = await rootBundle.load(widget.image.imagePath);
        imageData = byteData.buffer.asUint8List();
      }

      await _coloringProvider.loadImage(imageData);

      // Load existing artwork colors if editing
      if (widget.existingArtwork != null) {
        _coloringProvider.loadExistingArtwork(
          widget.existingArtwork!.coloredRegions,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim yüklenemedi: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveArtwork() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final appProvider = context.read<AppProvider>();

      // Generate colored image
      final coloredImage = await _coloringProvider.generateColoredImage();

      // Create thumbnail
      final thumbnail = await _imageProcessingService.createThumbnail(coloredImage);

      // Save files
      final imagePath = await appProvider.storageService.saveArtworkImage(
        _artworkId!,
        coloredImage,
      );
      final thumbnailPath = await appProvider.storageService.saveThumbnail(
        _artworkId!,
        thumbnail,
      );

      // Create or update artwork
      final now = DateTime.now();
      final artwork = SavedArtwork(
        id: _artworkId!,
        originalImageId: widget.image.id,
        originalImagePath: widget.image.imagePath,
        savedImagePath: imagePath,
        thumbnailPath: thumbnailPath,
        name: widget.image.name,
        createdAt: widget.existingArtwork?.createdAt ?? now,
        updatedAt: now,
        coloredRegions: _coloringProvider.getColoredRegionsMap(),
      );

      await appProvider.saveArtwork(artwork);
      _soundService.playSuccessSound();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resim kaydedildi! ✓'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydetme hatası: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _shareArtwork() async {
    try {
      final coloredImage = await _coloringProvider.generateColoredImage();
      await _shareService.shareImage(
        coloredImage,
        text: '${widget.image.name} - Cobi Paint ile boyadım! 🎨',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paylaşma hatası: $e')),
        );
      }
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Paylaş',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.share,
                  label: 'Paylaş',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    _shareArtwork();
                  },
                ),
                _ShareOption(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.pop(context);
                    _shareArtwork();
                  },
                ),
                _ShareOption(
                  icon: Icons.camera_alt,
                  label: 'Instagram',
                  color: const Color(0xFFE1306C),
                  onTap: () {
                    Navigator.pop(context);
                    _shareArtwork();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    // Hide/show system UI
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _coloringProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _coloringProvider,
      child: Scaffold(
        backgroundColor: _isFullScreen ? Colors.black : AppTheme.backgroundColor,
        appBar: _isFullScreen
            ? null
            : AppBar(
                title: Text(widget.image.name),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  // Undo
                  Consumer<ColoringProvider>(
                    builder: (context, provider, _) => IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: provider.canUndo
                          ? () {
                              provider.undo();
                              _soundService.playUndoSound();
                            }
                          : null,
                      tooltip: 'Geri Al',
                    ),
                  ),
                  // Redo
                  Consumer<ColoringProvider>(
                    builder: (context, provider, _) => IconButton(
                      icon: const Icon(Icons.redo),
                      onPressed: provider.canRedo
                          ? () {
                              provider.redo();
                              _soundService.playUndoSound();
                            }
                          : null,
                      tooltip: 'İleri Al',
                    ),
                  ),
                  // Clear all
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _showClearConfirmation,
                    tooltip: 'Temizle',
                  ),
                  // Full screen
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: _toggleFullScreen,
                    tooltip: 'Tam Ekran',
                  ),
                  // Share
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _showShareOptions,
                    tooltip: 'Paylaş',
                  ),
                ],
              ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isFullScreen
                ? _buildFullScreenBody()
                : _buildNormalBody(),
        floatingActionButton: _isLoading || _isFullScreen
            ? null
            : FloatingActionButton.extended(
                onPressed: _isSaving ? null : _saveArtwork,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Kaydediliyor...' : 'Kaydet'),
              ),
      ),
    );
  }

  Widget _buildNormalBody() {
    return Stack(
      children: [
        // Canvas area (takes full width)
        Positioned.fill(
          child: Consumer<ColoringProvider>(
            builder: (context, provider, _) {
              if (provider.originalImageData == null) {
                return const Center(
                  child: Text('Resim yüklenemedi'),
                );
              }
              return ColoringCanvas(
                imageData: provider.originalImageData!,
                imageWidth: provider.imageWidth,
                imageHeight: provider.imageHeight,
                coloredPixels: provider.coloredPixels,
                coloredPixelsVersion: provider.coloredPixelsVersion,
                scale: provider.scale,
                offset: provider.offset,
                currentTool: provider.currentTool,
                selectedColor: provider.selectedColor,
                brushSize: provider.brushSize,
                onTap: (x, y) {
                  if (provider.currentTool == DrawingTool.fill) {
                    final filledPixels = provider.fillArea(x, y);
                    if (filledPixels > 0) {
                      // Play splash for large areas (>5000 pixels), pop for small
                      if (filledPixels > 5000) {
                        _soundService.playSplashSound();
                      } else {
                        _soundService.playFillSound();
                      }
                    }
                  }
                },
                onScaleChanged: (scale) => provider.setScale(scale),
                onOffsetChanged: (offset) => provider.setOffset(offset),
                onDraw: (points, color, size) {
                  provider.drawStroke(points, color, size);
                  _soundService.playDrawSound();
                },
                onErase: (points, size) {
                  provider.erase(points, size);
                },
              );
            },
          ),
        ),
        // Zoom buttons (bottom right, semi-transparent)
        Positioned(
          right: 16,
          bottom: 100,
          child: _buildZoomButtons(),
        ),
        // Collapsible left panel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          left: _isPanelCollapsed ? -70 : 0,
          top: 0,
          bottom: 0,
          child: Row(
            children: [
              // Panel content
              Container(
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drawing tools
                    _buildToolSelector(),
                    // Brush size slider (only for pencil/eraser)
                    Consumer<ColoringProvider>(
                      builder: (context, provider, _) {
                        if (provider.currentTool == DrawingTool.fill) {
                          return const SizedBox.shrink();
                        }
                        return _buildBrushSizeSlider();
                      },
                    ),
                    // Color palette
                    const Expanded(child: ColorPalette()),
                  ],
                ),
              ),
              // Toggle button
              GestureDetector(
                onTap: () => setState(() => _isPanelCollapsed = !_isPanelCollapsed),
                child: Container(
                  width: 24,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPanelCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolSelector() {
    return Consumer<ColoringProvider>(
      builder: (context, provider, _) {
        return Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToolButton(
                icon: Icons.format_color_fill,
                label: 'Doldur',
                isSelected: provider.currentTool == DrawingTool.fill,
                onTap: () => provider.setCurrentTool(DrawingTool.fill),
              ),
              const SizedBox(height: 8),
              _ToolButton(
                icon: Icons.edit,
                label: 'Kalem',
                isSelected: provider.currentTool == DrawingTool.pencil,
                onTap: () => provider.setCurrentTool(DrawingTool.pencil),
              ),
              const SizedBox(height: 8),
              _ToolButton(
                icon: Icons.auto_fix_high,
                label: 'Silgi',
                isSelected: provider.currentTool == DrawingTool.eraser,
                onTap: () => provider.setCurrentTool(DrawingTool.eraser),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrushSizeSlider() {
    return Consumer<ColoringProvider>(
      builder: (context, provider, _) {
        return Container(
          width: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.brushSize < 1 ? '0.5px' : '${provider.brushSize.round()}px',
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
              RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  width: 80,
                  child: Slider(
                    value: provider.brushSize,
                    min: 0.5,
                    max: 30,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) => provider.setBrushSize(value),
                  ),
                ),
              ),
              const Icon(Icons.brush, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildZoomButtons() {
    return Consumer<ColoringProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom in button
              _ZoomButton(
                icon: Icons.add,
                onTap: provider.scale < 5.0 ? provider.zoomIn : null,
                isTop: true,
              ),
              // Divider
              Container(
                width: 30,
                height: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              // Zoom level indicator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${(provider.scale * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Divider
              Container(
                width: 30,
                height: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              // Zoom out button
              _ZoomButton(
                icon: Icons.remove,
                onTap: provider.scale > 0.5 ? provider.zoomOut : null,
                isBottom: true,
              ),
              // Reset button (only show when zoomed)
              if (provider.scale != 1.0) ...[
                Container(
                  width: 30,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _ZoomButton(
                  icon: Icons.fit_screen,
                  onTap: provider.resetView,
                  isBottom: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullScreenBody() {
    return Stack(
      children: [
        // Canvas takes full screen
        Consumer<ColoringProvider>(
          builder: (context, provider, _) {
            if (provider.originalImageData == null) {
              return const Center(
                child: Text('Resim yüklenemedi', style: TextStyle(color: Colors.white)),
              );
            }
            return ColoringCanvas(
              imageData: provider.originalImageData!,
              imageWidth: provider.imageWidth,
              imageHeight: provider.imageHeight,
              coloredPixels: provider.coloredPixels,
              coloredPixelsVersion: provider.coloredPixelsVersion,
              scale: provider.scale,
              offset: provider.offset,
              currentTool: provider.currentTool,
              selectedColor: provider.selectedColor,
              brushSize: provider.brushSize,
              onTap: (x, y) {
                if (provider.currentTool == DrawingTool.fill) {
                  final filledPixels = provider.fillArea(x, y);
                  if (filledPixels > 0) {
                    // Play splash for large areas (>5000 pixels), pop for small
                    if (filledPixels > 5000) {
                      _soundService.playSplashSound();
                    } else {
                      _soundService.playFillSound();
                    }
                  }
                }
              },
              onScaleChanged: (scale) => provider.setScale(scale),
              onOffsetChanged: (offset) => provider.setOffset(offset),
              onDraw: (points, color, size) {
                provider.drawStroke(points, color, size);
                _soundService.playDrawSound();
              },
              onErase: (points, size) {
                provider.erase(points, size);
              },
            );
          },
        ),
        // Floating toolbar at top
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          right: 8,
          child: _buildFullScreenToolbar(),
        ),
        // Floating color palette and tools at bottom
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 8,
          left: 8,
          right: 8,
          child: _buildFloatingBottomBar(),
        ),
      ],
    );
  }

  Widget _buildFullScreenToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Exit full screen
          IconButton(
            icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
            onPressed: _toggleFullScreen,
            tooltip: 'Tam Ekrandan Çık',
            iconSize: 24,
          ),
          const SizedBox(width: 4),
          // Undo
          Consumer<ColoringProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.undo, color: Colors.white),
              onPressed: provider.canUndo
                  ? () {
                      provider.undo();
                      _soundService.playUndoSound();
                    }
                  : null,
              tooltip: 'Geri Al',
              iconSize: 24,
            ),
          ),
          // Redo
          Consumer<ColoringProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.redo, color: Colors.white),
              onPressed: provider.canRedo
                  ? () {
                      provider.redo();
                      _soundService.playUndoSound();
                    }
                  : null,
              tooltip: 'İleri Al',
              iconSize: 24,
            ),
          ),
          // Reset view
          IconButton(
            icon: const Icon(Icons.zoom_out_map, color: Colors.white),
            onPressed: () => _coloringProvider.resetView(),
            tooltip: 'Görünümü Sıfırla',
            iconSize: 24,
          ),
          const Spacer(),
          // Save
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            onPressed: _isSaving ? null : _saveArtwork,
            tooltip: 'Kaydet',
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Consumer<ColoringProvider>(
      builder: (context, provider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tool selector row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FloatingToolButton(
                    icon: Icons.format_color_fill,
                    isSelected: provider.currentTool == DrawingTool.fill,
                    onTap: () => provider.setCurrentTool(DrawingTool.fill),
                  ),
                  const SizedBox(width: 8),
                  _FloatingToolButton(
                    icon: Icons.edit,
                    isSelected: provider.currentTool == DrawingTool.pencil,
                    onTap: () => provider.setCurrentTool(DrawingTool.pencil),
                  ),
                  const SizedBox(width: 8),
                  _FloatingToolButton(
                    icon: Icons.auto_fix_high,
                    isSelected: provider.currentTool == DrawingTool.eraser,
                    onTap: () => provider.setCurrentTool(DrawingTool.eraser),
                  ),
                  if (provider.currentTool != DrawingTool.fill) ...[
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      child: Slider(
                        value: provider.brushSize,
                        min: 0.5,
                        max: 30,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white30,
                        onChanged: (value) => provider.setBrushSize(value),
                      ),
                    ),
                    Text(
                      provider.brushSize < 1 ? '0.5' : '${provider.brushSize.round()}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Color palette row
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppTheme.colorPalette.length,
                itemBuilder: (context, index) {
                  final color = AppTheme.colorPalette[index];
                  final isSelected = provider.selectedColor == color;
                  return GestureDetector(
                    onTap: () => provider.setSelectedColor(color),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temizle'),
        content: const Text('Tüm boyamayı temizlemek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _coloringProvider.clearAll();
            },
            child: const Text(
              'Temizle',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppTheme.primaryDark, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingToolButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FloatingToolButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white54,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black87 : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isTop;
  final bool isBottom;

  const _ZoomButton({
    required this.icon,
    this.onTap,
    this.isTop = false,
    this.isBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(22) : Radius.zero,
            bottom: isBottom ? const Radius.circular(22) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          color: isDisabled
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.9),
          size: 22,
        ),
      ),
    );
  }
}
