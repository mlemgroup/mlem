//
//  PostProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

import Foundation

public struct PostProperties: UnifiedPropertiesProviding {
    public typealias Snapshot = PostSnapshotProviding
    
    // From Post1Snapshot, guaranteed to always be present
    var actorId: ActorIdentifier
    var id: Int
    var creatorId: Int
    var communityId: Int
    var created: Date
    var title: String
    var content: String?
    var linkUrl: URL?
    var embed: PostEmbed?
    var nsfw: Bool
    var thumbnailUrl: URL?
    var updated: Date?
    var languageId: Int
    var altText: String?
    var deleted: Bool
    var removed: Bool
    var pinnedCommunity: Bool
    var pinnedInstance: Bool
    var locked: Bool
    
    // From Post2Snapshot
    var creator: (any Person)?
    var community: (any Community)?
    var commentCount: Int?
    var unreadCommentCount: Int?
    var creatorIsModerator: Bool?
    var creatorIsAdmin: Bool?
    var creatorBannedFromCommunity: Bool?
    var creatorBlocked: Bool?
    var votes: VotesModel?
    var saved: Bool?
    var read: Bool?
    var hidden: Bool?
    
    // From Post3Snapshot
    var crossPosts: [UnifiedPostModel]?
    
    @MainActor
    public mutating func update(with properties: Self) {
        actorId = properties.actorId
        id = properties.id
        creatorId = properties.creatorId
        communityId = properties.communityId
        created = properties.created
        title = properties.title
        content = properties.content
        linkUrl = properties.linkUrl
        embed = properties.embed
        nsfw = properties.nsfw
        thumbnailUrl = properties.thumbnailUrl
        updated = properties.updated
        languageId = properties.languageId
        altText = properties.altText
        deleted = properties.deleted
        removed = properties.removed
        pinnedCommunity = properties.pinnedCommunity
        pinnedInstance = properties.pinnedInstance
        locked = properties.locked

        creator = properties.creator ?? creator
        community = properties.community ?? community
        commentCount = properties.commentCount ?? commentCount
        unreadCommentCount = properties.unreadCommentCount ?? unreadCommentCount
        creatorIsModerator = properties.creatorIsModerator ?? creatorIsModerator
        creatorIsAdmin = properties.creatorIsAdmin ?? creatorIsAdmin
        creatorBannedFromCommunity = properties.creatorBannedFromCommunity ?? creatorBannedFromCommunity
        creatorBlocked = properties.creatorBlocked ?? creatorBlocked
        votes = properties.votes ?? votes
        saved = properties.saved ?? saved
        read = properties.read ?? read
        hidden = properties.hidden ?? hidden
        
        crossPosts = properties.crossPosts ?? crossPosts
    }
    
    /// Constructs a PostProperties from a given snapshot
    /// - Note: External models (e.g., Creator) will NOT be included!
    public init(snapshot: any PostSnapshotProviding) {
        let snapshot2: Post2Snapshot?
        let snapshot1: Post1Snapshot?
        
        if let snapshot3 = snapshot as? Post3Snapshot {
            // Post3Snapshot-specific properties all must be explicitly passed in
            snapshot2 = snapshot3.post
        } else {
            snapshot2 = snapshot as? Post2Snapshot
        }
        
        if let snapshot2 {
            snapshot1 = snapshot2.post
            
            commentCount = snapshot2.commentCount
            unreadCommentCount = snapshot2.unreadCommentCount
            creatorIsModerator = snapshot2.creatorIsModerator
            creatorIsAdmin = snapshot2.creatorIsAdmin
            creatorBannedFromCommunity = snapshot2.creatorBannedFromCommunity
            creatorBlocked = snapshot2.creatorBlocked
            votes = snapshot2.votes
            saved = snapshot2.saved
            read = snapshot2.read
            hidden = snapshot2.hidden
        } else {
            snapshot1 = snapshot as? Post1Snapshot
        }
        
        // TODO: NOW unified snapshot model to avoid this force unwrap
        let shimSnapshot1 = snapshot1!
        actorId = shimSnapshot1.actorId
        id = shimSnapshot1.id
        creatorId = shimSnapshot1.creatorId
        communityId = shimSnapshot1.communityId
        created = shimSnapshot1.created
        title = shimSnapshot1.title
        content = shimSnapshot1.content
        linkUrl = shimSnapshot1.linkUrl
        embed = shimSnapshot1.embed
        nsfw = shimSnapshot1.nsfw
        thumbnailUrl = shimSnapshot1.thumbnailUrl
        updated = shimSnapshot1.updated
        languageId = shimSnapshot1.languageId
        altText = shimSnapshot1.altText
        deleted = shimSnapshot1.deleted
        removed = shimSnapshot1.removed
        pinnedCommunity = shimSnapshot1.pinnedCommunity
        pinnedInstance = shimSnapshot1.pinnedInstance
        locked = shimSnapshot1.locked
    }
    
    /// Constructs a PostProperties from a given snapshot, including external models
    public init(snapshot: any PostSnapshotProviding, creator: (any Person)?, community: (any Community)?, crossPosts: [UnifiedPostModel]?) {
        self.init(snapshot: snapshot)
        self.creator = creator
        self.community = community
        self.crossPosts = crossPosts
    }
}
