import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AppProvider, PurchaseService>(
        builder: (context, appProvider, purchaseService, _) {
          return CustomScrollView(
            slivers: [
              // Custom App Bar with gradient
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.amber,
                          Colors.orange,
                          Colors.deepOrange,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          const Icon(
                            Icons.star,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Cobi Paint Pro',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sınırsız yaratıcılık!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Features
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pro Özellikleri',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _FeatureTile(
                        icon: Icons.all_inclusive,
                        title: 'Sınırsız İçe Aktarma',
                        description:
                            'İstediğiniz kadar resmi içe aktarın ve boyama sayfasına dönüştürün.',
                        isPro: true,
                      ),
                      const _FeatureTile(
                        icon: Icons.cloud_download,
                        title: 'Yeni Resimler',
                        description:
                            'Firebase\'den yüklenen tüm yeni resimlere erişin.',
                        isPro: true,
                      ),
                      const _FeatureTile(
                        icon: Icons.palette,
                        title: 'Ekstra Renkler',
                        description:
                            'Genişletilmiş renk paletine erişim.',
                        isPro: true,
                      ),
                      const _FeatureTile(
                        icon: Icons.block,
                        title: 'Reklamsız',
                        description: 'Hiçbir reklam görmeden boyama keyfi.',
                        isPro: true,
                      ),
                      const _FeatureTile(
                        icon: Icons.support_agent,
                        title: 'Öncelikli Destek',
                        description:
                            'Sorularınıza öncelikli yanıt.',
                        isPro: true,
                      ),

                      const SizedBox(height: 30),

                      // Pricing
                      const Text(
                        'Fiyatlandırma',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Monthly subscription
                      _PricingCard(
                        title: 'Aylık',
                        price: '₺29.99',
                        period: '/ay',
                        features: const [
                          'Tüm Pro özellikleri',
                          'İstediğiniz zaman iptal',
                        ],
                        onTap: () => _purchase(context, purchaseService, false),
                        isLoading: purchaseService.loading,
                      ),
                      const SizedBox(height: 16),

                      // Lifetime
                      _PricingCard(
                        title: 'Ömür Boyu',
                        price: '₺149.99',
                        period: 'tek seferlik',
                        features: const [
                          'Tüm Pro özellikleri',
                          'Sınırsız süre',
                          'Gelecek güncellemeler dahil',
                        ],
                        isRecommended: true,
                        onTap: () => _purchase(context, purchaseService, true),
                        isLoading: purchaseService.loading,
                      ),

                      const SizedBox(height: 20),

                      // Restore purchases
                      Center(
                        child: TextButton(
                          onPressed: () => _restore(context, purchaseService),
                          child: const Text('Satın Alımları Geri Yükle'),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Terms
                      const Text(
                        'Satın alma işlemi tamamlandığında Apple/Google hesabınızdan ödeme alınır. '
                        'Abonelik, mevcut dönem bitmeden en az 24 saat önce iptal edilmedikçe otomatik olarak yenilenir.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _purchase(
    BuildContext context,
    PurchaseService purchaseService,
    bool lifetime,
  ) async {
    try {
      final success = await purchaseService.buyPro(lifetime: lifetime);
      if (success && context.mounted) {
        // Update app provider
        context.read<AppProvider>().setPro(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pro satın alındı! Teşekkürler!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _restore(
    BuildContext context,
    PurchaseService purchaseService,
  ) async {
    try {
      await purchaseService.restorePurchases();
      if (context.mounted) {
        if (purchaseService.isPro) {
          context.read<AppProvider>().setPro(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pro geri yüklendi!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Geri yüklenecek satın alım bulunamadı'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isPro;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isPro) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isRecommended;
  final VoidCallback onTap;
  final bool isLoading;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    this.isRecommended = false,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isRecommended
            ? Border.all(color: Colors.amber, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'En Popüler',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  period,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(f),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended
                    ? Colors.amber
                    : AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Satın Al'),
            ),
          ),
        ],
      ),
    );
  }
}
