//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-05.
//

import Foundation
import Rest
import UniformTypeIdentifiers

public extension PieFedConnection {
    func uploadImage(
        _ data: Data,
        fileType: UTType?,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1Snapshot {
        guard let token else { throw ApiClientError.notLoggedIn }

        let request = PieFedUploadImageRequest(data: data, fileType: fileType)
        let response = try await restClient.upload(baseUrl: baseUrl, request, token: token, onProgress: progressCallback)
        return .init(from: response)
    }
    
    func deleteImage(alias: String, deleteToken: String) async throws {
        throw ApiClientError.featureUnsupported
    }
}
