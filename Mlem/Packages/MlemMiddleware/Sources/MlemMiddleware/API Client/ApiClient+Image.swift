//
//  ApiClient+Image.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation
import Rest

public extension ApiClient {
    func uploadImage(
        _ imageData: Data,
        fileExtension: String,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1 {
        let file = try await repository.uploadImage(imageData, fileExtension: fileExtension, onProgress: progressCallback)
        return caches.imageUpload1.getModel(api: self, from: file)
    }
    
    func deleteImage(alias: String, deleteToken: String) async throws {
        try await repository.deleteImage(alias: alias, deleteToken: deleteToken)
    }
}
