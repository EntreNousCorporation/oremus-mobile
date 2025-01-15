import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window.rootViewController as! FlutterViewController

    let flavorChannel = FlutterMethodChannel(
        name: "flavor",
        binaryMessenger: controller.binaryMessenger)

    flavorChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        // Note: this method is invoked on the UI thread
        let flavor = Bundle.main.infoDictionary?["Oremus - Flavor"]
        result(flavor)
    })
    GMSServices.provideAPIKey("AIzaSyCTR_9q5d6380xtzxM__KL5Ph96gqvQucg")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
