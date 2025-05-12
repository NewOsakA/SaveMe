import SwiftUI

struct AddBudgetView: View {
    var budgetToEdit: Budget? = nil
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var budgetService = BudgetService()

    @State private var category = ""
    @State private var limit = ""
    @State private var errorMessage = ""

    init(budgetToEdit: Budget? = nil) {
        self.budgetToEdit = budgetToEdit
        if let budget = budgetToEdit {
            // Set initial values for editing
            _category = State(initialValue: budget.category)
            _limit = State(initialValue: String(format: "%.2f", budget.limit))
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text(budgetToEdit == nil ? "Add Budget" : "Edit Budget")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)

                Form {
                    TextField("Category", text: $category)
                        .disabled(budgetToEdit != nil) // Disable category editing

                    TextField("Limit", text: $limit)
                        .keyboardType(.decimalPad)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }

                    Button(budgetToEdit == nil ? "Add Budget" : "Save Changes") {
                        if let budget = budgetToEdit {
                            updateBudget(budget: budget)
                        } else {
                            addBudget()
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .padding(.top)
        }
    }

    private func addBudget() {
        guard let limitValue = Double(limit), !category.isEmpty else {
            errorMessage = "Please enter a valid category and limit."
            return
        }

        let newBudget = Budget(
            category: category,
            limit: limitValue,
            spent: 0,
            createDate: Date()
        )

        budgetService.addBudget(newBudget) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func updateBudget(budget: Budget) {
        guard let budgetId = budget.id, let limitValue = Double(limit) else {
            errorMessage = "Please enter a valid limit."
            return
        }

        budgetService.updateBudgetLimit(budgetId: budgetId, newLimit: limitValue) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
