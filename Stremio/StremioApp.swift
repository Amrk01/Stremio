import SwiftUI

@main
struct StremioApp: App {
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            if settings.isConfigured {
                MainTabView()
                    .environmentObject(settings)
            } else {
                SetupView()
                    .environmentObject(settings)
            }
        }
    }
}
