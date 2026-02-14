//
//  PostProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

import Foundation

public struct PostProperties: UnifiedPropertiesProviding {
    // From Post1Snapshot, guaranteed to always be present
    let actorId: ActorIdentifier
    let id: Int
    let creatorId: Int
    let communityId: Int
    let created: Date
    var title: String
    var content: String?
    var linkUrl: URL?
    var embed: PostEmbed?
    var poll: PostPoll?
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
    var creator: Person?
    var community: (any DeprecatedCommunity)?
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
    @MainActor
    public init(api: ApiClient, snapshot: AnyPostSnapshot) {
        let snapshot1: Post1Snapshot
        let snapshot2: Post2Snapshot?
        let snapshot3: Post3Snapshot?
        switch snapshot {
        case let .post1(post1Snapshot):
            snapshot1 = post1Snapshot
            snapshot2 = nil
            snapshot3 = nil
        case let .post2(post2Snapshot):
            snapshot1 = post2Snapshot.post
            snapshot2 = post2Snapshot
            snapshot3 = nil
        case let .post3(post3Snapshot):
            snapshot1 = post3Snapshot.post.post
            snapshot2 = post3Snapshot.post
            snapshot3 = post3Snapshot
        }
        
        if let snapshot3 {
            crossPosts = api.caches.post.getModels(api: api, from: snapshot3.crossPosts.map { .post2($0) })
        }
        
        if let snapshot2 {
            let newCreator = api.caches.person.getModel(api: api, from: .person1(snapshot2.creator))
            newCreator.updateKnownCommunityBanState(id: snapshot1.communityId, banned: snapshot2.creatorBannedFromCommunity)
            
            creator = newCreator
            community =  api.caches.community1.getModel(api: api, from: snapshot2.community)
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
        poll = snapshot1.poll
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
    
    public mutating func merge(_ other: PostProperties) {
        // tier 1 properties: simple assignment
        self.title = other.title
        self.content = other.content
        self.linkUrl = other.linkUrl
        self.embed = other.embed
        self.poll = other.poll
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
