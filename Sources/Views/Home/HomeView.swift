import SwiftUI

struct HomeView: View {
    var previewMode: Bool = false

    @StateObject private var listingService = ListingService()
    @State private var selectedFilter: ListingType?

    private var displayListings: [Listing] {
        previewMode ? PreviewData.listings : listingService.listings
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                filterBar

                LazyVStack(spacing: 14) {
                    ForEach(displayListings) { listing in
                        if let id = listing.id {
                            NavigationLink(value: id) {
                                ListingRowView(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                if displayListings.isEmpty && !listingService.isLoading {
                    ContentUnavailableView(
                        "Todavía no hay publicaciones",
                        systemImage: "tray",
                        description: Text("Sé el primero en publicar algo en Tico Market.")
                    )
                    .padding(.top, 60)
                }
            }
            .navigationTitle("Tico Market")
            .navigationDestination(for: String.self) { listingId in
                if let listing = displayListings.first(where: { $0.id == listingId }) {
                    ListingDetailView(listing: listing)
                }
            }
            .onAppear {
                guard !previewMode else { return }
                listingService.startListening(filter: selectedFilter)
            }
            .onChange(of: selectedFilter) { _, newValue in
                guard !previewMode else { return }
                listingService.startListening(filter: newValue)
            }
            .onDisappear {
                guard !previewMode else { return }
                listingService.stopListening()
            }
            .refreshable {
                guard !previewMode else { return }
                listingService.startListening(filter: selectedFilter)
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(title: "Todos", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                filterChip(title: "Subastas", isSelected: selectedFilter == .auction) {
                    selectedFilter = .auction
                }
                filterChip(title: "Precio fijo", isSelected: selectedFilter == .fixedPrice) {
                    selectedFilter = .fixedPrice
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(isSelected ? Color.orange : Color.clear, in: Capsule())
                .glassCard(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }
}
