import SwiftUI

struct LiveAuctionView: View {
    let listing: Listing
    @EnvironmentObject var authService: AuthService
    @StateObject private var bidService = BidService()
    @Environment(\.dismiss) private var dismiss

    @State private var bidAmountText = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    private var minimumBid: Double {
        (listing.currentBid ?? listing.askingPrice) + listing.minBidIncrement
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let endsAt = listing.auctionEndsAt {
                    CountdownTimerView(endsAt: endsAt)
                        .padding(.top, 8)
                }

                VStack(spacing: 4) {
                    Text("Oferta más alta")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.format(listing.currentBid ?? listing.askingPrice))
                        .font(.largeTitle.bold())
                }
                .padding()
                .glassCard(cornerRadius: 20)
                .padding(.horizontal)

                List(bidService.bids) { bid in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(bid.bidderName).font(.subheadline.weight(.medium))
                            Text(RelativeDateFormatter.string(from: bid.placedAt))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(CurrencyFormatter.format(bid.amount))
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .listStyle(.plain)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                if listing.isAuctionLive {
                    HStack(spacing: 10) {
                        TextField("Mínimo \(CurrencyFormatter.format(minimumBid))", text: $bidAmountText)
                            .keyboardType(.numberPad)
                            .padding()
                            .glassCard(cornerRadius: 14)

                        Button {
                            Task { await placeBid() }
                        } label: {
                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text("Ofertar")
                            }
                        }
                        .buttonStyle(.primaryGlass)
                        .disabled(isSubmitting)
                    }
                    .padding()
                }
            }
            .navigationTitle(listing.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .onAppear {
                bidService.startListening(listingId: listing.id ?? "")
                bidAmountText = String(format: "%.0f", minimumBid)
            }
            .onDisappear { bidService.stopListening() }
        }
    }

    private func placeBid() async {
        errorMessage = nil
        guard let listingId = listing.id,
              let user = authService.currentUser,
              let amount = Double(bidAmountText) else {
            errorMessage = "Ingresá un monto válido."
            return
        }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await bidService.placeBid(
                listingId: listingId,
                bidderId: user.uid,
                bidderName: authService.userProfile?.displayName ?? "Usuario",
                amount: amount
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
