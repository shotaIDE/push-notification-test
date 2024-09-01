import Foundation
import FirebaseCore
import FirebaseMessaging
import SwiftUI
import CallKit
import PushKit

class ViewModel: NSObject, ObservableObject {
    let callModel = CallModel.shared
}

extension ViewModel: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupFirebase()
        setupUserNotification(application: application)
        setupPushKit()
        setupFirebaseMessaging()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // This method will not be called because Firebase intercepts the call via swizzle.
        // To make this method to be called, we need disable `FirebaseAppDelegateProxyEnabled`.
        let deviceToken = deviceToken.toHexString()
        print("[UserNotification] Registered with device token: \(deviceToken)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        // This method will not be called because Firebase intercepts the call via swizzle.
        // To make this method to be called, we need disable `FirebaseAppDelegateProxyEnabled`.
        print("[UserNotification] Failed to register: \(error)")
    }

    private func setupFirebase() {
        print("[Firebase] Setup")

        FirebaseApp.configure()
    }

    private func setupUserNotification(application: UIApplication) {
        print("[UserNotification] Setup")

        // Request push notification permission
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
    }

    private func setupPushKit() {
        print("[PushKit] Setup")

        let voipRegistry = PKPushRegistry(queue: nil)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }

    private func setupFirebaseMessaging() {
        Messaging.messaging().delegate = self
    }
}

extension ViewModel: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print("[PushKit] Push credentials has been updated")

        let deviceToken = pushCredentials.token.toHexString()

        print("[PushKit] Device token for VoIP: \(deviceToken)")
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("[PushKit] didInvalidatePushTokenFor")
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("[PushKit] didReceiveIncomingPushWith")

        let dictionary = payload.dictionaryPayload as NSDictionary
        let aps = dictionary["aps"] as! NSDictionary
        let title = aps["title"] as? String ?? "(No title)"

        callModel.IncomingCall(true, title: title)
    }
}

extension ViewModel: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmRegistrationToken = fcmToken else {
            return
        }
        print("[FCM] Registration token: \(fcmRegistrationToken)")

        guard let apnsDeviceTokenData = messaging.apnsToken else {
            return
        }
        let apnsDeviceToken = apnsDeviceTokenData.toHexString()
        print("[FCM] APNs token: \(apnsDeviceToken)")
    }
}
