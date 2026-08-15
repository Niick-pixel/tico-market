import SwiftUI
import PhotosUI

struct CreateListingView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var listingService = ListingService()
    private let storageService = StorageService()

    @State private var title = ""
    @State private var description = ""
    @State private var category = "General"
    @State private var type: ListingType = .fixedPrice
    @State private var priceText = ""
    @State private var minIncrementText = "1000"
    @State private var durationHours = 24.0
    @State private var location = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var didPublish = false

    private let categories = ["General", "Electrónica", "Hogar", "Vehículos", "Ropa", "Deportes", "Otros"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles") {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Categoría", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    TextField("Ubicación (ej. San José)", text: $location)
                }

                Section("Tipo de publicación") {
                    Picker("Tipo", selection: $type) {
                        ForEach(ListingType.allCases) { t in
                            Text(t.label).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField(type == .auction ? "Precio inicial (₡)" : "Precio (₡)", text: $priceText)
                        .keyboardType(.numberPad)

                    if type == .auction {
                        TextField("Incremento mínimo por oferta (₡)", text: $minIncrementText)
                            .keyboardType(.numberPad)

                        VStack(alignment: .leading) {
                            Text("Duración: \(Int(durationHours)) horas")
                            Slider(value: $durationHours, in: 1...168, step: 1)
                        }
                    }
                }

                Section("Fotos") {
                    PhotosPicker("Elegir fotos", selection: $selectedItems, maxSelectionCount: 5, matching: .images)
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }

                Section {
                    Button {
                        Task { await publish() }
                    } label: {
                        if isSubmitting {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Publicar").frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.primaryGlass)
                    .disabled(!isValid || isSubmitting)
                }
            }
            .navigationTitle("Publicar")
            .onChange(of: selectedItems) { _, items in
                Task { await loadImages(items) }
            }
            .alert("¡Publicado!", isPresented: $didPublish) {
                Button("Listo") { resetForm() }
            } message: {
                Text("Tu publicación ya está disponible en Tico Market.")
            }
        }
    }

    private var isValid: Bool {
        !title.isEmpty && !description.isEmpty && !location.isEmpty && Double(priceText) != nil
    }

    private func loadImages(_ items: [PhotosPickerItem]) async {
        var images: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                images.append(image)
            }
        }
        selectedImages = images
    }

    private func publish() async {
        guard let user = authService.currentUser, let price = Double(priceText) else { return }
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let listingId = UUID().uuidString
            var imageURLs: [String] = []
            for image in selectedImages {
                let url = try await storageService.uploadListingImage(image, listingId: listingId)
                imageURLs.append(url)
            }

            let listing = Listing(
                sellerId: user.uid,
                sellerName: authService.userProfile?.displayName ?? "Usuario",
                title: title,
                description: description,
                category: category,
                imageURLs: imageURLs,
                type: type,
                status: .active,
                askingPrice: price,
                currentBid: type == .auction ? price : nil,
                bidCount: 0,
                minBidIncrement: Double(minIncrementText) ?? 1000,
                auctionEndsAt: type == .auction ? Date().addingTimeInterval(durationHours * 3600) : nil,
                createdAt: Date(),
                location: location
            )

            try await listingService.createListing(listing)
            didPublish = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetForm() {
        title = ""
        description = ""
        priceText = ""
        location = ""
        selectedItems = []
        selectedImages = []
        type = .fixedPrice
        minIncrementText = "1000"
        durationHours = 24
    }
}
