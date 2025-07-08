//
//  ApiPictrsFile.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation

public struct ApiPictrsFile: Codable, Equatable {
    public let file: String
    public let deleteToken: String
}

public extension ApiPictrsFile {
    enum CodingKeys: String, CodingKey {
        case file
        case deleteToken = "delete_token"
    }
}
