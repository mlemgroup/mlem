//
//  APIComment.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APIComment: Decodable, Identifiable {
    let apId: String
    let content: String
    let creatorId: Int
    let deleted: Bool
    let distinguished: Bool
    let id: Int
    let languageId: Int
    let local: Bool
    let path: String
    let postId: Int
    let published: Date
    let removed: Bool
    let updated: Date?
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
