import Foundation
import FirebaseFirestore
enum TransactionType: String, Codable {
    case income
    case expense
}

struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore doc ID
    var title: String
    var amount: Double
    var category: String
    var date: Date
    var type: TransactionType
}
