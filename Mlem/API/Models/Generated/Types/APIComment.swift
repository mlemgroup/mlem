//
//  APIComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/Comment.ts
struct APIComment: Codable {
    // swiftlint:disable:next identifier_name
    let id: Int
    let creatorId: Int
    let postId: Int
    let content: String
    let removed: Bool
    let published: Date
    let updated: Date?
    let deleted: Bool
    let apId: URL
    let local: Bool
    let path: String
    let distinguished: Bool
    let languageId: Int
}
