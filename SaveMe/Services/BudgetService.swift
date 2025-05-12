import FirebaseFirestore
import FirebaseAuth

class BudgetService: ObservableObject {
    private let db = Firestore.firestore()
    
    func addBudget(_ budget: Budget, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        do {
            _ = try db.collection("users")
                .document(uid)
                .collection("budgets")
                .addDocument(from: budget, completion: { error in
                    completion(error)
                })
        } catch {
            completion(error)
        }
    }
    
    func fetchBudgets(completion: @escaping ([Budget]?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        db.collection("users")
            .document(uid)
            .collection("budgets")
            .order(by: "createDate", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let budgets = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Budget.self)
                }
                completion(budgets, nil)
            }
    }
    
    func updateBudgetLimit(budgetId: String, newLimit: Double, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        db.collection("users")
            .document(uid)
            .collection("budgets")
            .document(budgetId)
            .updateData([
                "limit": newLimit
            ]) { error in
                completion(error)
            }
    }
    
    func fetchCategories(completion: @escaping ([String]?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        db.collection("users")
            .document(uid)
            .collection("budgets")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    let categories = snapshot?.documents.compactMap { doc in
                        doc.data()["category"] as? String
                    } ?? []
                    completion(categories, nil)
                }
            }
    }
    
    func deleteBudget(_ budget: Budget, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        guard let budgetId = budget.id else {
            completion(NSError(domain: "FirestoreError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Budget ID is nil"]))
            return
        }
        
        db.collection("users")
            .document(uid)
            .collection("budgets")
            .document(budgetId)
            .delete { error in
                if let error = error {
                    print("Error deleting budget: \(error.localizedDescription)")
                    completion(error)
                } else {
                    print("Budget deleted successfully")
                    completion(nil)
                }
            }
    }
}
