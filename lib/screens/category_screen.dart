import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';
import '../models/coloring_image.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import 'coloring_screen.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final AdService _adService = AdService();
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _adService.disposeBannerAd();
    super.dispose();
  }

  void _loadBannerAd() {
    final provider = context.read<AppProvider>();
    // Pro kullanicilara reklam gosterme
    if (provider.settings.isPro) return;

    _adService.loadBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() => _isBannerLoaded = true);
        }
      },
      onAdFailed: () {
        if (mounted) {
          setState(() => _isBannerLoaded = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final images = provider.getImagesForCategory(widget.category.id);

          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.category.icon,
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

          return Column(
            children: [
              // Banner reklam alani
              if (_isBannerLoaded && _adService.bannerAd != null && !provider.settings.isPro)
                Container(
                  alignment: Alignment.center,
                  width: _adService.bannerAd!.size.width.toDouble(),
                  height: _adService.bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _adService.bannerAd!),
                ),
              // Resim gridi
              Expanded(
                child: GridView.builder(
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
                ),
              ),
            ],
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
                        Colors.black.withOpacity(0.6),
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
              // Firebase badge
              if (image.isFromFirebase)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'YENİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  Widget _buildImage() {
    if (image.isFromFirebase) {
      return CachedNetworkImage(
        imageUrl: image.imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppTheme.backgroundColor,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppTheme.backgroundColor,
          child: const Center(
            child: Icon(Icons.error_outline, size: 40),
          ),
        ),
      );
    } else if (image.isImported) {
      return Image.asset(
        image.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
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
        },
      );
    } else {
      // Asset image
      return Image.asset(
        image.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
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
        },
      );
    }
  }
}
