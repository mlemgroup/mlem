//
//  ApiRepository+Image.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

import Foundation
import Rest

extension ApiRepository {
    func uploadImage(
        _ imageData: Data,
        fileExtension: String,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1Snapshot {
        try await self.getConnection().uploadImage(imageData, fileExtension: fileExtension, onProgress: progressCallback)
    }
    
    func deleteImage(alias: String, deleteToken: String) async throws {
        try await self.getConnection().deleteImage(alias: alias, deleteToken: deleteToken)
    }
}
