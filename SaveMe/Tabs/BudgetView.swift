import SwiftUI

struct BudgetView: View {
    @StateObject private var budgetService = BudgetService()
    @State private var budgets: [Budget] = []
    @State private var showEditSheet = false
    @State private var showAddSheet = false
    @State private var selectedBudget: Budget?
    @State private var updatedLimit = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Budgets")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)

                List(budgets) { budget in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(budget.category)
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Edit") {
                                selectedBudget = budget
                                updatedLimit = String(format: "%.2f", budget.limit)
                                showEditSheet = true
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Text("Limit: \(budget.limit, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text("Spent: \(budget.spent, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(budget.spent > budget.limit ? .red : .green)

                        ProgressView(value: budget.limit > 0 ? min(max(budget.spent / budget.limit, 0), 1) : 0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.vertical, 4)
                            .accentColor(budget.spent > budget.limit ? .red : .blue)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
            .onAppear {
                loadBudgets()
            }
            .sheet(isPresented: $showAddSheet) {
                AddBudgetView()
            }
            .sheet(isPresented: $showEditSheet) {
                if let selectedBudget = selectedBudget {
                    AddBudgetView(budgetToEdit: selectedBudget)
                }
            }
        }
    }

    private func loadBudgets() {
        budgetService.fetchBudgets { result, error in
            if let result = result {
                budgets = result
            }
        }
    }
}
