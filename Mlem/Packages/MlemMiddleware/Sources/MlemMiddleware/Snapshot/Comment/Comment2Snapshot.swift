//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-07.
//

import Foundation

public struct Comment2Snapshot: CacheIdentifiable, CommentSnapshotProviding {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Post2.
    public var comment: Comment1Snapshot
    public let creator: Person1Snapshot
    public let post: Post1Snapshot
    public let community: Community1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Comment2!
    public let commentCount: Int
    public let creatorIsModerator: Bool
    public let creatorIsAdmin: Bool
    public let creatorBannedFromCommunity: Bool
    public let votes: VotesModel
    public let saved: Bool
    public let notificationsEnabled: Bool

    public var cacheId: Int { comment.cacheId }

    public init(
        comment: Comment1Snapshot,
        creator: Person1Snapshot,
        post: Post1Snapshot,
        community: Community1Snapshot,
        commentCount: Int,
        creatorIsModerator: Bool,
        creatorIsAdmin: Bool,
        creatorBannedFromCommunity: Bool,
        votes: VotesModel,
        saved: Bool,
        notificationsEnabled: Bool
    ) {
        self.comment = comment
        self.creator = creator
        self.post = post
        self.community = community
        self.commentCount = commentCount
        self.creatorIsModerator = creatorIsModerator
        self.creatorIsAdmin = creatorIsAdmin
        self.creatorBannedFromCommunity = creatorBannedFromCommunity
        self.votes = votes
        self.saved = saved
        self.notificationsEnabled = notificationsEnabled
    }
    
    public func merge(with snapshot: any CommentSnapshotProviding) -> any CommentSnapshotProviding {
        self
    }
}
