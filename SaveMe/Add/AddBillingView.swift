import SwiftUI
import FirebaseAuth

struct AddBillingView: View {
    var onSave: (Billing) -> Void
    @Environment(\.presentationMode) var presentationMode
    @StateObject var service = BillingService()

    @State private var name = ""
    @State private var amount = ""
    @State private var dueDate = Date()
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Add Billing")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                .padding(.top, 16)

                Text("Set your billing information here.")
                    .padding(.horizontal)

                Form {
                    TextField("Name", text: $name)

                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }

                    Button("Save Billing") {
                        saveBilling()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.vertical)
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }

    private func saveBilling() {
        guard !name.isEmpty, !amount.isEmpty else {
            errorMessage = "Name and Amount are required."
            return
        }

        guard let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        // Generate the ID here
        let newBilling = Billing(
            id: UUID().uuidString,
            name: name,
            amount: amountValue,
            dueDate: dueDate,
            createDate: Date()
        )

        service.addBilling(newBilling) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                onSave(newBilling) // Immediately reflect the change in the local list
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
