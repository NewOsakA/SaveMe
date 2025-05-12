import SwiftUI
import FirebaseCore
import UserNotifications

@main
struct SaveMeApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var billingService = BillingService()

    init() {
        FirebaseApp.configure()
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authManager)
                .environmentObject(billingService)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
}
