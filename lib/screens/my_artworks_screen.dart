import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_artwork.dart';
import '../models/coloring_image.dart';
import '../providers/app_provider.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import 'coloring_screen.dart';

class MyArtworksScreen extends StatelessWidget {
  const MyArtworksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resimlerim'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.savedArtworks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.collections_outlined,
                    size: 100,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Henüz kayıtlı resim yok',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Boyamaya başla ve\neserlerini burada gör!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Show hint to use bottom navigation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Boyama sekmesine geçmek için alttaki "Boyama" butonuna tıklayın'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.palette),
                    label: const Text('Boyamaya Başla'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: provider.savedArtworks.length,
            itemBuilder: (context, index) {
              return _ArtworkCard(
                artwork: provider.savedArtworks[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _ArtworkCard extends StatelessWidget {
  final SavedArtwork artwork;

  const _ArtworkCard({required this.artwork});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openArtwork(context),
      onLongPress: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              _buildThumbnail(),
              // Info overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        artwork.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(artwork.updatedAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // More options button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _showOptions(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final file = File(artwork.thumbnailPath.isNotEmpty
        ? artwork.thumbnailPath
        : artwork.savedImagePath);

    if (!file.existsSync()) {
      return Container(
        color: AppTheme.backgroundColor,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 40,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppTheme.backgroundColor,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 40,
              color: AppTheme.textSecondary,
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Bugün';
    } else if (diff.inDays == 1) {
      return 'Dün';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _openArtwork(BuildContext context) {
    final appProvider = context.read<AppProvider>();

    // Find original image
    ColoringImage? originalImage;

    // Check static images
    for (final img in appProvider.staticImages) {
      if (img.id == artwork.originalImageId) {
        originalImage = img;
        break;
      }
    }

    // Check imported images
    if (originalImage == null) {
      for (final img in appProvider.importedImages) {
        if (img.id == artwork.originalImageId) {
          originalImage = img;
          break;
        }
      }
    }

    // Check Firebase images
    if (originalImage == null) {
      for (final img in appProvider.firebaseImages) {
        if (img.id == artwork.originalImageId) {
          originalImage = img;
          break;
        }
      }
    }

    // If not found, create a placeholder
    if (originalImage == null) {
      originalImage = ColoringImage(
        id: artwork.originalImageId,
        name: artwork.name,
        category: '',
        imagePath: artwork.originalImagePath,
        isImported: artwork.originalImagePath.contains('/imported/'),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColoringScreen(
          image: originalImage!,
          existingArtwork: artwork,
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
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
            Text(
              artwork.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.edit,
              title: 'Düzenle',
              onTap: () {
                Navigator.pop(context);
                _openArtwork(context);
              },
            ),
            _OptionTile(
              icon: Icons.share,
              title: 'Paylaş',
              onTap: () async {
                Navigator.pop(context);
                try {
                  final file = File(artwork.savedImagePath);
                  if (await file.exists()) {
                    final shareService = ShareService();
                    await shareService.shareArtwork(
                      artwork.savedImagePath,
                      artworkName: artwork.name,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Paylaşma hatası: $e')),
                    );
                  }
                }
              },
            ),
            _OptionTile(
              icon: Icons.delete_outline,
              title: 'Sil',
              color: AppTheme.errorColor,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Silmek istediğinize emin misiniz?'),
        content: Text('"${artwork.name}" kalıcı olarak silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppProvider>().deleteArtwork(artwork.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resim silindi'),
                ),
              );
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
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }
}
