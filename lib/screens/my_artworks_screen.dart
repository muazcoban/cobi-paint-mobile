import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/saved_artwork.dart';
import '../models/coloring_image.dart';
import '../providers/app_provider.dart';
import '../services/share_service.dart';
import '../services/sound_service.dart';
import '../widgets/kid_button.dart';
import '../widgets/parental_gate.dart';
import 'coloring_screen.dart';
import 'home_screen.dart' show gridColumns;

/// The child's pictures. Opening one continues it; sharing and deleting
/// need a grown-up (long press, then the parental gate).
class MyArtworksScreen extends StatelessWidget {
  const MyArtworksScreen({super.key});

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
                  Expanded(
                    child: Text(
                      l10n.myArtworks,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF2D3142)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  if (provider.savedArtworks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.collections_rounded, size: 120, color: Color(0xFFFFB74D)),
                          const SizedBox(height: 24),
                          KidButton(
                            icon: Icons.palette_rounded,
                            size: 96,
                            color: const Color(0xFF43A047),
                            iconColor: Colors.white,
                            semanticLabel: l10n.startColoring,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) => GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridColumns(constraints.maxWidth),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: provider.savedArtworks.length,
                      itemBuilder: (context, index) => _ArtworkCard(artwork: provider.savedArtworks[index]),
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

class _ArtworkCard extends StatelessWidget {
  final SavedArtwork artwork;

  const _ArtworkCard({required this.artwork});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<AppProvider>().storageService;
    final file = storage.resolveArtworkFile(
      artwork.thumbnailPath.isNotEmpty ? artwork.thumbnailPath : artwork.savedImagePath,
    );
    return PressableCard(
      semanticLabel: artwork.name,
      onTap: () {
        SoundService().playClickSound();
        openArtwork(context, artwork);
      },
      onLongPress: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.image_rounded, size: 56, color: Color(0xFFB0B3C6))),
        ),
      ),
    );
  }

  Future<void> _showOptions(BuildContext context) async {
    if (!await showParentalGate(context) || !context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share_rounded),
              title: Text(l10n.share),
              onTap: () => Navigator.pop(sheetContext, 'share'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935)),
              title: Text(l10n.delete, style: const TextStyle(color: Color(0xFFE53935))),
              onTap: () => Navigator.pop(sheetContext, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    final app = context.read<AppProvider>();
    switch (action) {
      case 'share':
        try {
          final path = app.storageService.resolveArtworkFile(artwork.savedImagePath).path;
          await ShareService().shareArtwork(path, text: l10n.shareText, subject: artwork.name, origin: origin);
        } catch (e) {
          debugPrint('Share failed: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.shareError)));
          }
        }
      case 'delete':
        final yes = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.deleteConfirmTitle),
            content: Text(l10n.deleteConfirmMessage),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
              TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.delete)),
            ],
          ),
        );
        if (yes == true) await app.deleteArtwork(artwork.id);
    }
  }
}

/// Opens a saved artwork on its page. Works for built-in pages, pages
/// imported before the freeze and pages that no longer exist in the app.
void openArtwork(BuildContext context, SavedArtwork artwork) {
  final app = context.read<AppProvider>();
  final page =
      [...app.staticImages, ...app.importedImages].where((img) => img.id == artwork.originalImageId).firstOrNull ??
      ColoringImage(
        id: artwork.originalImageId,
        name: artwork.name,
        category: '',
        imagePath: artwork.originalImagePath,
        isImported: artwork.originalImagePath.contains('/imported/'),
      );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ColoringScreen(image: page, existingArtwork: artwork),
    ),
  );
}
