import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/category.dart';
import 'category_screen.dart';
import 'my_artworks_screen.dart';
import 'settings_screen.dart';
import 'import_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _CategoriesTab(),
          MyArtworksScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.palette_outlined),
              activeIcon: const Icon(Icons.palette),
              label: l10n.categories,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.collections_outlined),
              activeIcon: const Icon(Icons.collections),
              label: l10n.myArtworks,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cobi Paint'),
        centerTitle: true,
        // Pro badge - temporarily hidden for initial launch
        // TODO: Uncomment when ready to enable in-app purchases
        // actions: [
        //   Consumer<AppProvider>(
        //     builder: (context, provider, _) {
        //       if (provider.settings.isPro) {
        //         return Container(
        //           margin: const EdgeInsets.only(right: 8),
        //           padding: const EdgeInsets.symmetric(
        //             horizontal: 12,
        //             vertical: 4,
        //           ),
        //           decoration: BoxDecoration(
        //             color: Colors.amber,
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //           child: const Row(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               Icon(Icons.star, size: 16, color: Colors.white),
        //               SizedBox(width: 4),
        //               Text(
        //                 'PRO',
        //                 style: TextStyle(
        //                   color: Colors.white,
        //                   fontWeight: FontWeight.bold,
        //                   fontSize: 12,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         );
        //       }
        //       return const SizedBox.shrink();
        //     },
        //   ),
        // ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshFromFirebase(),
            child: CustomScrollView(
              slivers: [
                // Welcome section
                SliverToBoxAdapter(
                  child: _WelcomeSection(),
                ),
                // Categories grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = provider.categories[index];
                        return _CategoryCard(category: category);
                      },
                      childCount: provider.categories.length,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.welcome} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.welcomeMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '🎨',
            style: TextStyle(fontSize: 50),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (category.isImportCategory) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImportScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(category: category),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.icon,
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (category.isImportCategory) ...[
              const SizedBox(height: 4),
              Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final remaining = provider.settings.getRemainingImports();
                  return Text(
                    remaining < 0 ? 'Sınırsız' : '$remaining hak',
                    style: TextStyle(
                      fontSize: 12,
                      color: remaining == 0
                          ? AppTheme.errorColor
                          : AppTheme.textSecondary,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
