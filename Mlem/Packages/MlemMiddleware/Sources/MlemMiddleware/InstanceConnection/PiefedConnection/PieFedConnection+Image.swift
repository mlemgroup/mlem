//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-05.
//

import Foundation
import Rest

public extension PieFedConnection {
    func uploadImage(
        _ imageData: Data,
        fileExtension: String,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1Snapshot {
        guard let token else { throw ApiClientError.notLoggedIn }
        var request = mlemUrlRequest(url: baseUrl.appending(path: "api/alpha/upload/image"))
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encodedData = createMultiPartForm(
            boundary: boundary,
            contentType: "application/octet-stream",
            name: "file",
            fileName: "image.\(fileExtension)",
            imageData: imageData,
            auth: token
        )
        
        let (data, _) = try await restClient.urlSession.upload(
            for: request,
            from: encodedData,
            delegate: ImageUploadDelegate(callback: progressCallback)
        )
        
        do {
            let response = try JSONDecoder.defaultDecoder.decode(PieFedImageUploadResponse.self, from: data)
            return .init(from: response)
        } catch DecodingError.dataCorrupted {
            let text = String(decoding: data, as: UTF8.self)
            if text.contains("413 Request Entity Too Large") {
                throw ApiClientError.imageTooLarge
            }
            throw ApiClientError.decoding(data, nil)
        }
    }
    
    func deleteImage(alias: String, deleteToken: String) async throws {
        throw ApiClientError.featureUnsupported
    }
}
