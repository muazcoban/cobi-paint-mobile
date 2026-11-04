import Flutter
import UIKit

/// UIScene life cycle (Info.plist, UIApplicationSceneManifest with
/// FlutterSceneDelegate): required by Apple for apps built with the iOS 27
/// SDK, supported since Flutter 3.38. Plugins register once the implicit
/// engine exists, not in didFinishLaunching.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Small children shake devices; that must not pop up the system Undo alert.
    application.applicationSupportsShakeToEdit = false
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

/// Root view controller (Main.storyboard). While the child colours, iOS
/// defers the system edge gestures: the first swipe from the top or bottom
/// edge only shows the indicator, a second one opens the system UI. HIG,
/// "Going full screen"; Flutter does not offer this itself.
class KidFlutterViewController: FlutterViewController {
  private var defersEdgeGestures = false

  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    defersEdgeGestures ? [.top, .bottom] : []
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let channel = FlutterMethodChannel(name: "cobi_paint/system_gestures", binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "deferEdgeGestures", let shouldDefer = call.arguments as? Bool else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.defersEdgeGestures = shouldDefer
      self?.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
      result(nil)
    }
  }
}
