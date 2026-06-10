import Flutter
import UIKit
import Firebase
import FirebaseAuth

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    // Configure Auth for iOS - CRITICAL for Phone Auth
    configureAuthSettings()
    
    // IMMEDIATELY set fallback APNS token
    // This prevents nil unwrap crashes in Firebase Phone Auth on simulator
    self.setupAPNSFallback()
    
    // Register for remote notifications
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      UIApplication.shared.registerForRemoteNotifications()
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  /// Ensure APNS is set up with fallback for simulator
  private func setupAPNSFallback() {
    #if targetEnvironment(simulator)
      // On simulator, ALWAYS use empty token immediately
      NSLog("📱 [SIMULATOR] Setting empty APNS token NOW to prevent Phone Auth crashes")
      Auth.auth().setAPNSToken(Data(), type: .unknown)
      NSLog("✅ [SIMULATOR] Fallback APNS token set - Phone Auth will use reCAPTCHA")
    #else
      // On real device
      NSLog("📱 [DEVICE] Waiting for real APNS token registration...")
      
      // Set empty token as immediate fallback
      Auth.auth().setAPNSToken(Data(), type: .unknown)
      NSLog("✅ [DEVICE] Fallback APNS token set - will be replaced when real token arrives")
    #endif
  }
  
  /// Configure Firebase Authentication settings for iOS
  private func configureAuthSettings() {
    // CRITICAL: Disable app verification for testing/development
    // This forces Firebase to use reCAPTCHA instead of APNS verification
    // which prevents nil force-unwrap crashes on simulator
    Auth.auth().settings?.isAppVerificationDisabledForTesting = true
    
    // Set language code for verification messages
    Auth.auth().languageCode = Locale.current.languageCode ?? "en"
    
    NSLog("✅ Firebase Auth configured for iOS - App Verification DISABLED for reCAPTCHA flow")
  }
  
  // MARK: - Remote Notifications (APNS)
  
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    NSLog("✅ Real APNS token registered: \(token.prefix(20))...")
    Auth.auth().setAPNSToken(deviceToken, type: .prod)
  }
  
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("⚠️ Failed to register for remote notifications: %@", error.localizedDescription)
    
    // Fallback already set in setupAPNSFallback()
    NSLog("🔄 Fallback APNS token already set - using reCAPTCHA authentication")
  }
  
  // Handle incoming remote notifications
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // Check if this is an auth notification
    if Auth.auth().canHandleNotification(userInfo) {
      completionHandler(.noData)
      return
    }
    
    // Handle other push notifications if needed
    completionHandler(.newData)
  }
}
