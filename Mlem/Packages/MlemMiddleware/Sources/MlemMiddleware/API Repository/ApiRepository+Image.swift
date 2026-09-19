//
//  ApiRepository+Image.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

import Foundation
import Rest
import UniformTypeIdentifiers

extension ApiRepository {
    func uploadImage(
        _ imageData: Data,
        fileType: UTType?,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1Snapshot {
        try await self.getConnection().uploadImage(imageData, fileType: fileType, onProgress: progressCallback)
    }
    
    func deleteImage(token: ImageDeleteToken) async throws {
        try await self.getConnection().deleteImage(token: token)
    }
}
