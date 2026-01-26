//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Post1Snapshot {
    init(from post: LemmyPost) throws(ApiClientError) {
        guard let published = post.publishedAt ?? post.published else {
            throw .responseMissingRequiredData("LemmyPost published")
        }

        self.init(
            actorId: post.apId,
            id: post.id,
            creatorId: post.creatorId,
            communityId: post.communityId,
            created: published,
            title: post.name,
            content: post.body,
            linkUrl: post.linkUrl,
            embed: post.embed,
            poll: nil,
            nsfw: post.nsfw,
            thumbnailUrl: post.thumbnailImageUrl,
            updated: post.updatedAt ?? post.updated,
            languageId: post.languageId,
            altText: post.altText,
            deleted: post.deleted,
            removed: post.removed,
            pinnedCommunity: post.featuredCommunity,
            pinnedInstance: post.featuredLocal,
            locked: post.locked
        )
    }
}
