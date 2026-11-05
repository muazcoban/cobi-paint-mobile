import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/saved_artwork.dart';
import '../models/coloring_image.dart';
import '../providers/app_provider.dart';
import '../services/export_service.dart';
import '../services/share_service.dart';
import '../services/sound_service.dart';
import '../widgets/kid_button.dart';
import '../widgets/parental_gate.dart';
import 'coloring_screen.dart';
import 'home_screen.dart' show gridColumns;

/// The child's pictures. Opening one continues it; sharing, saving to the
/// gallery, printing and deleting need a grown-up (long press, then the
/// parental gate).
class MyArtworksScreen extends StatelessWidget {
  const MyArtworksScreen({super.key});

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
                  // VoiceOver reads a picture by its page's name in the app's
                  // language; the saved name (always Turkish) is only kept for
                  // pages that are no longer in the app.
                  final pages = provider.pagesById;
                  final languageCode = Localizations.localeOf(context).languageCode;
                  String labelOf(SavedArtwork a) => pages[a.originalImageId]?.localizedName(languageCode) ?? a.name;
                  return LayoutBuilder(
                    builder: (context, constraints) => GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridColumns(constraints.maxWidth),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: provider.savedArtworks.length,
                      itemBuilder: (context, index) {
                        final artwork = provider.savedArtworks[index];
                        return _ArtworkCard(artwork: artwork, label: labelOf(artwork));
                      },
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

  /// What VoiceOver reads for the picture.
  final String label;

  const _ArtworkCard({required this.artwork, required this.label});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<AppProvider>().storageService;
    final file = storage.resolveArtworkFile(
      artwork.thumbnailPath.isNotEmpty ? artwork.thumbnailPath : artwork.savedImagePath,
    );
    return PressableCard(
      semanticLabel: label,
      onTap: () {
        SoundService().playClickSound();
        openArtwork(context, artwork);
      },
      onLongPress: () => _showOptions(context),
      // A framed picture on the wall: wooden frame, white mat, the whole
      // drawing visible. The frame is only decoration, never a reward.
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFC98A4B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFA86A32), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(6),
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.image_rounded, size: 56, color: Color(0xFFB0B3C6))),
          ),
        ),
      ),
    );
  }

  Future<void> _showOptions(BuildContext context) async {
    if (!await showParentalGate(context) || !context.mounted) return;
    // Android's share sheet has no Print or Save, so the gate offers them
    // itself where the device can; iOS has both in the sheet.
    final exports = await ExportService().capabilities();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    final hasBlankPage =
        !artwork.originalImagePath.contains('/imported/') && !artwork.originalImagePath.endsWith('/blank.png');
    // A fresh copy of the same page, only for a page the child can open
    // from a category: not the Draw page, not a page behind the Full
    // Version lock, not one that left the app. Nothing is deleted.
    final catalog = context.read<AppProvider>();
    final page = catalog.pagesById[artwork.originalImageId];
    final freshPage = page != null &&
            !page.freeDraw &&
            catalog.getImagesForCategory(page.category).any((p) => p.id == page.id)
        ? page
        : null;
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
            if (exports.gallery)
              ListTile(
                leading: const Icon(Icons.save_alt_rounded),
                title: Text(l10n.saveToGallery),
                onTap: () => Navigator.pop(sheetContext, 'gallery'),
              ),
            if (exports.print)
              ListTile(
                leading: const Icon(Icons.print_rounded),
                title: Text(l10n.printPicture),
                onTap: () => Navigator.pop(sheetContext, 'print'),
              ),
            if (hasBlankPage)
              // The line art on paper: printed here on Android, through the
              // share sheet's Print and Save elsewhere.
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: Text(exports.print ? l10n.printBlankPage : l10n.shareBlankPage),
                onTap: () => Navigator.pop(sheetContext, exports.print ? 'printBlank' : 'blank'),
              ),
            if (freshPage != null)
              ListTile(
                leading: const Icon(Icons.note_add_outlined),
                title: Text(l10n.paintAgain),
                subtitle: Text(l10n.paintAgainHint),
                onTap: () => Navigator.pop(sheetContext, 'again'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935)),
              title: Text(l10n.delete, style: const TextStyle(color: Color(0xFFD32F2F))), // 5.0:1 on white
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
      case 'gallery':
        try {
          final bytes = await app.storageService.resolveArtworkFile(artwork.savedImagePath).readAsBytes();
          await ExportService().saveToGallery(bytes, name: _exportName(DateTime.now()));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.savedToGallery)));
          }
        } catch (e) {
          debugPrint('Gallery save failed: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.saveError)));
          }
        }
      case 'print':
        try {
          final bytes = await app.storageService.resolveArtworkFile(artwork.savedImagePath).readAsBytes();
          await ExportService().printPicture(bytes, name: artwork.name);
        } catch (e) {
          debugPrint('Print failed: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.printError)));
          }
        }
      case 'printBlank':
        try {
          final data = await rootBundle.load(artwork.originalImagePath);
          await ExportService().printPicture(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            name: artwork.name,
          );
        } catch (e) {
          debugPrint('Blank page print failed: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.printError)));
          }
        }
      case 'blank':
        // The empty page as a file: the system sheet offers Print and Save.
        try {
          final data = await rootBundle.load(artwork.originalImagePath);
          final file = File('${(await getTemporaryDirectory()).path}/blank_page.png');
          await file.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
          if (!context.mounted) return;
          await ShareService().shareArtwork(file.path, text: l10n.shareText, subject: artwork.name, origin: origin);
        } catch (e) {
          debugPrint('Blank page share failed: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.shareError)));
          }
        }
      case 'again':
        // The same page, blank and not tied to this artwork: the first
        // touch saves a new copy, and the old picture stays on the wall.
        await Navigator.push(context, MaterialPageRoute(builder: (_) => ColoringScreen(image: freshPage!)));
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

/// The file name a saved picture gets in the gallery: the app's name and a
/// time stamp, so two saves never collide and the album sorts by date.
String _exportName(DateTime at) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'cobi_paint_${at.year}${two(at.month)}${two(at.day)}_${two(at.hour)}${two(at.minute)}${two(at.second)}';
}

/// Opens a saved artwork on its page. Works for built-in pages, pages
/// imported before the freeze and pages that no longer exist in the app.
void openArtwork(BuildContext context, SavedArtwork artwork) {
  final app = context.read<AppProvider>();
  final page = app.pagesById[artwork.originalImageId] ??
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
