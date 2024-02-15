//
//  APIPost.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::source::post::Post
struct APIPost: Decodable {
    internal init(
        id: Int = 0,
        name: String = "Mock Post",
        url: String? = nil,
        body: String? = nil,
        creatorId: Int = 0,
        communityId: Int = 0,
        deleted: Bool = false,
        embedDescription: String? = nil,
        embedTitle: String? = nil,
        embedVideoUrl: String? = nil,
        featuredCommunity: Bool = false,
        featuredLocal: Bool = false,
        languageId: Int = 0,
        apId: String = "mock.apId",
        local: Bool = false,
        locked: Bool = false,
        nsfw: Bool = false,
        published: Date = .mock,
        removed: Bool = false,
        thumbnailUrl: String? = nil,
        updated: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.body = body
        self.creatorId = creatorId
        self.communityId = communityId
        self.deleted = deleted
        self.embedDescription = embedDescription
        self.embedTitle = embedTitle
        self.embedVideoUrl = embedVideoUrl
        self.featuredCommunity = featuredCommunity
        self.featuredLocal = featuredLocal
        self.languageId = languageId
        self.apId = apId
        self.local = local
        self.locked = locked
        self.nsfw = nsfw
        self.published = published
        self.removed = removed
        self.thumbnailUrl = thumbnailUrl
        self.updated = updated
    }
    
    let id: Int
    let name: String
    let url: String?
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
    let thumbnailUrl: String?
    let updated: Date?
}

extension APIPost: Mockable {
    static var mock: APIPost = .init()
}

extension APIPost {
    var linkUrl: URL? { LemmyURL(string: url)?.url }
    var thumbnailImageUrl: URL? { LemmyURL(string: thumbnailUrl)?.url }
}

extension APIPost: Equatable {
    static func == (lhs: APIPost, rhs: APIPost) -> Bool {
        lhs.id == rhs.id
    }
}

extension APIPost: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(local)
        hasher.combine(published)
    }
}
