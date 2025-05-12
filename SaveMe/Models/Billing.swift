import Foundation
import FirebaseFirestore

struct Billing: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var amount: Double
    var dueDate: Date
    var createDate: Date
}
