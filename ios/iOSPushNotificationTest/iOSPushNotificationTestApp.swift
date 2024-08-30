import SwiftUI

@main
struct iOSPushNotificationTestApp: App {
    @UIApplicationDelegateAdaptor(ViewModel.self) var viewModel

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
