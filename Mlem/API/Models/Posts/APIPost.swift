//
//  APIPost.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APIPost: Decodable {
    let apId: String
    let body: String?
    let communityId: Int
    let creatorId: Int
    let deleted: Bool
    let embedDescription: String?
    let embedTitle: String?
    let embedVideoUrl: String?
    let featuredCommunity: Bool
    let featuredLocal: Bool
    let id: Int
    let languageId: Int
    let local: Bool
    let locked: Bool
    let name: String
    let nsfw: Bool
    let published: Date
    let removed: Bool
    let thumbnailUrl: URL?
    let updated: Date?
    let url: URL?
}

extension APIPost: Equatable {
    static func == (lhs: APIPost, rhs: APIPost) -> Bool {
        lhs.id == rhs.id
    }
}
