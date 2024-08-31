import Foundation
import SwiftUI
import CallKit
import PushKit

class ViewModel: NSObject, ObservableObject {
    let callModel = CallModel.shared
}

extension ViewModel: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupPushKit()
        return true
    }

    func setupPushKit() {
        print("[PushKit] Setup")

        let voipRegistry = PKPushRegistry(queue: nil)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
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
