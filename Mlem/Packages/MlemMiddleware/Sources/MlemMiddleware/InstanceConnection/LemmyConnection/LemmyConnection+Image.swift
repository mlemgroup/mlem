//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-05.
//

import Foundation
import Rest

public extension LemmyConnection {
    func uploadImage(
        _ imageData: Data,
        fileExtension: String,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1Snapshot {
        guard let token else { throw ApiClientError.notLoggedIn }
        var request = mlemUrlRequest(url: baseUrl.appending(path: "pictrs/image"))
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encodedData = createMultiPartForm(
            boundary: boundary,
            contentType: "image/png",
            name: "images[]",
            fileName: "image.\(fileExtension)",
            imageData: imageData,
            auth: token
        )
        
        let (data, response) = try await restClient.urlSession.upload(
            for: request,
            from: encodedData,
            delegate: ImageUploadDelegate(callback: progressCallback)
        )

        let decoder = JSONDecoder.defaultDecoder

        do {
            let response = try decoder.decode(LemmyPictrsUploadResponse.self, from: data)
            guard let file = response.files?.first else { throw ApiClientError.noEntityFound }
            return .init(from: file, baseUrl: baseUrl)
        } catch DecodingError.dataCorrupted {
            let text = String(decoding: data, as: UTF8.self)
            if text.contains("413 Request Entity Too Large") {
                throw ApiClientError.imageTooLarge
            }
            throw ApiClientError.decoding(data, nil)
        } catch {
            if let error = try? decoder.decode(LemmyErrorResponse.self, from: data) {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                throw ApiClientError.response(error.error, statusCode ?? -1)
            } else {
                throw error
            }
        }
    }
    
    func deleteImage(alias: String, deleteToken: String) async throws {
        guard let token else { throw ApiClientError.notLoggedIn }
        var request = mlemUrlRequest(url: baseUrl.appending(path: "pictrs/image/delete/\(deleteToken)/\(alias)"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let response = try await restClient.execute(request)
        if let response = response.1 as? HTTPURLResponse {
            if response.statusCode != 204 {
                throw ApiClientError.response("Unexpected status code", response.statusCode)
            }
        }
    }
}
