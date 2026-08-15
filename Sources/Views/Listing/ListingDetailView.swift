import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    @EnvironmentObject var authService: AuthService
    @State private var showAuction = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TabView {
                    ForEach(listing.imageURLs, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Rectangle().fill(.quaternary)
                            }
                        }
                        .clipped()
                    }
                }
                .frame(height: 280)
                .tabViewStyle(.page)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(listing.title)
                            .font(.title2.bold())
                        Spacer()
                        if listing.isAuctionLive {
                            StatusBadge(text: "EN VIVO", color: .red)
                        }
                    }

                    Text(listing.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    PriceTag(
                        amount: listing.displayPrice,
                        label: listing.type == .auction ? "Oferta actual · \(listing.bidCount) ofertas" : nil
                    )
                    .font(.title3)

                    if listing.type == .auction, let endsAt = listing.auctionEndsAt {
                        CountdownTimerView(endsAt: endsAt)
                    }

                    Divider()

                    Text(listing.description)
                        .font(.body)

                    Divider()

                    Text("Vendido por \(listing.sellerName)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .glassCard(cornerRadius: 20)
                .padding(.horizontal)

                actionButton
                    .padding(.horizontal)
                    .padding(.bottom, 24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAuction) {
            LiveAuctionView(listing: listing)
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if listing.type == .auction {
            Button {
                showAuction = true
            } label: {
                Text(listing.isAuctionLive ? "Ver subasta en vivo y ofertar" : "Ver resultado de la subasta")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primaryGlass)
        } else {
            Button {
                // Contactar al vendedor — fuera del alcance del MVP.
            } label: {
                Text("Contactar al vendedor")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primaryGlass)
        }
    }
}
