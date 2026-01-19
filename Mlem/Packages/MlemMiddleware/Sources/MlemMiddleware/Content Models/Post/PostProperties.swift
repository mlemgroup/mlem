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
    
    public mutating func merge(_ other: PostProperties) {
        // tier 1 properties: simple assignment
        self.actorId = other.actorId
        self.id = other.id
        self.creatorId = other.creatorId
        self.communityId = other.communityId
        self.created = other.created
        self.title = other.title
        self.content = other.content
        self.linkUrl = other.linkUrl
        self.embed = other.embed
        self.nsfw = other.nsfw
        self.thumbnailUrl = other.thumbnailUrl
        self.updated = other.updated
        self.languageId = other.languageId
        self.altText = other.altText
        self.deleted = other.deleted
        self.removed = other.removed
        self.pinnedCommunity = other.pinnedCommunity
        self.pinnedInstance = other.pinnedInstance
        self.locked = other.locked
        
        // tier 2, 3 properties: only assign if incoming non-nil
        self.creator = other.creator ?? self.creator
        self.community = other.community ?? self.community
        self.commentCount = other.commentCount ?? self.commentCount
        self.unreadCommentCount = other.unreadCommentCount ?? self.unreadCommentCount
        self.creatorIsModerator = other.creatorIsModerator ?? self.creatorIsModerator
        self.creatorIsAdmin = other.creatorIsAdmin ?? self.creatorIsAdmin
        self.creatorBannedFromCommunity = other.creatorBannedFromCommunity ?? self.creatorBannedFromCommunity
        self.creatorBlocked = other.creatorBlocked ?? self.creatorBlocked
        self.votes = other.votes ?? self.votes
        self.saved = other.saved ?? self.saved
        self.read = other.read ?? self.read
        self.hidden = other.hidden ?? self.hidden
        
        self.crossPosts = other.crossPosts ?? self.crossPosts
    }
}
