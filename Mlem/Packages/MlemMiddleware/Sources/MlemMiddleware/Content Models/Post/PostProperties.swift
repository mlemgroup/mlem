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
    var crossPosts: [Post]?
    
    /// Updates this properties with the values from the given PostProperties, preferring the incoming values
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
        
        if let creator, let creatorBannedFromCommunity {
            creator.person1.updateKnownCommunityBanState(id: communityId, banned: creatorBannedFromCommunity)
        }
    }
    
    /// Updates this properties with the values from the given PostProperties, preferring the current values
    @MainActor
    public mutating func softUpdate(with properties: Self) {
        // all tier 1 properties ignored since guaranteed to be present already
        
        creator = creator ?? properties.creator
        community = community ?? properties.community
        commentCount = commentCount ?? properties.commentCount
        unreadCommentCount = unreadCommentCount ?? properties.unreadCommentCount
        creatorIsModerator = creatorIsModerator ?? properties.creatorIsModerator
        creatorIsAdmin = creatorIsAdmin ?? properties.creatorIsAdmin
        creatorBannedFromCommunity = creatorBannedFromCommunity ?? properties.creatorBannedFromCommunity
        creatorBlocked = creatorBlocked ?? properties.creatorBlocked
        votes = votes ?? properties.votes
        saved = saved ?? properties.saved
        read = read ?? properties.read
        hidden = hidden ?? properties.hidden
        
        crossPosts = crossPosts ?? properties.crossPosts
        
        if let creator, let creatorBannedFromCommunity {
            creator.person1.updateKnownCommunityBanState(id: communityId, banned: creatorBannedFromCommunity)
        }
    }
    
    /// Constructs a PostProperties from a given snapshot
    /// - Note: External models (e.g., Creator) will NOT be included!
    public init(snapshot: AnyPostSnapshot) {
        let snapshot1: Post1Snapshot
        let snapshot2: Post2Snapshot?
        switch snapshot {
        case let .post1(post1Snapshot):
            snapshot1 = post1Snapshot
            snapshot2 = nil
        case let .post2(post2Snapshot):
            snapshot1 = post2Snapshot.post
            snapshot2 = post2Snapshot
        case let .post3(post3Snapshot):
            snapshot1 = post3Snapshot.post.post
            snapshot2 = post3Snapshot.post
        }
        
        if let snapshot2 {
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
        }
        
        actorId = snapshot1.actorId
        id = snapshot1.id
        creatorId = snapshot1.creatorId
        communityId = snapshot1.communityId
        created = snapshot1.created
        title = snapshot1.title
        content = snapshot1.content
        linkUrl = snapshot1.linkUrl
        embed = snapshot1.embed
        nsfw = snapshot1.nsfw
        thumbnailUrl = snapshot1.thumbnailUrl
        updated = snapshot1.updated
        languageId = snapshot1.languageId
        altText = snapshot1.altText
        deleted = snapshot1.deleted
        removed = snapshot1.removed
        pinnedCommunity = snapshot1.pinnedCommunity
        pinnedInstance = snapshot1.pinnedInstance
        locked = snapshot1.locked
    }
    
    /// Constructs a PostProperties from a given snapshot, including external models
    public init(snapshot: AnyPostSnapshot, creator: (any Person)?, community: (any Community)?, crossPosts: [Post]?) {
        if let creator {
            switch snapshot {
            case let .post2(post2Snapshot):
                creator.person1.updateKnownCommunityBanState(
                    id: post2Snapshot.community.id,
                    banned: post2Snapshot.creatorBannedFromCommunity)
            case let .post3(post3Snapshot):
                creator.person1.updateKnownCommunityBanState(
                    id: post3Snapshot.community.community.id,
                    banned: post3Snapshot.post.creatorBannedFromCommunity)
            default: break // noop
            }
        }
        
        self.init(snapshot: snapshot)
        self.creator = creator
        self.community = community
        self.crossPosts = crossPosts
    }
}
