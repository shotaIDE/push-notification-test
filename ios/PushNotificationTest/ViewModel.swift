import Foundation
import FirebaseCore
import FirebaseMessaging
import SwiftUI
import CallKit
import PushKit

class ViewModel: NSObject, ObservableObject {
    let callModel = CallModel.shared
}

extension ViewModel: UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupFirebase()
        setupPushNotification()
        setupPushKit()
        setupFirebaseMessaging(application: application)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("[UserNotification] Received")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("[UserNotification] Failed to register: \(error)")
    }

    private func setupFirebase() {
        print("[Firebase] Setup")

        FirebaseApp.configure()
    }

    private func setupPushNotification() {
        print("[UserNotification] Setup")

        // This line is need for User Notification and FCM
        UIApplication.shared.registerForRemoteNotifications()
    }

    func setupPushKit() {
        print("[PushKit] Setup")

        let voipRegistry = PKPushRegistry(queue: nil)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }

    private func setupFirebaseMessaging(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        Messaging.messaging().delegate = self
    }
}

extension ViewModel: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print("[PushKit] Push credentials has been updated")

        let deviceToken = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()

        print("[PushKit] Device token for VoIP: \(deviceToken)")
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("[PushKit] didInvalidatePushTokenFor")
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("[PushKit] didReceiveIncomingPushWith")

        let dictionary = payload.dictionaryPayload as NSDictionary
        let aps = dictionary["aps"] as! NSDictionary
        let alert = aps["alert"]
        if let message = alert as? String {
            callModel.IncomingCall(true, displayText: "\(message)")
        } else {
            callModel.IncomingCall(true, displayText: "(none)")
        }
    }
}

extension ViewModel: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmRegistrationToken = fcmToken else {
            return
        }
        print("[FCM] Registration token: \(fcmRegistrationToken)")

        guard let apnsTokenData = messaging.apnsToken else {
            return
        }
        let apnsToken = apnsTokenData.map { String(format: "%02.2hhx", $0) }.joined()
        print("[FCM] APNs token: \(apnsToken)")
    }
}
