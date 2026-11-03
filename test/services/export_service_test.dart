import 'package:cobi_paint_mobile/services/export_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Android export channel as the Dart side sees it: the platform code
/// itself is checked on the emulator.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('cobi.paint/export');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('without the platform side (iOS, tests) nothing is offered and nothing throws', () async {
    final caps = await ExportService().capabilities();
    expect(caps.gallery, isFalse);
    expect(caps.print, isFalse);
  });

  test('the Android side answers the capabilities, saves and prints with the bytes and the name', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'capabilities' => {'gallery': true, 'print': true},
        'saveToGallery' => 'content://media/external/images/media/42',
        'print' => null,
        _ => throw MissingPluginException(),
      };
    });
    final service = ExportService();
    final caps = await service.capabilities();
    expect(caps.gallery, isTrue);
    expect(caps.print, isTrue);

    final bytes = Uint8List.fromList([137, 80, 78, 71]);
    expect(await service.saveToGallery(bytes, name: 'cobi_paint_1'), 'content://media/external/images/media/42');
    await service.printPicture(bytes, name: 'Kedi');
    expect(calls.map((c) => c.method), ['capabilities', 'saveToGallery', 'print']);
    expect(calls[1].arguments, {'bytes': bytes, 'name': 'cobi_paint_1'});
    expect(calls[2].arguments, {'bytes': bytes, 'name': 'Kedi'});
  });

  test('a platform error is false for the capabilities and an exception for a save', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => throw PlatformException(code: 'save', message: 'full'));
    final caps = await ExportService().capabilities();
    expect(caps.gallery, isFalse);
    expect(() => ExportService().saveToGallery(Uint8List(0), name: 'x'), throwsA(isA<PlatformException>()));
  });
}
