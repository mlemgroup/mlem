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
        if try await self.version > .init("1.0.0") {
            try await self.uploadImageV4(data, fileType: fileType, onProgress: progressCallback)
        } else {
            try await self.uploadImageV3(data, fileType: fileType, onProgress: progressCallback)
        }
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

    private func uploadImageV4(
        _ data: Data,
        fileType: UTType?,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1Snapshot {
        let request = LemmyV4UploadImageRequest(data: data, fileType: fileType)
        let response = try await self.upload(request, onProgress: progressCallback)

        return .init(from: response)
    }
    
    func deleteImage(token: ImageDeleteToken) async throws {
        if let token = token.wrappedValue as? LemmyV3ImageDeleteToken {
            let request = LemmyV3DeleteImageRequest(deleteToken: token.token, alias: token.alias)
            try await self.performWithoutEndpoint(request)
        } else {
            throw ApiClientError.invalidInput
        }
    }
}
