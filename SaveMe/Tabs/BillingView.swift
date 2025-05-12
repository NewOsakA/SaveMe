import SwiftUI

struct BillingView: View {
    @StateObject private var service = BillingService()
    @State private var billings: [Billing] = []
    @State private var showAddSheet = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            HStack {
                Text("Billing")
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
                if billings.isEmpty {
                    Text("No billings available.")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(billings) { billing in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(billing.name)
                                    .font(.headline)

                                Text("Due: \(formatDate(billing.dueDate))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(billing.amount, specifier: "%.2f")")
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)

                                Text(formatDate(billing.createDate))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteBilling(billing)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $showAddSheet) {
            AddBillingView(onSave: { newBilling in
                billings.insert(newBilling, at: 0)
            })
        }
        .onAppear {
            loadBillings()
        }
    }

    private func loadBillings() {
        service.fetchBillings { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                billings = result ?? []
            }
        }
    }

    private func saveBilling(_ billing: Billing) {
        service.addBilling(billing) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                loadBillings()
            }
        }
    }

    private func deleteBilling(_ billing: Billing) {
        service.deleteBilling(billing) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                billings.removeAll { $0.id == billing.id }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
