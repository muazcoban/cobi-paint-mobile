import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Small children shake devices; that must not pop up the system Undo alert.
    application.applicationSupportsShakeToEdit = false
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
