import 'dart:io';

import 'package:cobi_paint_mobile/services/rating_prompt.dart';
import 'package:cobi_paint_mobile/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A store that remembers what it was asked.
class FakeStoreReview implements StoreReview {
  FakeStoreReview({this.available = true, this.failing = false});

  bool available;
  bool failing;
  int requests = 0;
  int listings = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    if (failing) throw StateError('store down');
    requests++;
  }

  @override
  Future<void> openStoreListing() async => listings++;
}

void main() {
  final installed = DateTime(2026, 11, 8, 10);

  group('RatingPolicy', () {
    test('asks three days and three pictures after the first launch', () {
      expect(
        RatingPolicy.shouldAsk(
          now: installed.add(const Duration(days: 3)),
          firstLaunchAt: installed,
          artworkCount: 3,
          lastAskedAt: null,
        ),
        isTrue,
      );
    });

    test('never asks before the app is three days old', () {
      expect(
        RatingPolicy.shouldAsk(
          now: installed.add(const Duration(days: 2, hours: 23)),
          firstLaunchAt: installed,
          artworkCount: 10,
          lastAskedAt: null,
        ),
        isFalse,
      );
    });

    test('never asks without a first-launch record', () {
      expect(
        RatingPolicy.shouldAsk(now: installed, firstLaunchAt: null, artworkCount: 10, lastAskedAt: null),
        isFalse,
      );
    });

    test('never asks with fewer than three pictures on the wall', () {
      expect(
        RatingPolicy.shouldAsk(
          now: installed.add(const Duration(days: 30)),
          firstLaunchAt: installed,
          artworkCount: 2,
          lastAskedAt: null,
        ),
        isFalse,
      );
    });

    test('leaves two weeks between requests', () {
      final asked = installed.add(const Duration(days: 5));
      expect(
        RatingPolicy.shouldAsk(
          now: asked.add(const Duration(days: 13)),
          firstLaunchAt: installed,
          artworkCount: 5,
          lastAskedAt: asked,
        ),
        isFalse,
      );
      expect(
        RatingPolicy.shouldAsk(
          now: asked.add(const Duration(days: 14)),
          firstLaunchAt: installed,
          artworkCount: 5,
          lastAskedAt: asked,
        ),
        isTrue,
      );
    });
  });

  group('RatingPrompt', () {
    late Directory docs;
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      docs = Directory.systemTemp.createTempSync('rating_test');
      storage = StorageService(documentsDirectory: () async => docs);
      await storage.init();
      await storage.recordFirstLaunch(installed);
    });

    tearDown(() => docs.deleteSync(recursive: true));

    test('asks the store once the policy allows and remembers when', () async {
      final store = FakeStoreReview();
      var now = installed.add(const Duration(days: 4));
      final prompt = RatingPrompt(storage: storage, review: store, clock: () => now);

      expect(await prompt.maybeAsk(artworkCount: 3), isTrue);
      expect(store.requests, 1);
      expect(await storage.getRatingAskedAt(), now);

      // The next share a week later asks nothing.
      now = now.add(const Duration(days: 7));
      expect(await prompt.maybeAsk(artworkCount: 8), isFalse);
      expect(store.requests, 1);

      // Two weeks after the first request it may ask again.
      now = now.add(const Duration(days: 7));
      expect(await prompt.maybeAsk(artworkCount: 8), isTrue);
      expect(store.requests, 2);
    });

    test('stays quiet while the policy says no', () async {
      final store = FakeStoreReview();
      final prompt = RatingPrompt(storage: storage, review: store, clock: () => installed.add(const Duration(days: 1)));

      expect(await prompt.maybeAsk(artworkCount: 9), isFalse);
      expect(store.requests, 0);
      expect(await storage.getRatingAskedAt(), isNull);
    });

    test('a store that is unavailable or failing is not counted as asked', () async {
      final now = installed.add(const Duration(days: 10));
      final unavailable = FakeStoreReview(available: false);
      expect(await RatingPrompt(storage: storage, review: unavailable, clock: () => now).maybeAsk(artworkCount: 5), isFalse);
      expect(unavailable.requests, 0);

      final failing = FakeStoreReview(failing: true);
      expect(await RatingPrompt(storage: storage, review: failing, clock: () => now).maybeAsk(artworkCount: 5), isFalse);
      expect(await storage.getRatingAskedAt(), isNull, reason: 'a failed request is retried on the next share');
    });

    test('the Parents row opens the store listing and survives a failure', () async {
      final store = FakeStoreReview();
      final prompt = RatingPrompt(storage: storage, review: store);
      await prompt.openStoreListing();
      expect(store.listings, 1);
    });
  });

  test('the first launch is recorded once', () async {
    SharedPreferences.setMockInitialValues({});
    final docs = Directory.systemTemp.createTempSync('rating_first_launch');
    addTearDown(() => docs.deleteSync(recursive: true));
    final storage = StorageService(documentsDirectory: () async => docs);
    await storage.init();

    expect(await storage.getFirstLaunchAt(), isNull);
    await storage.recordFirstLaunch(installed);
    await storage.recordFirstLaunch(installed.add(const Duration(days: 9)));
    expect(await storage.getFirstLaunchAt(), installed);
  });
}
