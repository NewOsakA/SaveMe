import SwiftUI
import FirebaseAuth

struct UserToolbarMenu: View {
    var onLogout: () -> Void

    var body: some View {
        Menu {
            if let email = Auth.auth().currentUser?.email {
                Text(email)
            }
            Button("Log Out", role: .destructive, action: onLogout)
        } label: {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 28, height: 28)
        }
    }
}
