import Foundation
import FirebaseFirestore

enum ListingType: String, Codable, CaseIterable, Identifiable, Equatable {
    case fixedPrice = "fixed_price"
    case auction = "auction"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fixedPrice: return "Precio fijo"
        case .auction: return "Subasta"
        }
    }
}

enum ListingStatus: String, Codable, Equatable {
    case active
    case sold
    case ended
    case cancelled
}

struct Listing: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var sellerId: String
    var sellerName: String
    var title: String
    var description: String
    var category: String
    var imageURLs: [String]
    var type: ListingType
    var status: ListingStatus
    var askingPrice: Double
    var currentBid: Double?
    var bidCount: Int
    var minBidIncrement: Double
    var auctionEndsAt: Date?
    var createdAt: Date
    var location: String

    var displayPrice: Double {
        type == .auction ? (currentBid ?? askingPrice) : askingPrice
    }

    var isAuctionLive: Bool {
        guard type == .auction, status == .active, let endsAt = auctionEndsAt else { return false }
        return endsAt > Date()
    }
}
