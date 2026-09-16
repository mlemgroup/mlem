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
    
    func deleteImage(token: ImageDeleteToken) async throws {
        guard let url = token.wrappedValue as? URL else {
            throw ApiClientError.invalidInput
        }
        let request = PieFedImageDeleteRequest(file: url.absoluteString)
        // The `result` field of the response is always "ok", so we don't need to decode it
        // https://codeberg.org/rimu/pyfedi/src/commit/dd2e9f9603be016f768b45ede0a71f1f0abd0cbd/app/api/alpha/utils/upload.py#L56
        try await perform(request)
    }
}
