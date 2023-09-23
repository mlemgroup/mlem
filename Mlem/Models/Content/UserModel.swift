//
//  UserModel.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import Dependencies
import Foundation

struct UserModel {
    let userId: Int
    var user: APIPerson
    var postCount: Int
    var commentCount: Int
    
    // Creates a UserModel from an APIPersonView
    /// - Parameter apiPersonView: APIPersonView to create a UserModel representation of
    init(from apiPersonView: APIPersonView) {
        self.userId = apiPersonView.person.id
        self.user = apiPersonView.person
        self.postCount = apiPersonView.counts.postCount
        self.commentCount = apiPersonView.counts.commentCount
    }
}

extension UserModel: Identifiable {
    var id: Int { hashValue }
}

extension UserModel: Hashable {
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(user.id)
    }
}

extension UserModel: ContentModel {
    var uid: ContentModelIdentifier { .init(contentType: .user, contentId: userId) }
    
    var imageUrls: [URL] {
        if let url = user.avatarUrl {
            return [url.withIcon64Parameters]
        }
        return []
    }
    var searchResultScore: Int {
        let result = self.commentCount / 4 + self.postCount
        return Int(result)
    }
}
