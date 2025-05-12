import FirebaseFirestore
import FirebaseAuth

class TransactionService: ObservableObject {
    private let db = Firestore.firestore()

    func addTransaction(_ transaction: Transaction, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        do {
            // Add the transaction
            _ = try db.collection("users")
                .document(uid)
                .collection("transactions")
                .addDocument(from: transaction, completion: { error in
                    if let error = error {
                        completion(error)
                    } else {
                        // Update the associated budget
                        if transaction.type == .expense {
                            self.updateBudgetSpent(category: transaction.category, amount: transaction.amount)
                        }
                        completion(nil)
                    }
                })
        } catch {
            completion(error)
        }
    }
    
    func fetchTransactions(completion: @escaping ([Transaction]?, Error?) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
                return
            }

            db.collection("users")
                .document(uid)
                .collection("transactions")
                .order(by: "date", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }

                    let transactions = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Transaction.self)
                    }
                    completion(transactions, nil)
                }
        }

    private func updateBudgetSpent(category: String, amount: Double) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let budgetRef = db.collection("users")
            .document(uid)
            .collection("budgets")
            .whereField("category", isEqualTo: category)

        budgetRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching budgets: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No matching budget found for category: \(category)")
                return
            }

            // Assume there is only one budget per category
            if let document = documents.first {
                let budgetId = document.documentID
                let currentSpent = document.data()["spent"] as? Double ?? 0
                let newSpent = currentSpent + amount

                self.db.collection("users")
                    .document(uid)
                    .collection("budgets")
                    .document(budgetId)
                    .updateData(["spent": newSpent]) { error in
                        if let error = error {
                            print("Error updating budget: \(error.localizedDescription)")
                        } else {
                            print("Budget updated successfully for category: \(category)")
                        }
                    }
            }
        }
    }

}
