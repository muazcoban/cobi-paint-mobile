import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';
import '../models/coloring_image.dart';
import '../theme/app_theme.dart';
import 'coloring_screen.dart';

class CategoryScreen extends StatelessWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final images = provider.getImagesForCategory(category.id);

          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.icon,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bu kategoride henüz resim yok',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Yakında yeni resimler eklenecek!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
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
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _ImageCard(image: images[index]);
            },
          );
        },
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final ColoringImage image;

  const _ImageCard({required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColoringScreen(image: image),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
              // Image
              _buildImage(),
              // Overlay gradient
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
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Text(
                    image.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Imported pages are files in the app's documents folder, built-in pages are assets
    if (image.isImported) {
      return Image.file(
        File(image.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return Image.asset(
      image.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, size: 40, color: AppTheme.textSecondary),
            const SizedBox(height: 8),
            Text(
              image.name,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
