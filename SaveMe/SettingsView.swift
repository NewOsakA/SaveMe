import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()
                }
                .padding(.horizontal)

                Form {
                    Section(header: Text("Account")) {
                        if let email = Auth.auth().currentUser?.email {
                            HStack {
                                Text("Logged in as")
                                Spacer()
                                Text(email)
                                    .foregroundColor(.gray)
                            }
                        }

                        Button(role: .destructive) {
                            authManager.logout()
                        } label: {
                            Text("Sign Out")
                        }
                    }
                }

                Spacer()
            }
            .padding(.top)
        }
    }
}
