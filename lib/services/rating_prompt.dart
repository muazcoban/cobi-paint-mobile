import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

import 'storage_service.dart';

/// When the app may ask a grown-up for a rating (plan, 8 Nov 2026).
///
/// Never on a child's screen and never on its own: only right after a
/// grown-up has passed the gate and finished something of their own (shared
/// or saved a picture), at least three days after the first launch, with at
/// least three pictures on the wall, and at most once every two weeks (HIG:
/// "a week or two" between requests). The sheet itself is the system's
/// (App Review 5.6.1), and the system shows it at most three times a year.
abstract final class RatingPolicy {
  static const minimumAge = Duration(days: 3);
  static const minimumArtworks = 3;
  static const minimumGap = Duration(days: 14);

  static bool shouldAsk({
    required DateTime now,
    required DateTime? firstLaunchAt,
    required int artworkCount,
    required DateTime? lastAskedAt,
  }) {
    if (firstLaunchAt == null || now.difference(firstLaunchAt) < minimumAge) return false;
    if (artworkCount < minimumArtworks) return false;
    if (lastAskedAt != null && now.difference(lastAskedAt) < minimumGap) return false;
    return true;
  }
}

/// The store's rating sheet and the app's store page: the plugin in the
/// app, a fake in tests.
abstract class StoreReview {
  Future<bool> isAvailable();
  Future<void> requestReview();
  Future<void> openStoreListing();
}

/// StoreKit on iOS (the sheet does nothing in TestFlight and shows every
/// time in a debug build), Play In-App Review on Android.
class PluginStoreReview implements StoreReview {
  const PluginStoreReview();

  static const appStoreId = '6757766966';

  @override
  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  @override
  Future<void> requestReview() => InAppReview.instance.requestReview();

  /// The App Store's write-a-review page, or the Play listing.
  @override
  Future<void> openStoreListing() => InAppReview.instance.openStoreListing(appStoreId: appStoreId);
}

class RatingPrompt {
  RatingPrompt({required StorageService storage, StoreReview? review, DateTime Function()? clock})
      : _storage = storage,
        _review = review ?? const PluginStoreReview(),
        _clock = clock ?? DateTime.now;

  final StorageService _storage;
  final StoreReview _review;
  final DateTime Function() _clock;

  /// Asks when [RatingPolicy] allows it. Returns whether the system was
  /// asked; the system decides whether the sheet appears.
  Future<bool> maybeAsk({required int artworkCount}) async {
    final now = _clock();
    final allowed = RatingPolicy.shouldAsk(
      now: now,
      firstLaunchAt: await _storage.getFirstLaunchAt(),
      artworkCount: artworkCount,
      lastAskedAt: await _storage.getRatingAskedAt(),
    );
    if (!allowed) return false;
    try {
      if (!await _review.isAvailable()) return false;
      await _review.requestReview();
    } catch (e) {
      // A store that cannot be asked must never break sharing.
      debugPrint('Rating request failed: $e');
      return false;
    }
    await _storage.saveRatingAskedAt(now);
    return true;
  }

  /// The "Rate the app" row in the Parents area: a link out of the app, so
  /// it lives behind the gate (App Review 1.3).
  Future<void> openStoreListing() async {
    try {
      await _review.openStoreListing();
    } catch (e) {
      debugPrint('Store listing failed to open: $e');
    }
  }
}
