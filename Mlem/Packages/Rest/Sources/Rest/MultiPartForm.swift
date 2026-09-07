//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-07-05.
//  

import Foundation
import UniformTypeIdentifiers

public struct MultipartFormData {
    public let boundary = "Boundary-\(UUID().uuidString)"
    private var body = Data()

    public init() {}
    
    public mutating func addFile(fieldName: String, filename: String, mimeType: String, data: Data) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }

    public mutating func addFile(fieldName: String, filenameWithoutExtension: String, type: UTType?, data: Data) {
        var filename = filenameWithoutExtension
        if let fileExtension = type?.preferredFilenameExtension {
            filename += ".\(fileExtension)"
        }
        self.addFile(
            fieldName: fieldName,
            filename: filename,
            mimeType: type?.preferredMIMEType ?? "application/octet-stream",
            data: data
        )
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
