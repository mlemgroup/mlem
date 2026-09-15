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
        guard let token else { throw ApiClientError.notLoggedIn }

        let request = LemmyUploadImageRequest(data: data, fileType: fileType)
        let response: LemmyPictrsUploadResponse

        do throws(RestError) {
            response = try await restClient.upload(baseUrl: baseUrl, request, token: token, onProgress: progressCallback)
        } catch {
            if case let .decoding(data, _) = error,
               String(decoding: data, as: UTF8.self).contains("413 Request Entity Too Large") {
                throw ApiClientError.imageTooLarge
            }
            throw ApiClientError(from: error)
        }

        guard let file = response.files?.first else {
            throw ApiClientError.responseMissingRequiredData(
                response.msg ?? "Unknown error: Missing \"files\" field in response"
            )
        }
        return .init(from: file, baseUrl: baseUrl)
    }
    
    func deleteImage(alias: String, deleteToken: String) async throws {
        let request = LemmyDeleteImageRequest(deleteToken: deleteToken, alias: alias)
        try await self.performWithoutEndpoint(request)
    }
}
