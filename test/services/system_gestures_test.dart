import 'package:cobi_paint_mobile/services/system_gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('cobi_paint/system_gestures');
  final calls = <Object?>[];

  setUp(() {
    calls.clear();
    SystemGestures.debugReset();
    SystemGestures.debugIsIOS = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.arguments);
      return null;
    });
  });

  tearDown(() {
    SystemGestures.debugIsIOS = null;
    SystemGestures.debugReset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('a screen that replaces another keeps the edges deferred', () async {
    // The scene opens, then its page replaces it: the page's initState
    // comes before the scene's dispose.
    await SystemGestures.deferEdgeGestures(true);
    await SystemGestures.deferEdgeGestures(true);
    await SystemGestures.deferEdgeGestures(false);
    expect(calls, [true], reason: 'the platform heard one request and no release');
    expect(SystemGestures.deferrals, 1);
    await SystemGestures.deferEdgeGestures(false);
    expect(calls, [true, false], reason: 'the last screen closing gives the edges back');
  });

  test('an extra release never goes below zero', () async {
    await SystemGestures.deferEdgeGestures(false);
    expect(calls, isEmpty);
    expect(SystemGestures.deferrals, 0);
    await SystemGestures.deferEdgeGestures(true);
    expect(calls, [true]);
  });

  test('nothing is sent off iOS', () async {
    SystemGestures.debugIsIOS = false;
    await SystemGestures.deferEdgeGestures(true);
    await SystemGestures.deferEdgeGestures(false);
    expect(calls, isEmpty);
  });
}
