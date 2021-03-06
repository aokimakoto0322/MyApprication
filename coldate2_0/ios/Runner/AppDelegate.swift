import UIKit
import Flutter
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure() 
    if #available(iOS 14, *) {
          ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
              GADMobileAds.sharedInstance().start(completionHandler: nil)
          })
        } else {
            // Fallback on earlier versions
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
