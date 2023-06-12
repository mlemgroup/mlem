//
//  APIPost.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::source::post::Post
struct APIPost: Decodable {
    let id: Int
    let name: String
    let url: URL?
    let body: String?
    let creatorId: Int
    let communityId: Int
    let deleted: Bool
    let embedDescription: String?
    let embedTitle: String?
    let embedVideoUrl: String?
    let featuredCommunity: Bool
    let featuredLocal: Bool
    let languageId: Int
    let apId: String
    let local: Bool
    let locked: Bool
    let nsfw: Bool
    let published: Date
    let removed: Bool
    let thumbnailUrl: URL?
    let updated: Date?
}

extension APIPost: Equatable {
    static func == (lhs: APIPost, rhs: APIPost) -> Bool {
        lhs.id == rhs.id
    }
}
