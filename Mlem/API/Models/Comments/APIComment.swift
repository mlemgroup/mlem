//
//  APIComment.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::source::comment::Comment
struct APIComment: Decodable, Identifiable {
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
