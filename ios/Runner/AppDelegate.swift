import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1. Firebase configure
    FirebaseApp.configure()

    // 2. Push permission
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { granted, error in
        if granted {
          DispatchQueue.main.async {
            application.registerForRemoteNotifications()  // is needful
          }
        }
      }
    )
    // 3. Plugins register
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  // 4. APNs Token Firebase
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  // 5. Handle notification when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Let Flutter handle the notification via Firebase Messaging
    // The notification will be automatically forwarded to Flutter's onMessage listener
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
  
  // 6. Handle notification tap (when user taps on notification)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    
    // Forward to Flutter's onMessageOpenedApp handler
    // Firebase Messaging will handle this automatically if the notification came from FCM
    // For local notifications, we need to manually trigger the handler
    if let data = userInfo as? [String: Any] {
      // Check if this is an FCM notification (has gcm.message_id)
      if data["gcm.message_id"] != nil || data["google.c.a.e"] != nil {
        // FCM notification - will be handled automatically by Firebase Messaging
      } else {
        // Local notification - manually create RemoteMessage and forward
        // This will be handled by Flutter's notification tap handler
      }
    }
    
    completionHandler()
  }
}