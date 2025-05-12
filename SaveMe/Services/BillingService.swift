import Foundation
import FirebaseFirestore
import FirebaseAuth

class BillingService: ObservableObject {
    private let db = Firestore.firestore()

    func fetchBillings(completion: @escaping ([Billing]?, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "BillingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        db.collection("users")
            .document(userId)
            .collection("billings")
            .order(by: "createDate", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }

                do {
                    let billings = try snapshot?.documents.compactMap {
                        try $0.data(as: Billing.self)
                    } ?? []
                    completion(billings, nil)
                } catch {
                    completion(nil, error)
                }
            }
    }

    func addBilling(_ billing: Billing, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "BillingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        do {
            try db.collection("users")
                .document(userId)
                .collection("billings")
                .document(billing.id ?? UUID().uuidString)
                .setData(from: billing)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func deleteBilling(_ billing: Billing, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "BillingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        guard let id = billing.id else {
            completion(NSError(domain: "BillingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Billing ID is missing"]))
            return
        }

        db.collection("users")
            .document(userId)
            .collection("billings")
            .document(id)
            .delete { error in
                completion(error)
            }
    }
}
