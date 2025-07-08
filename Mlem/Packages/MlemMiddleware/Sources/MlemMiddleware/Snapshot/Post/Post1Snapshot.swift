//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-06.
//

import Foundation

public struct Post1Snapshot: CacheIdentifiable, PostSnapshotProviding {
    // Won't change.
    public let actorId: ActorIdentifier
    public let id: Int
    public let creatorId: Int
    public let communityId: Int
    public let created: Date
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Post1!
    public let title: String
    public let content: String?
    public let linkUrl: URL?
    public let embed: PostEmbed?
    public let nsfw: Bool
    public let thumbnailUrl: URL?
    public let updated: Date?
    public let languageId: Int
    public let altText: String?
    public let deleted: Bool
    public let removed: Bool
    public let pinnedCommunity: Bool
    public let pinnedInstance: Bool
    public let locked: Bool

    public var cacheId: Int { id }
    
    public init(from post: ApiPost) throws(ApiClientError) {
        self.actorId = post.apId
        self.id = post.id
        self.creatorId = post.creatorId
        self.communityId = post.communityId
        self.created = post.published
        
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
        self.updated = post.updated
        self.languageId = post.languageId
        self.altText = post.altText
    }
}
