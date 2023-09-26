//
//  APIClient+Pictrs.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import Foundation

extension APIClient {
    func uploadImage(_ imageData: Data, callback: @escaping (_ progress: Double) -> Void) async throws -> ImageUploadResponse {
        
        let delegate = ImageUploadDelegate(callback: callback)
        
        // Modify the instance URL to remove "api/v3" and add "pictrs/image".
        var components = URLComponents()
        components.scheme = try self.session.instanceUrl.scheme
        components.host = try self.session.instanceUrl.host
        components.path = "/pictrs/image"
        
        guard let url = components.url else {
            throw APIClientError.response(.init(error: "Failed to modify instance URL to add pictrs."), nil)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("jwt=\(try session.token)", forHTTPHeaderField: "Cookie")
        
        let multiPartForm: MultiPartForm = try .init(
            mimeType: "image/png",
            fileName: "image.png",
            imageData: imageData,
            auth: session.token
        )
        
        let (data, _) = try await self.urlSession.upload(
            for: request,
            from: multiPartForm.createField(boundary: boundary),
            delegate: delegate
        )
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(ImageUploadResponse.self, from: data)
        } catch {
            throw APIClientError.decoding(data)
        }
    }
}

struct ImageUploadResponse: Codable {
    public let msg: String
    public let files: [PictrsFile]
}

struct PictrsFile: Codable, Equatable {
    public let file: String
    public let deleteToken: String
}

private struct MultiPartForm: Codable {
    var mimeType: String
    var fileName: String
    var imageData: Data
    var auth: String
    
    func createField(boundary: String) -> Data {
        var data = Data()
        data.append(Data("--\(boundary)\r\n".utf8))
        data.append(Data("Content-Disposition: form-data; name=\"images[]\"; filename=\"\(fileName)\"\r\n".utf8))
        data.append(Data("Content-Type: \(mimeType)\r\n".utf8))
        data.append(Data("\r\n".utf8))
        data.append(imageData)
        data.append(Data("\r\n".utf8))
        data.append(Data("--\(boundary)--\r\n".utf8))
        return data
    }
}

private class ImageUploadDelegate: NSObject, URLSessionTaskDelegate {
    public let callback: (Double) -> Void
    
    public init(callback: @escaping (Double) -> Void) {
        self.callback = callback
    }
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        callback(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
    }
}
