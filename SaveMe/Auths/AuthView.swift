import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        if authManager.isLoggedIn {
            MainView()
        } else {
            LoginView()
        }
    }
}
