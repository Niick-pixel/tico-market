import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var displayName: String
    var email: String
    var phoneNumber: String?
    var location: String?
    var rating: Double
    var ratingCount: Int
    var createdAt: Date
}
