import SwiftUI

struct TransactionListView: View {
    @StateObject private var service = TransactionService()
    @State private var transactions: [Transaction] = []
    @State private var showAddSheet = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Transactions")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: {
                        showAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                List {
                    if transactions.isEmpty {
                        Text("No transactions available.")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(groupedTransactions(), id: \.key) { date, transactions in
                            VStack(alignment: .leading, spacing: 8) {
                                // Date Header with Conditional Income and Expense
                                HStack {
                                    Text(formatHeaderDate(date))
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Spacer()

                                    let totalIncome = calculateTotalIncome(for: transactions)
                                    let totalExpense = calculateTotalExpense(for: transactions)

                                    if totalIncome > 0 && totalExpense > 0 {
                                        HStack(spacing: 8) {
                                            Text("Income: \(totalIncome, specifier: "%.2f")")
                                                .font(.caption)
                                                .foregroundColor(.green)

                                            Text("Expense: \(totalExpense, specifier: "%.2f")")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                    } else if totalIncome > 0 {
                                        Text("Income: \(totalIncome, specifier: "%.2f")")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    } else if totalExpense > 0 {
                                        Text("Expense: \(totalExpense, specifier: "%.2f")")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(15)
                                .padding(.horizontal)
                                .padding(.top, 8)

                                // Transactions for this Date
                                ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                                    VStack {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(transaction.title)
                                                    .font(.headline)

                                                Text(transaction.category)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("\(transaction.amount, specifier: "%.2f")")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(transaction.type == .expense ? .red : .green)

                                                Text(formatDate(transaction.date))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding()
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)

                                        // Add divider between transactions
                                        if index < transactions.count - 1 {
                                            Divider()
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .onAppear {
                loadTransactions()
            }
            .sheet(isPresented: $showAddSheet) {
                AddTransactionView()
            }
        }
    }

    private func loadTransactions() {
        service.fetchTransactions { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                transactions = result ?? []
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func groupedTransactions() -> [(key: Date, value: [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    private func formatHeaderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    private func calculateTotalExpense(for transactions: [Transaction]) -> Double {
        return transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private func calculateTotalIncome(for transactions: [Transaction]) -> Double {
        return transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

}
