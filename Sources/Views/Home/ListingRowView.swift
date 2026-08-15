import SwiftUI

struct ListingRowView: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: listing.imageURLs.first ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle().fill(.quaternary)
                }
            }
            .frame(width: 84, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(listing.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    if listing.isAuctionLive {
                        StatusBadge(text: "EN VIVO", color: .red)
                    }
                }

                Text(listing.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    PriceTag(
                        amount: listing.displayPrice,
                        label: listing.type == .auction ? "Oferta actual" : nil
                    )
                    Spacer()
                    if listing.type == .auction, let endsAt = listing.auctionEndsAt {
                        CountdownChip(endsAt: endsAt)
                    }
                }
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 18)
    }
}
