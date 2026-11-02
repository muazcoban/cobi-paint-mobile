import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';
import '../models/coloring_image.dart';
import '../models/saved_artwork.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kid_button.dart';
import 'coloring_screen.dart';
import 'home_screen.dart' show categoryName, gridColumns;
import 'my_artworks_screen.dart' show openArtwork;

/// Pages of one category. A page the child already coloured shows their
/// colours and opens where they left off.
class CategoryScreen extends StatelessWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  KidButton(
                    icon: Icons.home_rounded,
                    color: const Color(0xFFFFD54F),
                    semanticLabel: l10n.home,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 16),
                  Text(category.icon, style: const TextStyle(fontSize: 44)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      categoryName(l10n, category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final images = provider.getImagesForCategory(category.id);
                  if (images.isEmpty) {
                    return Center(child: Text(category.icon, style: const TextStyle(fontSize: 96)));
                  }
                  // Latest artwork per page: lists are newest first.
                  final latest = <String, SavedArtwork>{};
                  for (final a in provider.savedArtworks) {
                    latest.putIfAbsent(a.originalImageId, () => a);
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) => GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridColumns(constraints.maxWidth),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) => _PageCard(image: images[index], artwork: latest[images[index].id]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  final ColoringImage image;
  final SavedArtwork? artwork;

  const _PageCard({required this.image, this.artwork});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: image.name,
      child: GestureDetector(
        onTap: () {
          SoundService().playClickSound();
          final existing = artwork;
          if (existing != null) {
            openArtwork(context, existing);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ColoringScreen(image: image)));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(8),
          child: _buildImage(context),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final placeholder = Center(child: Icon(Icons.image_rounded, size: 56, color: Colors.grey.shade400));
    final existing = artwork;
    if (existing != null) {
      final storage = context.read<AppProvider>().storageService;
      final file = storage.resolveArtworkFile(existing.thumbnailPath.isNotEmpty ? existing.thumbnailPath : existing.savedImagePath);
      return Image.file(file, fit: BoxFit.contain, errorBuilder: (context, error, stack) => _page(placeholder));
    }
    return _page(placeholder);
  }

  // Imported pages are files in the app's documents folder, built-in pages are assets.
  Widget _page(Widget placeholder) => image.isImported
      ? Image.file(File(image.imagePath), fit: BoxFit.contain, errorBuilder: (context, error, stack) => placeholder)
      : Image.asset(image.imagePath, fit: BoxFit.contain, errorBuilder: (context, error, stack) => placeholder);
}
