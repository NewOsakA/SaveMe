import SwiftUI
import FirebaseAuth

struct AddTransactionView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject var service = TransactionService()
    @StateObject var budgetService = BudgetService()

    @State private var title = ""
    @State private var amount = ""
    @State private var category = ""
    @State private var type: TransactionType = .expense
    @State private var date = Date()
    @State private var errorMessage = ""
    @State private var categories: [String] = []
    @State private var filteredCategories: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Add Transaction")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)

                Text("Add your transaction here.")
                    .padding(.horizontal)

                Form {
                    TextField("Title", text: $title)

                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    VStack(alignment: .leading) {
                        TextField("Category", text: $category, onEditingChanged: { isEditing in
                            if isEditing {
                                filterCategories()
                            }
                        })
                        .onChange(of: category) { _ in
                            filterCategories()
                        }

                        if !filteredCategories.isEmpty {
                            List(filteredCategories, id: \.self) { cat in
                                Text(cat)
                                    .onTapGesture {
                                        category = cat
                                        filteredCategories = []
                                    }
                            }
                            .frame(maxHeight: 150)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        }
                    }

                    Picker("Type", selection: $type) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }

                    Button("Save Transaction") {
                        saveTransaction()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .padding(.top)
            .onAppear {
                loadCategories()
            }
        }
    }

    private func loadCategories() {
        budgetService.fetchCategories { result, error in
            if let result = result {
                categories = result
            }
        }
    }

    private func filterCategories() {
        filteredCategories = categories.filter { $0.lowercased().contains(category.lowercased()) }
    }

    private func saveTransaction() {
        let newTransaction = Transaction(
            title: title,
            amount: Double(amount) ?? 0,
            category: category,
            date: date,
            type: type
        )

        service.addTransaction(newTransaction) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

