import UIKit
import Flutter
import GoogleSignIn
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GIDSignIn.sharedInstance().clientID = "703446656477-jvird8eo197s7oqo6ethomqoadg9l1ha.apps.googleusercontent.com"
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
