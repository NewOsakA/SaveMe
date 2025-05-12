import Foundation
import FirebaseFirestore

struct Budget: Identifiable, Codable {
    @DocumentID var id: String?
    var category: String
    var limit: Double
    var spent: Double
    var createDate: Date
}
