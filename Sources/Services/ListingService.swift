import Foundation
import FirebaseFirestore

@MainActor
final class ListingService: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func startListening(filter: ListingType? = nil) {
        listener?.remove()
        isLoading = true

        var query: Query = db.collection("listings")
            .whereField("status", isEqualTo: ListingStatus.active.rawValue)
            .order(by: "createdAt", descending: true)

        if let filter {
            query = query.whereField("type", isEqualTo: filter.rawValue)
        }

        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            self.isLoading = false
            if let error {
                self.errorMessage = error.localizedDescription
                return
            }
            self.listings = snapshot?.documents.compactMap { try? $0.data(as: Listing.self) } ?? []
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func createListing(_ listing: Listing) async throws {
        _ = try db.collection("listings").addDocument(from: listing)
    }

    deinit {
        listener?.remove()
    }
}
