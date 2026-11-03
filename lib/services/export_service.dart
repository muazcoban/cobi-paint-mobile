import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The grown-up exports Android's share sheet does not offer: saving a
/// picture to the gallery and printing it through the system print dialog.
/// Both live behind the parental gate. iOS has both in its share sheet, so
/// there is no channel there and every capability reads false.
class ExportService {
  ExportService({MethodChannel? channel}) : _channel = channel ?? const MethodChannel('cobi.paint/export');

  final MethodChannel _channel;

  /// What this device can do; false for everything where the platform side
  /// is missing (iOS, tests) or fails.
  Future<ExportCapabilities> capabilities() async {
    try {
      final map = await _channel.invokeMapMethod<String, Object?>('capabilities');
      return ExportCapabilities(gallery: map?['gallery'] == true, print: map?['print'] == true);
    } on MissingPluginException {
      return const ExportCapabilities();
    } on PlatformException catch (e) {
      debugPrint('Export capabilities failed: $e');
      return const ExportCapabilities();
    }
  }

  /// Saves [bytes], a PNG, as [name] in the Pictures/Cobi Paint album and
  /// returns the gallery URI. Throws when the platform refuses.
  Future<String> saveToGallery(Uint8List bytes, {required String name}) async =>
      (await _channel.invokeMethod<String>('saveToGallery', {'bytes': bytes, 'name': name}))!;

  /// Opens the system print dialog with [bytes], a PNG, fitted to one page.
  Future<void> printPicture(Uint8List bytes, {required String name}) =>
      _channel.invokeMethod<void>('print', {'bytes': bytes, 'name': name});
}

@immutable
class ExportCapabilities {
  const ExportCapabilities({this.gallery = false, this.print = false});

  final bool gallery;
  final bool print;
}
