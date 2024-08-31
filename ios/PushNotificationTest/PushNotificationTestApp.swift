import SwiftUI

@main
struct PushNotificationTestApp: App {
    @UIApplicationDelegateAdaptor(ViewModel.self) var viewModel

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
