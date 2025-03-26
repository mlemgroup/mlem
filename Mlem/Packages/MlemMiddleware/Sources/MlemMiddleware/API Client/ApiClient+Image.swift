//
//  ApiClient+Image.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation

public extension ApiClient {
    func uploadImage(
        _ imageData: Data,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1 {
        guard let token else { throw ApiClientError.notLoggedIn }
        var request = mlemUrlRequest(url: baseUrl.appending(path: "pictrs/image"))
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // This is required pre 0.19.0
        // TODO: 0.18 deprecation: possibly remove this? Haven't tested how >0.19 behaves without this,
        // but I assume it's not required anymore since they're now requiring a different format instead
        request.setValue("jwt=\(token)", forHTTPHeaderField: "Cookie")
        
        // This is required post 0.19.0
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encodedData = createMultiPartForm(
            boundary: boundary,
            mimeType: "image/png",
            fileName: "image/png",
            imageData: imageData,
            auth: token
        )
        
        let (data, _) = try await urlSession.upload(
            for: request,
            from: encodedData,
            delegate: ImageUploadDelegate(callback: progressCallback)
        )
        
        do {
            let response = try decoder.decode(ApiPictrsUploadResponse.self, from: data)
            guard let file = response.files?.first else { throw ApiClientError.noEntityFound }
            return caches.imageUpload1.getModel(api: self, from: file)
        } catch DecodingError.dataCorrupted {
            let text = String(decoding: data, as: UTF8.self)
            if text.contains("413 Request Entity Too Large") {
                throw ApiClientError.imageTooLarge
            }
            throw ApiClientError.decoding(data, nil)
        }
    }
    
    func deleteImage(alias: String, deleteToken: String) async throws {
        guard let token else { throw ApiClientError.notLoggedIn }
        var request = mlemUrlRequest(url: baseUrl.appending(path: "pictrs/image/delete/\(deleteToken)/\(alias)"))
        // TODO: 0.18 deprecation: see comments in method above
        request.setValue("jwt=\(token)", forHTTPHeaderField: "Cookie")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let response = try await execute(request)
        if let response = response.1 as? HTTPURLResponse {
            if response.statusCode != 204 {
                throw ApiClientError.response(.init(error: "Unexpected status code"), response.statusCode)
            }
        }
    }
}

private func createMultiPartForm(
    boundary: String,
    mimeType: String,
    fileName: String,
    imageData: Data,
    auth: String
) -> Data {
    var data = Data()
    data.append(Data("--\(boundary)\r\n".utf8))
    data.append(Data("Content-Disposition: form-data; name=\"images[]\"; filename=\"\(fileName)\"\r\n".utf8))
    data.append(Data("Content-Type: \(mimeType)\r\n\r\n".utf8))
    data.append(imageData)
    data.append(Data("\r\n--\(boundary)--\r\n".utf8))
    return data
}

private class ImageUploadDelegate: NSObject, URLSessionTaskDelegate {
    let callback: (Double) -> Void
    
    init(callback: @escaping (Double) -> Void) {
        self.callback = callback
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        callback(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
    }
}
