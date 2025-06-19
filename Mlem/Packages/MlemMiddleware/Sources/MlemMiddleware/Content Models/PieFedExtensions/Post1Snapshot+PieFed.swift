//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Post1Snapshot {
    init(from post: PieFedPost) throws(ApiClientError) {
        self.actorId = post.apId
        self.id = post.id
        self.creatorId = post.userId
        self.communityId = post.communityId
        self.created = post.published
        
        self.title = post.title
        self.content = post.body
        self.linkUrl = post.url
        self.deleted = post.deleted
        self.embed = nil
        self.pinnedCommunity = post.sticky
        self.pinnedInstance = false
        self.locked = post.locked
        self.nsfw = post.nsfw
        self.removed = post.removed
        self.thumbnailUrl = post.thumbnailUrl
        self.updated = post.updated
        self.languageId = post.languageId
        self.altText = post.altText
    }
}
