//
//  APIComment.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::source::comment::Comment
struct APIComment: Decodable, Identifiable {
    internal init(
        id: Int = 0,
        creatorId: Int = 0,
        postId: Int = 0,
        content: String = "Mock Comment",
        removed: Bool = false,
        deleted: Bool = false,
        published: Date = .mock,
        updated: Date? = nil,
        apId: String = "mock.apId",
        local: Bool = false,
        path: String = "",
        distinguished: Bool = false,
        languageId: Int = 0
    ) {
        self.id = id
        self.creatorId = creatorId
        self.postId = postId
        self.content = content
        self.removed = removed
        self.deleted = deleted
        self.published = published
        self.updated = updated
        self.apId = apId
        self.local = local
        self.path = path
        self.distinguished = distinguished
        self.languageId = languageId
    }
    
    let id: Int
    let creatorId: Int
    let postId: Int
    let content: String
    let removed: Bool
    let deleted: Bool
    let published: Date
    let updated: Date?
    let apId: String
    let local: Bool
    let path: String
    let distinguished: Bool
    let languageId: Int
}

extension APIComment: Mockable {
    static var mock: APIComment = .init()
}

extension APIComment {
    var parentId: Int? {
        let components = path.components(separatedBy: ".")

        guard path != "0", components.count != 2 else {
            return nil
        }

        guard let id = components.dropLast(1).last else {
            return nil
        }

        return Int(id)
    }
}

extension APIComment: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(updated)
    }
}
