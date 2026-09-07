//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-07-05.
//  

import Foundation

public struct MultipartFormData {
    public let boundary = "Boundary-\(UUID().uuidString)"
    private var body = Data()

    public init() {}
    
    public mutating func addFile(name: String, filename: String, mimeType: String, data: Data) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }
    
    public func finalize() -> Data {
        var finalBody = body
        finalBody.append("--\(boundary)--\r\n")
        return finalBody
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
