//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-05.
//

import Foundation
import Rest
import UniformTypeIdentifiers

public extension LemmyConnection {
    func uploadImage(
        _ data: Data,
        fileType: UTType?,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1Snapshot {
        try await self.uploadImageV3(data, fileType: fileType, onProgress: progressCallback)
    }

    private func uploadImageV3(
        _ data: Data,
        fileType: UTType?,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1Snapshot {
        let request = LemmyV3UploadImageRequest(data: data, fileType: fileType)
        let response = try await self.upload(request, onProgress: progressCallback)

        guard let file = response.files?.first else {
            throw ApiClientError.responseMissingRequiredData(
                response.msg ?? "Unknown error: Missing \"files\" field in response"
            )
        }
        return .init(from: file, baseUrl: baseUrl)
    }
    
    func deleteImage(token: ImageDeleteToken) async throws {
        guard let token = token.wrappedValue as? LemmyImageDeleteToken else {
            throw ApiClientError.invalidInput
        }

        let request = LemmyDeleteImageRequest(deleteToken: token.token, alias: token.alias)
        try await self.performWithoutEndpoint(request)
    }
}
