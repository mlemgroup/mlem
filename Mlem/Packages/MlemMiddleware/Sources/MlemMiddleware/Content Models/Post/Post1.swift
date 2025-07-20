//
//  Post1.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation
import Observation

public struct PostEmbed: Equatable {
    public let title: String?
    public let description: String?
    public let videoUrl: URL?
}

@Observable
public final class Post1: Post1Providing {
    public var updateQueue: PostUpdateQueue = .init()
    
    public static let tierNumber: Int = 1
    public var api: ApiClient
    public var post1: Post1 { self }
    
    public let actorId: ActorIdentifier
    public let id: Int
    public let creatorId: Int
    public let communityId: Int
    
    public var title: String
    
    // We can't name this 'body' because @Observable uses that property name already
    public var content: String?
    public var linkUrl: URL?
    public var embeddedMediaUrl: URL?
    public var embed: PostEmbed?
    public var nsfw: Bool
    public var thumbnailUrl: URL?
    public let created: Date
    public var updated: Date?
    public var languageId: Int
    public var altText: String?
    public var purged: Bool = false
    public var deleted: Bool
    
    public var removed: Bool
    public var removedPending: Bool = false
    
    public var locked: Bool
    public var lockedPending: Bool = false
    
    public var pinnedCommunity: Bool
    public var pinnedCommunityPending: Bool = false
    
    public var pinnedInstance: Bool
    public var pinnedInstancePending: Bool = false
    
    init(
        api: ApiClient,
        actorId: ActorIdentifier,
        id: Int,
        creatorId: Int,
        communityId: Int,
        created: Date,
        title: String,
        content: String?,
        linkUrl: URL?,
        deleted: Bool,
        embed: PostEmbed?,
        pinnedCommunity: Bool,
        pinnedInstance: Bool,
        locked: Bool,
        nsfw: Bool,
        removed: Bool,
        thumbnailUrl: URL?,
        updated: Date?,
        languageId: Int,
        altText: String?
    ) {
        self.api = api
        self.actorId = actorId
        self.id = id
        self.creatorId = creatorId
        self.communityId = communityId
        self.created = created
        self.title = title
        self.content = content
        self.linkUrl = linkUrl
        self.deleted = deleted
        self.embed = embed
        self.pinnedCommunity = pinnedCommunity
        self.pinnedInstance = pinnedInstance
        self.locked = locked
        self.nsfw = nsfw
        self.removed = removed
        self.thumbnailUrl = thumbnailUrl
        self.updated = updated
        self.languageId = languageId
        self.altText = altText
        
        Task {
            await updateQueue.setParent(self)
        }
    }
}
