//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Post1Snapshot {
    init(from post: LemmyPost) throws(ApiClientError) {
        self.actorId = post.apId
        self.id = post.id
        self.creatorId = post.creatorId
        self.communityId = post.communityId
        
        if let published = post.publishedAt ?? post.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyPost published")
        }

        self.title = post.name
        self.content = post.body
        self.linkUrl = post.linkUrl
        self.deleted = post.deleted
        self.embed = post.embed
        self.pinnedCommunity = post.featuredCommunity
        self.pinnedInstance = post.featuredLocal
        self.locked = post.locked
        self.nsfw = post.nsfw
        self.removed = post.removed
        self.thumbnailUrl = post.thumbnailImageUrl
        self.updated = post.updatedAt ?? post.updated
        self.languageId = post.languageId
        self.altText = post.altText
    }
}
