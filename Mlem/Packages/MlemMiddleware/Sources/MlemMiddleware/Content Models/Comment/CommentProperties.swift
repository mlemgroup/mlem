//
//  CommentProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-19.
//

import Foundation

public struct CommentProperties: UnifiedPropertiesProviding {
    // From Comment1Snapshot, guaranteed to always be present
    let actorId: ActorIdentifier
    let id: Int
    let creatorId: Int
    let postId: Int
    let parentCommentIds: [Int]
    let created: Date
    var content: String
    var updated: Date?
    var distinguished: Bool
    var languageId: Int
    var deleted: Bool
    var removed: Bool
    
    // from Comment2Snapshot
    var creator: Person?
    var post: Post?
    var community: Community?
    var commentCount: Int?
    var creatorIsModerator: Bool?
    var creatorIsAdmin: Bool?
    var creatorBannedFromCommunity: Bool?
    var votes: VotesModel?
    var saved: Bool?
    var watched: Bool?
    
    /// Constructs a CommentProperties from a given snapshot
    @MainActor
    public init(api: ApiClient, snapshot: AnyCommentSnapshot) {
        let snapshot1: Comment1Snapshot
        let snapshot2: Comment2Snapshot?
        switch snapshot {
        case let .comment1(comment1Snapshot):
            snapshot1 = comment1Snapshot
            snapshot2 = nil
        case let .comment2(comment2Snapshot):
            snapshot1 = comment2Snapshot.comment
            snapshot2 = comment2Snapshot
        }
        
        if let snapshot2 {
            let newCreator: Person = api.caches.person.getModel(api: api, from: .person1(snapshot2.creator))
            newCreator.updateKnownCommunityBanState(id: snapshot2.community.id, banned: snapshot2.creatorBannedFromCommunity)
            
            creator = newCreator
            post = api.caches.post.getModel(api: api, from: .post1(snapshot2.post))
            community = api.caches.community.getModel(api: api, from: .community1(snapshot2.community))
            commentCount = snapshot2.commentCount
            creatorIsModerator = snapshot2.creatorIsModerator
            creatorIsAdmin = snapshot2.creatorIsAdmin
            creatorBannedFromCommunity = snapshot2.creatorBannedFromCommunity
            votes = snapshot2.votes
            saved = snapshot2.saved
            watched = snapshot2.watched
        }
        
        actorId = snapshot1.actorId
        id = snapshot1.id
        creatorId = snapshot1.creatorId
        postId = snapshot1.postId
        parentCommentIds = snapshot1.parentCommentIds
        created = snapshot1.created
        content = snapshot1.content
        updated = snapshot1.updated
        distinguished = snapshot1.distinguished
        languageId = snapshot1.languageId
        deleted = snapshot1.deleted
        removed = snapshot1.removed
    }
    
    public mutating func merge(_ other: CommentProperties) {
        // tier 1 properties: simple assignment
        self.content = other.content
        self.updated = other.updated
        self.distinguished = other.distinguished
        self.languageId = other.languageId
        self.deleted = other.deleted
        self.removed = other.removed
        
        // tier 2 properties: only assign if incoming non-nil
        self.creator = other.creator ?? self.creator
        self.post = other.post ?? self.post
        self.community = other.community ?? self.community
        self.commentCount = other.commentCount ?? self.commentCount
        self.creatorIsModerator = other.creatorIsModerator ?? self.creatorIsModerator
        self.creatorIsAdmin = other.creatorIsAdmin ?? self.creatorIsAdmin
        self.creatorBannedFromCommunity = other.creatorBannedFromCommunity ?? self.creatorBannedFromCommunity
        self.votes = other.votes ?? self.votes
        self.saved = other.saved ?? self.saved
        self.watched = other.watched ?? self.watched
    }
}
