import Foundation
import FirebaseFirestore

enum BidError: LocalizedError {
    case auctionEnded
    case bidTooLow(minimum: Double)
    case listingNotFound

    var errorDescription: String? {
        switch self {
        case .auctionEnded:
            return "Esta subasta ya terminó."
        case .bidTooLow(let minimum):
            return "Tu oferta debe ser de al menos \(CurrencyFormatter.format(minimum))."
        case .listingNotFound:
            return "No se encontró la publicación."
        }
    }
}

@MainActor
final class BidService: ObservableObject {
    @Published var bids: [Bid] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func startListening(listingId: String) {
        listener?.remove()
        listener = db.collection("bids")
            .whereField("listingId", isEqualTo: listingId)
            .order(by: "placedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                self?.bids = snapshot?.documents.compactMap { try? $0.data(as: Bid.self) } ?? []
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    /// Places a bid atomically: re-reads the listing inside a Firestore transaction so two
    /// simultaneous bidders can't both "win" against a stale local price.
    func placeBid(listingId: String, bidderId: String, bidderName: String, amount: Double) async throws {
        let listingRef = db.collection("listings").document(listingId)
        let bidRef = db.collection("bids").document()

        _ = try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let listingSnapshot: DocumentSnapshot
            do {
                listingSnapshot = try transaction.getDocument(listingRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard let listing = try? listingSnapshot.data(as: Listing.self) else {
                errorPointer?.pointee = BidError.listingNotFound as NSError
                return nil
            }

            if let endsAt = listing.auctionEndsAt, endsAt <= Date() {
                errorPointer?.pointee = BidError.auctionEnded as NSError
                return nil
            }

            let minimumBid = (listing.currentBid ?? listing.askingPrice) + listing.minBidIncrement
            if amount < minimumBid {
                errorPointer?.pointee = BidError.bidTooLow(minimum: minimumBid) as NSError
                return nil
            }

            transaction.setData([
                "listingId": listingId,
                "bidderId": bidderId,
                "bidderName": bidderName,
                "amount": amount,
                "placedAt": Timestamp(date: Date())
            ], forDocument: bidRef)

            transaction.updateData([
                "currentBid": amount,
                "bidCount": listing.bidCount + 1
            ], forDocument: listingRef)

            return nil
        }
    }

    deinit {
        listener?.remove()
    }
}
