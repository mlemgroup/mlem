//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Post1Snapshot {
    init(from post: PieFedPost) throws(ApiClientError) {
        self.init(
            actorId: post.apId,
            id: post.id,
            creatorId: post.userId,
            communityId: post.communityId,
            created: post.published,
            title: post.title,
            content: post.body,
            linkUrl: post.url,
            embed: nil,
            poll: post.poll.map { .init(from: $0) },
            nsfw: post.nsfw,
            thumbnailUrl: post.thumbnailUrl,
            updated: post.updated,
            languageId: post.languageId,
            altText: post.altText,
            // If a post is removed, deleted is true for some reason
            deleted: post.removed ? false : post.deleted,
            removed: post.removed,
            pinnedCommunity: post.sticky,
            pinnedInstance: false,
            locked: post.locked
        )
    }
}
