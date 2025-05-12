import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil

    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }

    func loginSuccess() {
        isLoggedIn = true
    }
}
