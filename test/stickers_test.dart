import 'package:cobi_paint_mobile/data/stickers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('there are 12 to 16 stickers, each with a name in both languages', () {
    expect(stickers.length, inInclusiveRange(12, 16));
    expect(stickers.map((s) => s.code).toSet(), hasLength(stickers.length), reason: 'codes are unique');
    for (final s in stickers) {
      expect(s.nameTr, isNotEmpty, reason: s.code);
      expect(s.nameEn, isNotEmpty, reason: s.code);
      expect(s.localizedName('tr'), s.nameTr);
      expect(s.localizedName('de'), s.nameEn, reason: 'other languages fall back to English');
    }
  });

  test('every sticker picture exists and decodes at 256 px', () async {
    for (final s in stickers) {
      final data = await rootBundle.load(s.assetPath);
      final image = await decodeImageFromList(data.buffer.asUint8List());
      expect(image.width, 256, reason: s.code);
      expect(image.height, 256, reason: s.code);
      image.dispose();
    }
  });
}
