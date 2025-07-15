//
//  ImageUpload1Providing.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation

public protocol ImageUpload1Providing: ContentModel, Hashable {
    var mediaUpload1: ImageUpload1 { get }
    var url: URL { get }
    var deleted: Bool { get }
}

public extension ImageUpload1Providing {
    /// Delete the image. Doesn't state-fake. Can't be undone.
    func delete() async throws {
        guard let alias = mediaUpload1.alias, let deleteToken = mediaUpload1.deleteToken else {
            throw ApiClientError.featureUnsupported
        }
        try await api.deleteImage(alias: alias, deleteToken: deleteToken)
        mediaUpload1.deleted = true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

public typealias ImageUpload = ImageUpload1Providing
 
