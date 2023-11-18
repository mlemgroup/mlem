//
//  APIClient+Pictrs.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import Foundation

extension APIClient {
    @discardableResult
    func deleteImage(file: PictrsFile) async throws -> ImageDeleteResponse {
        let request = try ImageDeleteRequest(session: session, file: file.file, deleteToken: file.deleteToken)
        return try await perform(request: request)
    }
    
    func uploadImage(
        _ imageData: Data,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void,
        onCompletion completionCallback: @escaping (_ response: ImageUploadResponse?) -> Void,
        catch: @escaping (Error) -> Void
    ) async throws -> Task<Void, any Error> {
        let delegate = ImageUploadDelegate(callback: progressCallback)
        // Modify the instance URL to remove "api/v3" and add "pictrs/image".
        var components = URLComponents()
        components.scheme = try session.instanceUrl.scheme
        components.host = try session.instanceUrl.host
        components.path = "/pictrs/image"
        
        guard let url = components.url else {
            throw APIClientError.response(.init(error: "Failed to modify instance URL to add pictrs."), nil, nil)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        try request.setValue("jwt=\(session.token)", forHTTPHeaderField: "Cookie")
        
        let multiPartForm: MultiPartForm = try .init(
            mimeType: "image/png",
            fileName: "image.png",
            imageData: imageData,
            auth: session.token
        )
        
        return Task { [request] in
            do {
                let (data, _) = try await self.urlSession.upload(
                    for: request,
                    from: multiPartForm.createField(boundary: boundary),
                    delegate: delegate
                )
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(ImageUploadResponse.self, from: data)
                    completionCallback(response)
                } catch DecodingError.dataCorrupted {
                    throw APIClientError.decoding(data)
                }
            } catch {
                if !Task.isCancelled {
                    `catch`(error)
                }
            }
        }
    }
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
