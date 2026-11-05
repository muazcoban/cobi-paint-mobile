import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../data/free_pages.dart';
import '../models/category.dart';
import '../models/saved_artwork.dart';
import '../providers/app_provider.dart';
import '../services/sound_service.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kid_button.dart';
import '../widgets/parental_gate.dart';
import 'category_screen.dart';
import 'coloring_screen.dart';
import 'my_artworks_screen.dart';
import 'parents_screen.dart';

/// Columns for picture grids: big tiles on phones, more on tablets.
int gridColumns(double width) => width >= 900 ? 4 : (width >= 560 ? 3 : 2);

/// One screen, no tabs: the child chooses a category or their pictures.
/// Everything for grown-ups sits behind the small gear and the gate.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The home screen is the root: a system back must not close the app.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final columns = gridColumns(constraints.maxWidth);
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _Header(onParents: () => _openParents(context))),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: _GalleryCard(
                            latest: provider.savedArtworks.isEmpty ? null : provider.savedArtworks.first,
                            label: l10n.myArtworks,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.95,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => index == 0
                                ? const _DrawCard()
                                : _CategoryCard(category: provider.categories[index - 1]),
                            childCount: provider.categories.length + 1,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openParents(BuildContext context) async {
    if (!await showParentalGate(context) || !context.mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentsScreen()));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onParents});

  final VoidCallback onParents;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          ClipOval(child: Image.asset('assets/images/app_icon.png', width: 64, height: 64)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Cobi Paint',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
          ),
          // Grown-up entrance: small, grey and gated on purpose.
          IconButton(
            tooltip: l10n.parentsArea,
            iconSize: 26,
            icon: const Icon(Icons.settings_rounded, color: Color(0xFF7D8297)),
            onPressed: onParents,
          ),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.latest, required this.label});

  final SavedArtwork? latest;
  final String label;

  @override
  Widget build(BuildContext context) {
    final storage = context.read<AppProvider>().storageService;
    final palette = AppTheme.current;
    final thumb = latest == null
        ? null
        : storage.resolveArtworkFile(latest!.thumbnailPath.isNotEmpty ? latest!.thumbnailPath : latest!.savedImagePath);
    return PressableCard(
      semanticLabel: label,
      onTap: () {
        SoundService().playClickSound();
        sayName(context, 'artworks');
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyArtworksScreen()));
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          // The one card that takes the parents' theme; the tool buttons keep
          // their fixed colours because a three-year-old learns them.
          gradient: LinearGradient(colors: palette.cardGradient),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              clipBehavior: Clip.antiAlias,
              child: thumb != null && thumb.existsSync()
                  ? Image.file(thumb, fit: BoxFit.cover)
                  : Icon(Icons.collections_rounded, size: 56, color: palette.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                // Dark text: white on the yellow-orange gradient was below 2.4:1.
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF2D3142)),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 48, color: Color(0xFF2D3142)),
          ],
        ),
      ),
    );
  }
}

/// Blank page for free drawing: one card, always in the same place.
class _DrawCard extends StatelessWidget {
  const _DrawCard();

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)!.freeDraw;
    return PressableCard(
      semanticLabel: label,
      onTap: () {
        SoundService().playClickSound();
        sayName(context, 'draw');
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ColoringScreen(image: freeDrawPage)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: FittedBox(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('🖍️', style: TextStyle(fontSize: 72)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final name = categoryName(AppLocalizations.of(context)!, category);
    return PressableCard(
      semanticLabel: name,
      onTap: () {
        SoundService().playClickSound();
        sayName(context, 'category_${category.id}');
        Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryScreen(category: category)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(category.icon, style: const TextStyle(fontSize: 72)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Speaks a recorded name for a child who cannot read; silent with a
/// screen reader or without the clip.
void sayName(BuildContext context, String key) {
  unawaited(VoiceService().say(
    key,
    languageCode: Localizations.localeOf(context).languageCode,
    screenReader: MediaQuery.accessibleNavigationOf(context),
  ));
}

/// Localised category name; the model only stores Turkish and English.
String categoryName(AppLocalizations l10n, Category category) {
  switch (category.id) {
    case 'animals':
      return l10n.animals;
    case 'plants':
      return l10n.plants;
    case 'vehicles':
      return l10n.vehicles;
    case 'characters':
      return l10n.characters;
    case 'nature':
      return l10n.nature;
    case 'food':
      return l10n.food;
    case 'things':
      return l10n.things;
    case 'import':
      return l10n.importedPages;
    default:
      return l10n.localeName.startsWith('tr') ? category.name : category.nameEn;
  }
}
