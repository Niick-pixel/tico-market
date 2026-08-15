import Foundation
import FirebaseStorage
import UIKit

final class StorageService {
    private let storage = Storage.storage()

    func uploadListingImage(_ image: UIImage, listingId: String) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(
                domain: "StorageService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No se pudo procesar la imagen."]
            )
        }

        let fileName = UUID().uuidString + ".jpg"
        let ref = storage.reference().child("listings/\(listingId)/\(fileName)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
