import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

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
    
    private func scheduleNotification(for billing: Billing) {
            let content = UNMutableNotificationContent()
            content.title = "Upcoming Billing Due"
            content.body = "\(billing.name) is due soon!"
            content.sound = .default

            // Trigger 1 day before the due date
            let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: billing.dueDate) ?? Date()
//            let triggerDate = Date().addingTimeInterval(10)
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: billing.id ?? UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled for billing \(billing.name)")
                }
            }
        }

        private func scheduleNotifications(for billings: [Billing]) {
            for billing in billings {
                scheduleNotification(for: billing)
            }
        }
}
