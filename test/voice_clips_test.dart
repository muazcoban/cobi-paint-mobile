import 'dart:io';

import 'package:cobi_paint_mobile/data/builtin_scenes.dart';
import 'package:cobi_paint_mobile/engine/document/stroke.dart';
import 'package:cobi_paint_mobile/models/category.dart';
import 'package:cobi_paint_mobile/screens/coloring_screen.dart' show bigPalette;
import 'package:flutter_test/flutter_test.dart';

/// tool/voice/README.md is the list of record for the spoken clips. These
/// tests keep the code, the README and the bundled clips in step with plain
/// file reads and no widget tree, so they pass before a single clip exists.
void main() {
  final readmeKeys = _readmeKeys(File('tool/voice/README.md'));

  test('the README lists both tables, with unique keys of lower-case letters, digits and underscores', () {
    expect(readmeKeys, contains('gate'), reason: 'the main table was read');
    expect(readmeKeys, contains('word_sun'), reason: 'the scene table was read');
    expect(readmeKeys.toSet(), hasLength(readmeKeys.length), reason: 'a key is listed twice');
    final shape = RegExp(r'^[a-z0-9_]+$');
    for (final key in readmeKeys) {
      expect(shape.hasMatch(key), isTrue, reason: '"$key" is not a clip file name');
    }
  });

  test('every key the code speaks has a row in the README', () {
    final spoken = _keysSpokenInCode();
    expect(
      spoken,
      containsAll(['gate', 'fill', 'draw', 'artworks', 'color_0', 'category_animals', 'rainbow', 'scene']),
      reason: 'the scan found the known call sites',
    );
    final missing = spoken.where((key) => !readmeKeys.contains(key)).toList()..sort();
    expect(missing, isEmpty, reason: 'spoken in lib/ but not listed in tool/voice/README.md');
  });

  test('every scene word clip has a row in the README', () {
    final clip = RegExp(r'^assets/voice/(tr|en)/([a-z0-9_]+)\.mp3$');
    for (final scene in builtInScenes) {
      for (final path in scene.clipPaths()) {
        final match = clip.firstMatch(path);
        expect(match, isNotNull, reason: path);
        expect(readmeKeys, contains(match!.group(2)), reason: path);
      }
    }
  });

  for (final lang in ['tr', 'en']) {
    test('assets/voice/$lang is either complete and declared, or absent and undeclared', () {
      final folder = Directory('assets/voice/$lang');
      final pubspec = File('pubspec.yaml').readAsStringSync();
      if (!folder.existsSync()) {
        expect(pubspec, isNot(contains('assets/voice/$lang/')), reason: 'no folder, so no pubspec line');
        return;
      }
      final missing = readmeKeys.where((key) => !File('${folder.path}/$key.mp3').existsSync()).toList();
      expect(missing, isEmpty, reason: 'clips still to record for $lang');
      expect(
        pubspec,
        contains('    - assets/voice/$lang/\n'),
        reason: 'run python3 tool/voice/process_clips.py --pubspec',
      );
    });
  }
}

/// The first cell of every data row of the README's tables, in order.
List<String> _readmeKeys(File readme) {
  final keys = <String>[];
  final separator = RegExp(r'^[-: ]+$');
  for (final line in readme.readAsLinesSync()) {
    if (!line.startsWith('|')) continue;
    // '| a | b | c |' splits into '', a, b, c, ''.
    final cells = line.split('|').map((cell) => cell.trim()).toList();
    if (cells.length < 4) continue;
    final key = cells[1];
    if (key.isEmpty || key == 'Anahtar' || separator.hasMatch(key)) continue;
    keys.add(key);
  }
  return keys;
}

/// The keys of every `_say(...)`, `sayName(context, ...)` and
/// `VoiceService().say(...)` call under lib/, with the patterns expanded:
/// `color_$index` to the big palette, `category_${category.id}` to the
/// coloring categories, and a brush's `.name` to every BrushKind, the marker
/// speaking as `brush`.
Set<String> _keysSpokenInCode() {
  final keys = <String>{};
  final call = RegExp(r'(?:_say|sayName|\.say)\(');
  final literal = RegExp(r"'([^']*)'");
  final files = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final match in call.allMatches(source)) {
      final arguments = _arguments(source, match.end);
      for (final found in literal.allMatches(arguments)) {
        keys.addAll(_expand(found.group(1)!, file.path));
      }
      if (arguments.contains('.name')) {
        if (!arguments.contains('BrushKind')) {
          fail('${file.path} speaks a .name this test cannot expand: $arguments');
        }
        keys.addAll(BrushKind.values.map((b) => b == BrushKind.marker ? 'brush' : b.name));
      }
    }
  }
  return keys;
}

/// The text between a call's opening parenthesis, which ends at [start], and
/// the parenthesis that closes it.
String _arguments(String source, int start) {
  var depth = 1;
  for (var i = start; i < source.length; i++) {
    final c = source[i];
    if (c == '(') depth++;
    if (c == ')' && --depth == 0) return source.substring(start, i);
  }
  return source.substring(start);
}

Iterable<String> _expand(String literal, String path) {
  if (!literal.contains(r'$')) return [literal];
  if (literal.startsWith(r'color_$')) return List.generate(bigPalette.length, (i) => 'color_$i');
  if (literal.startsWith(r'category_$')) {
    return Category.getDefaultCategories().where((c) => !c.isImportCategory).map((c) => 'category_${c.id}');
  }
  fail('$path speaks "$literal", a pattern this test cannot expand; teach it the pattern');
}
