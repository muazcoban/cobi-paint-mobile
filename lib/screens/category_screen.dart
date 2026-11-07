import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';
import '../models/coloring_image.dart';
import '../data/page_order.dart';
import '../models/saved_artwork.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kid_button.dart';
import '../widgets/one_line_label.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    child: OneLineLabel(
                      categoryName(l10n, category),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final level = currentLevel(provider.settings, provider.savedArtworks, provider.pagesById);
                  final images = orderPages(provider.getImagesForCategory(category.id), level);
                  if (images.isEmpty) {
                    return Center(child: Text(category.icon, style: const TextStyle(fontSize: 96)));
                  }
                  // The most recently coloured copy of each page: a page can
                  // have several (a grown-up can start it again), and an edit
                  // does not move an artwork in the list.
                  final latest = <String, SavedArtwork>{};
                  for (final a in provider.savedArtworks) {
                    final seen = latest[a.originalImageId];
                    if (seen == null || a.updatedAt.isAfter(seen.updatedAt)) latest[a.originalImageId] = a;
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
                      itemBuilder: (context, index) =>
                          _PageCard(image: images[index], artwork: latest[images[index].id], highlighted: images[index].level == level),
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

  /// Pages of the child's current level get a quiet coloured rim.
  final bool highlighted;

  const _PageCard({required this.image, this.artwork, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      // VoiceOver reads the page name in the app's language.
      semanticLabel: image.localizedName(Localizations.localeOf(context).languageCode),
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
          border: highlighted ? Border.all(color: const Color(0xFFFFD54F), width: 4) : null,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(8),
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final placeholder = Center(child: Icon(Icons.image_rounded, size: 56, color: Colors.grey.shade400));
    final existing = artwork;
    if (existing != null) {
      final storage = context.read<AppProvider>().storageService;
      final file = storage.resolveArtworkFile(
        existing.thumbnailPath.isNotEmpty ? existing.thumbnailPath : existing.savedImagePath,
      );
      return Image.file(file, fit: BoxFit.contain, errorBuilder: (context, error, stack) => _page(placeholder));
    }
    return _page(placeholder);
  }

  // Imported pages are files in the app's documents folder, built-in pages are assets.
  Widget _page(Widget placeholder) => image.isImported
      ? Image.file(File(image.imagePath), fit: BoxFit.contain, errorBuilder: (context, error, stack) => placeholder)
      : Image.asset(image.imagePath, fit: BoxFit.contain, errorBuilder: (context, error, stack) => placeholder);
}
