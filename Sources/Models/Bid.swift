import Foundation
import FirebaseFirestore

struct Bid: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var listingId: String
    var bidderId: String
    var bidderName: String
    var amount: Double
    var placedAt: Date
}
