//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-07-05.
//  

import Foundation

// swiftlint:disable:next function_parameter_count
public func createMultiPartForm(
    boundary: String,
    contentType: String,
    name: String,
    fileName: String,
    imageData: Data,
    auth: String
) -> Data {
    var data = Data()
    data.append(Data("--\(boundary)\r\n".utf8))
    data.append(Data("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".utf8))
    data.append(Data("Content-Type: \(contentType)\r\n\r\n".utf8))
    data.append(imageData)
    data.append(Data("\r\n--\(boundary)--\r\n".utf8))
    return data
}
