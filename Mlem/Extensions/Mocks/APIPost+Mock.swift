//
//  APIPost+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension APIPost {
    static func mock(
        id: Int = 0,
        name: String = "Mock Post",
        url: URL? = nil,
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
        thumbnailUrl: URL? = nil,
        updated: Date? = nil
    ) -> APIPost {
        .init(
            id: id,
            name: name,
            url: url,
            body: body,
            creatorId: creatorId,
            communityId: communityId,
            deleted: deleted,
            embedDescription: embedDescription,
            embedTitle: embedTitle,
            embedVideoUrl: embedVideoUrl,
            featuredCommunity: featuredCommunity,
            featuredLocal: featuredLocal,
            languageId: languageId,
            apId: apId,
            local: local,
            locked: locked,
            nsfw: nsfw,
            published: published,
            removed: removed,
            thumbnailUrl: thumbnailUrl,
            updated: updated
        )
    }
}
