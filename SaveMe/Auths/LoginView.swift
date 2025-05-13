import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var error = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Logo and Title
                VStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentColor)
                    
                    Text("Welcome to SaveMe")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Manage your finances effortlessly")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Login Fields
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    if !error.isEmpty {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: loginWithEmail) {
                        Text("Login")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Color.accentColor.opacity(0.4), radius: 4, x: 0, y: 2)
                    }

                    GoogleSignInButton(action: handleGoogleSignIn)
                        .frame(height: 50)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                // Register Link
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Register")
                        .foregroundColor(.accentColor)
                        .underline()
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: 500)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }

    // MARK: - Email/Password Login
    private func loginWithEmail() {
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if let err = err as NSError? {
                print("❌ Email login failed:", err.localizedDescription)
                
                switch AuthErrorCode(rawValue: err.code) {
                case .accountExistsWithDifferentCredential:
                    error = "This email is already registered using Google. Please sign in with Google."
                case .wrongPassword:
                    error = "Incorrect password. Please try again. Or try sign in with Google."
                case .userNotFound:
                    error = "No account found with this email. Please register first."
                case .userDisabled:
                    error = "Your account has been disabled. Contact support."
                case .invalidEmail:
                    error = "Please enter a valid email address."
                default:
                    error = err.localizedDescription
                }
            } else {
                print("✅ Email login success")
                authManager.loginSuccess()
            }
        }
    }

    // MARK: - Google Login
    private func handleGoogleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ No root view controller found")
            return
        }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ Missing Firebase client ID")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("❌ Google Sign-In failed:", error.localizedDescription)
                self.error = error.localizedDescription
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                print("❌ Missing Google ID token")
                self.error = "Google Sign-In failed"
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    print("❌ Firebase login with Google failed:", error.localizedDescription)
                    self.error = error.localizedDescription
                } else {
                    print("✅ Google login success")
                    authManager.loginSuccess()
                }
            }
        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//            .environmentObject(AuthManager())
//    }
//}
