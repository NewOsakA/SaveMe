import SwiftUI
import FirebaseCore

@main
struct SaveMeApp: App {
    @StateObject private var authManager = AuthManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authManager)
        }
    }
}
