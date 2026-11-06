import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/builtin_images.dart';
import '../l10n/app_localizations.dart';
import '../services/purchase_service.dart';
import '../widgets/one_line_label.dart';
import 'parents_screen.dart';

/// The only place a price is ever shown: one screen behind the parental
/// gate with the store's own price, a restore button, the privacy policy
/// and, on iOS, the Family Sharing note. No countdowns, no second screen.
class FullVersionScreen extends StatefulWidget {
  const FullVersionScreen({super.key});

  @override
  State<FullVersionScreen> createState() => _FullVersionScreenState();
}

class _FullVersionScreenState extends State<FullVersionScreen> {
  final _purchases = PurchaseService();
  ProductDetails? _product;
  bool _loading = true;

  /// A store call in flight: the buttons wait for it instead of starting a
  /// second one, and a failure is said out loud rather than swallowed.
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final product = await _purchases.loadProduct();
    if (mounted) {
      setState(() {
        _product = product;
        _loading = false;
      });
    }
  }

  Future<void> _run(Future<void> Function() call) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await call();
    } catch (e) {
      debugPrint('Store call failed: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.storeUnavailable)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: OneLineLabel(l10n.fullVersion)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // The count comes from the bundle, so the text grows with the pages.
          Text(l10n.fullVersionDesc(builtInImages.length), style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: _purchases.isFull,
            builder: (context, full, _) {
              if (full) {
                return _Note(icon: Icons.check_circle_outline_rounded, text: l10n.fullVersionOwned);
              }
              return ValueListenableBuilder<bool>(
                valueListenable: _purchases.pending,
                builder: (context, pending, _) {
                  if (pending) return _Note(icon: Icons.hourglass_empty_rounded, text: l10n.purchasePending);
                  if (_loading) return const Center(child: CircularProgressIndicator());
                  final product = _product;
                  if (product == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Note(icon: Icons.cloud_off_rounded, text: l10n.storeUnavailable),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: _load, child: Text(l10n.tryAgain)),
                      ],
                    );
                  }
                  return FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    onPressed: _busy ? null : () => unawaited(_run(() => _purchases.buy(product))),
                    child: Text('${l10n.buy} · ${product.price}', style: const TextStyle(fontSize: 18)),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: _busy ? null : () => unawaited(_run(_purchases.restore)),
            child: Text(l10n.restorePurchases),
          ),
          if (Platform.isIOS) ...[
            const SizedBox(height: 16),
            Text(l10n.familySharingNote, style: const TextStyle(color: Colors.black54)),
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())),
            child: Text(l10n.privacyPolicy),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
