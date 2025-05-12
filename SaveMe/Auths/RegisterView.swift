import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var password = ""
    @State private var error = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account").font(.title)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !error.isEmpty {
                Text(error).foregroundColor(.red)
            }

            Button("Register") {
                Auth.auth().createUser(withEmail: email, password: password) { result, err in
                    if let err = err {
                        print("❌ Register error:", err.localizedDescription)
                        error = err.localizedDescription
                    } else {
                        // ✅ Auto login immediately after register
                        Auth.auth().signIn(withEmail: email, password: password) { _, _ in
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .padding()
    }
}
