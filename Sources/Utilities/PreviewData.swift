import Foundation

/// Sample data for SwiftUI previews and for the UI_PREVIEW_MODE screenshot
/// pass in CI, where there's no real Firebase project to sign in against.
enum PreviewData {
    static let listings: [Listing] = [
        Listing(
            id: "sample-1",
            sellerId: "seller-1",
            sellerName: "María Fernández",
            title: "iPhone 13 Pro, 256GB",
            description: "En excelente estado, poco uso. Incluye cargador y caja original.",
            category: "Electrónica",
            imageURLs: [],
            type: .fixedPrice,
            status: .active,
            askingPrice: 350000,
            currentBid: nil,
            bidCount: 0,
            minBidIncrement: 5000,
            auctionEndsAt: nil,
            createdAt: Date().addingTimeInterval(-3600),
            location: "San José"
        ),
        Listing(
            id: "sample-2",
            sellerId: "seller-2",
            sellerName: "Carlos Rojas",
            title: "Bicicleta de montaña Trek",
            description: "Rodado 29, frenos de disco hidráulicos. Ideal para trail.",
            category: "Deportes",
            imageURLs: [],
            type: .auction,
            status: .active,
            askingPrice: 150000,
            currentBid: 187000,
            bidCount: 6,
            minBidIncrement: 5000,
            auctionEndsAt: Date().addingTimeInterval(3600 * 4),
            createdAt: Date().addingTimeInterval(-7200),
            location: "Heredia"
        ),
        Listing(
            id: "sample-3",
            sellerId: "seller-3",
            sellerName: "Ana Jiménez",
            title: "Sofá modular 4 piezas",
            description: "Tela gris, muy cómodo. Se vende por mudanza.",
            category: "Hogar",
            imageURLs: [],
            type: .fixedPrice,
            status: .active,
            askingPrice: 220000,
            currentBid: nil,
            bidCount: 0,
            minBidIncrement: 5000,
            auctionEndsAt: nil,
            createdAt: Date().addingTimeInterval(-1800),
            location: "Alajuela"
        )
    ]

    static let profile = UserProfile(
        id: "preview-user",
        displayName: "Usuario de prueba",
        email: "preview@ticomarket.app",
        phoneNumber: nil,
        location: "San José",
        rating: 4.8,
        ratingCount: 12,
        createdAt: Date()
    )
}
