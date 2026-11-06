import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cobi_paint_mobile/data/builtin_scenes.dart';
import 'package:cobi_paint_mobile/data/scene_gate.dart';
import 'package:cobi_paint_mobile/engine/region/region_service.dart';
import 'package:cobi_paint_mobile/engine/scene/scene_placement.dart';
import 'package:cobi_paint_mobile/models/coloring_image.dart';
import 'package:cobi_paint_mobile/models/scene.dart';
import 'package:cobi_paint_mobile/screens/scene/scene_page.dart';
import 'package:flutter_test/flutter_test.dart';

ScenePiece piece(String key) => gardenScene.pieces.firstWhere((p) => p.key == key);
SceneSlot slot(int id) => gardenScene.slots.firstWhere((s) => s.id == id);

void main() {
  group('placement', () {
    test('Minik has four pieces and four slots, Büyük six, always in the same order', () {
      final little = ScenePlacement(gardenScene, big: false);
      final big = ScenePlacement(gardenScene, big: true);
      expect([for (final p in little.pieces) p.key], ['sun', 'house', 'tree', 'flower']);
      expect([for (final p in big.pieces) p.key], ['sun', 'house', 'tree', 'flower', 'cloud', 'bird']);
      expect(little.slots, hasLength(4));
      expect(big.slots, hasLength(6));
      expect(little.slots.where((s) => s.sky), hasLength(1));
      expect(big.slots.where((s) => s.sky), hasLength(3));
    });

    test('a tap sends a piece to its own slot', () {
      final placement = ScenePlacement(gardenScene, big: false);
      for (final p in placement.pieces) {
        final target = placement.slotForTap(p)!;
        expect(target.id, p.slot, reason: p.key);
        placement.place(p, target);
      }
      expect(placement.isComplete, isTrue);
      expect(placement.slotForTap(piece('sun')), isNull, reason: 'a placed piece goes nowhere');
    });

    test('when another piece took its slot, a tap sends it to the free slot nearest its own', () {
      final placement = ScenePlacement(gardenScene, big: false);
      placement.place(piece('house'), slot(0));
      // The sun's own slot is the sky's; the tree's slot below it is nearest.
      expect(placement.slotForTap(piece('sun'))!.id, 2);
    });

    test('the nearest free slot skips the taken ones', () {
      final placement = ScenePlacement(gardenScene, big: false);
      final nearSun = slot(0).rect.center;
      expect(placement.nearestFree(nearSun)!.id, 0);
      placement.place(piece('flower'), slot(0));
      expect(placement.nearestFree(nearSun)!.id, 2);
      expect(placement.nearestFree(const Offset(0, 1024))!.id, 1);
    });

    test('a piece goes in once and a slot holds one piece', () {
      final placement = ScenePlacement(gardenScene, big: false);
      placement.place(piece('sun'), slot(0));
      expect(() => placement.place(piece('sun'), slot(1)), throwsStateError);
      expect(() => placement.place(piece('house'), slot(0)), throwsStateError);
    });

    test('undo sends the last piece back, redo puts it in the same slot, a new placement drops the redo', () {
      final placement = ScenePlacement(gardenScene, big: true);
      placement.place(piece('sun'), slot(0));
      placement.place(piece('house'), slot(5));
      expect(placement.undo()!.piece.key, 'house');
      expect(placement.isPlaced(piece('house')), isFalse);
      expect(placement.isFree(slot(5)), isTrue);
      expect(placement.canRedo, isTrue);
      final again = placement.redo()!;
      expect((again.piece.key, again.slot.id), ('house', 5));
      placement.undo();
      placement.place(piece('tree'), slot(2));
      expect(placement.canRedo, isFalse);
      expect([for (final s in placement.placed) s.piece.key], ['sun', 'tree']);
    });
  });

  group('scene assets', () {
    final json = jsonDecode(File('tool/scenes/scenes.json').readAsStringSync()) as Map<String, dynamic>;
    final listed = (json['scenes'] as List).cast<Map<String, dynamic>>();

    test('the app\'s scenes match tool/scenes/scenes.json', () {
      expect([for (final s in builtInScenes) s.id], [for (final s in listed) s['id']]);
      for (final (i, scene) in builtInScenes.indexed) {
        final source = listed[i];
        expect(scene.size, (source['size'] as num).toDouble());
        expect([
          for (final s in scene.slots) [s.id, s.rect.left, s.rect.top, s.rect.width, s.sky, s.bigOnly],
        ], [
          for (final s in (source['slots'] as List).cast<Map<String, dynamic>>())
            [s['id'], (s['x'] as num).toDouble(), (s['y'] as num).toDouble(), (s['size'] as num).toDouble(), s['sky'] ?? false, s['big'] ?? false],
        ]);
        expect([for (final p in scene.pieces) [p.key, p.slot, p.tr, p.en, p.bigOnly]], [
          for (final p in (source['pieces'] as List).cast<Map<String, dynamic>>())
            [p['key'], p['slot'], p['tr'], p['en'], p['big'] ?? false],
        ]);
        expect([for (final w in scene.ground) [w.key, w.tr, w.en]], [
          for (final w in (source['ground'] as List).cast<Map<String, dynamic>>()) [w['key'], w['tr'], w['en']],
        ]);
      }
    });

    test('slots stay inside the scene and never overlap; each mode has a slot per piece', () {
      for (final scene in builtInScenes) {
        final bounds = Offset.zero & Size(scene.size, scene.size);
        for (final (i, a) in scene.slots.indexed) {
          expect(bounds.intersect(a.rect), a.rect, reason: 'slot ${a.id}');
          for (final b in scene.slots.skip(i + 1)) {
            expect(a.rect.overlaps(b.rect), isFalse, reason: 'slots ${a.id} and ${b.id}');
          }
        }
        for (final big in [false, true]) {
          expect(scene.slotsFor(big: big).length, scene.piecesFor(big: big).length);
          for (final p in scene.piecesFor(big: big)) {
            expect(scene.slotsFor(big: big).map((s) => s.id), contains(p.slot), reason: p.key);
          }
        }
      }
    });

    test('every drawing is bundled, each piece at its own slot\'s size', () async {
      for (final scene in builtInScenes) {
        final background = await _size(scene.background);
        expect(background, Size(scene.size, scene.size));
        for (final p in scene.pieces) {
          final own = scene.slots.firstWhere((s) => s.id == p.slot);
          expect(await _size(p.asset), own.rect.size, reason: p.key);
        }
      }
    });

    test('the words are the hand-picked ones and every one needs a clip in both languages', () {
      expect([for (final p in gardenScene.pieces) p.en], ['sun', 'house', 'tree', 'flower', 'cloud', 'bird']);
      expect([for (final w in gardenScene.ground) w.en], ['sky', 'grass', 'river']);
      final clips = gardenScene.clipPaths();
      expect(clips, hasLength(20));
      expect(clips, containsAll(['assets/voice/tr/scene.mp3', 'assets/voice/en/word_house.mp3', 'assets/voice/tr/word_river.mp3']));
      expect(piece('sun').label('tr'), 'Güneş, sun');
      expect(piece('house').label('en'), 'House');
    });
  });

  group('the scene card', () {
    test('only an observation build shows it without the clips', () {
      expect(sceneCardAllowed('', clipsBundled: true), isFalse);
      expect(sceneCardAllowed('true', clipsBundled: false), isFalse);
      expect(sceneCardAllowed('true', clipsBundled: true), isTrue);
      expect(sceneCardAllowed('observation', clipsBundled: false), isTrue);
    });

    test('a build without COBI_SCENE has no scene mode', () async {
      expect(sceneModeBuilt, isFalse);
      expect(await sceneCardVisible(), isFalse);
    });

    test('composed scene pages are read from the app\'s files, the scene drawings from the bundle', () {
      expect(isFilePage('/var/mobile/Containers/Data/Application/X/Documents/scenes/garden_1.png'), isTrue);
      expect(isScenePage('/data/user/0/app/app_flutter/scenes/garden_1.png'), isTrue);
      expect(isFilePage('assets/scenes/garden/background.png'), isFalse);
      expect(isFilePage('assets/pages/nature/2600.png'), isFalse);
      expect(isFilePage('/old/container/imported/photo.png'), isTrue);
    });
  });

  group('composed page', () {
    late Directory cache;

    setUp(() => cache = Directory.systemTemp.createTempSync('scene_page_test'));
    tearDown(() => cache.deleteSync(recursive: true));

    testWidgets('the pieces close their regions on the background, the way a page does', (tester) async {
      final empty = ScenePlacement(gardenScene, big: false);
      final full = ScenePlacement(gardenScene, big: false);
      for (final p in full.pieces) {
        full.place(p, full.slotForTap(p)!);
      }
      final service = RegionService(cacheDirectory: () async => cache);
      final counts = await tester.runAsync(() async {
        final bare = await service.labelMapFor(await composeScenePage(empty));
        final page = await service.labelMapFor(await composeScenePage(full));
        return (bare, page);
      });
      final (bare, page) = counts!;
      expect(page.width, 1024);
      // Sky, two grass fields and the river.
      expect(bare.regionCount, 4);
      // Every piece adds closed areas: the sun's disc, the house's walls and
      // door, the tree's crown, the tulip's cup...
      expect(page.regionCount, greaterThan(bare.regionCount + 12));
      // The middle of each piece is a region of its own, not the sky or the
      // grass around it.
      final around = {bare.labelAt(512, 100), bare.labelAt(100, 1000)};
      expect(around, hasLength(2));
      for (final step in full.placed) {
        final c = step.slot.rect.center;
        expect(page.labelAt(c.dx.round(), c.dy.round()), isNot(page.labelAt(512, 100)), reason: step.piece.key);
      }
    });
  });
}

Future<Size> _size(String asset) async {
  final codec = await instantiateImageCodec(File(asset).readAsBytesSync());
  final frame = await codec.getNextFrame();
  final size = Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  frame.image.dispose();
  codec.dispose();
  return size;
}
