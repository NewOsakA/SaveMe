import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var service = TransactionService()
    @State private var transactions: [Transaction] = []
    @State private var totalIncome: Double = 0
    @State private var totalExpenses: Double = 0
    @State private var balance: Double = 0
    @State private var expenseBreakdown: [String: Double] = [:]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Dashboard Title
                HStack {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)

                ScrollView {
                    VStack(spacing: 20) {
                        // Total Balance
                        VStack {
                            Text("Total Balance")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text("\(balance, specifier: "%.2f")")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(balance >= 0 ? .green : .red)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                        .padding(.horizontal)

                        // Income & Expense Summary
                        HStack(spacing: 20) {
                            VStack {
                                Text("Income")
                                    .font(.headline)
                                    .foregroundColor(.green)

                                Text("\(totalIncome, specifier: "%.2f")")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }

                            VStack {
                                Text("Expenses")
                                    .font(.headline)
                                    .foregroundColor(.red)

                                Text("\(totalExpenses, specifier: "%.2f")")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                        .padding(.horizontal)

                        // Expense Breakdown Chart
                        VStack(alignment: .leading) {
                            Text("Expense Breakdown")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart {
                                ForEach(expenseBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                                    let categoryName = category.isEmpty ? "etc." : category
                                    let percentage = (amount / totalExpenses) * 100

                                    SectorMark(
                                        angle: .value("Amount", amount),
                                        innerRadius: .ratio(0.4),
                                        outerRadius: .ratio(1.0)
                                    )
                                    .foregroundStyle(by: .value("Category", categoryName))
                                    .annotation(position: .overlay) {
                                        Text("\(categoryName) \(percentage, specifier: "%.1f")%")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .frame(width: 70)
                                            .multilineTextAlignment(.center)
//                                            .offset(y: -10)
                                    }
                                }
                            }
                            .frame(height: 300)
                            .padding(.horizontal)
                        }
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                        .padding(.horizontal)

                        // Recent Transactions
                        VStack(alignment: .leading) {
                            Text("Recent Transactions")
                                .font(.headline)
                                .padding(.horizontal)

                            if transactions.isEmpty {
                                Text("No recent transactions")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                ForEach(transactions.prefix(5)) { transaction in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(transaction.title)
                                                .font(.headline)

                                            Text(transaction.category.isEmpty ? "etc." : transaction.category)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        Text("\(transaction.amount, specifier: "%.2f")")
                                            .fontWeight(.bold)
                                            .foregroundColor(transaction.type == .expense ? .red : .green)
                                    }
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .onAppear {
                loadTransactions()
            }
        }
    }

    private func loadTransactions() {
        service.fetchTransactions { result, error in
            if let transactions = result {
                self.transactions = transactions
                self.totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
                self.totalExpenses = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
                self.balance = totalIncome - totalExpenses

                // Calculate expense breakdown with "etc." for empty categories
                self.expenseBreakdown = transactions.filter { $0.type == .expense }.reduce(into: [:]) { result, transaction in
                    let categoryName = transaction.category.isEmpty ? "etc." : transaction.category
                    result[categoryName, default: 0] += transaction.amount
                }
            }
        }
    }
}
