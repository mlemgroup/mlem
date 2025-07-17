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
    
    var deletedManager: StateManager<Bool>
    public var deleted: Bool { deletedManager.displayedValue }
    
    public var removedManager: StateManager<Bool>
    public var removed: Bool { removedManager.displayedValue }
    
    public var lockedManager: StateManager<Bool>
    public var locked: Bool { lockedManager.displayedValue }
    public var verifiedLocked: Bool { lockedManager.verifiedValue }
    
    public var pinnedCommunityManager: StateManager<Bool>
    public var pinnedCommunity: Bool { pinnedCommunityManager.displayedValue }
    
    public var pinnedInstanceManager: StateManager<Bool>
    public var pinnedInstance: Bool { pinnedInstanceManager.displayedValue }
    
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
        self.deletedManager = .init(wrappedValue: deleted)
        self.embed = embed
        self.pinnedCommunityManager = .init(wrappedValue: pinnedCommunity)
        self.pinnedInstanceManager = .init(wrappedValue: pinnedInstance)
        self.lockedManager = .init(wrappedValue: locked)
        self.nsfw = nsfw
        self.removedManager = .init(wrappedValue: removed)
        self.thumbnailUrl = thumbnailUrl
        self.updated = updated
        self.languageId = languageId
        self.altText = altText
        
        Task {
            await updateQueue.setParent(self)
        }
    }
}
