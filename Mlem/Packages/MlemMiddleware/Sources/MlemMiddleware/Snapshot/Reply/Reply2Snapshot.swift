//
//  Reply2ApiBacker.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

public struct Reply2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Reply2.
    public let reply: Reply1Snapshot
    public let comment: Comment1Snapshot
    public let creator: Person1Snapshot
    public let post: Post1Snapshot
    public let community: Community1Snapshot
    public let recipient: Person1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Reply2!
    public let subscribed: Bool
    public let commentCount: Int
    public let creatorIsModerator: Bool
    public let creatorIsAdmin: Bool
    public let creatorBannedFromCommunity: Bool
    public let votes: VotesModel
    public let saved: Bool
    
    public var cacheId: Int { reply.id }
    
    public init(
        reply: Reply1Snapshot,
        comment: Comment1Snapshot,
        creator: Person1Snapshot,
        post: Post1Snapshot,
        community: Community1Snapshot,
        recipient: Person1Snapshot,
        subscribed: Bool,
        commentCount: Int,
        creatorIsModerator: Bool,
        creatorIsAdmin: Bool,
        creatorBannedFromCommunity: Bool,
        votes: VotesModel,
        saved: Bool
    ) {
        self.reply = reply
        self.comment = comment
        self.creator = creator
        self.post = post
        self.community = community
        self.recipient = recipient
        self.subscribed = subscribed
        self.commentCount = commentCount
        self.creatorIsModerator = creatorIsModerator
        self.creatorIsAdmin = creatorIsAdmin
        self.creatorBannedFromCommunity = creatorBannedFromCommunity
        self.votes = votes
        self.saved = saved
    }
}
