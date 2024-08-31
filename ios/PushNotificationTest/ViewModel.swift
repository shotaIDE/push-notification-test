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
        let deviceToken = deviceToken.toHexString()
        print("[UserNotification] Registered with device token: \(deviceToken)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("[UserNotification] Failed to register: \(error)")
    }

    private func setupFirebase() {
        print("[Firebase] Setup")

        FirebaseApp.configure()
    }

    private func setupUserNotification(application: UIApplication) {
        print("[UserNotification] Setup")

        // This line is need for User Notification and FCM
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

        guard let apnsDeviceTokenData = messaging.apnsToken else {
            return
        }
        let apnsDeviceToken = apnsDeviceTokenData.toHexString()
        print("[FCM] APNs token: \(apnsDeviceToken)")
    }
}
