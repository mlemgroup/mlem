//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-06.
//

import Foundation

public struct Post2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Post2.
    public let post: Post1Snapshot
    public let creator: Person1Snapshot
    public let community: Community1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Post2!
    public let commentCount: Int
    public let unreadCommentCount: Int
    public let creatorIsModerator: Bool
    public let creatorIsAdmin: Bool
    public let creatorBannedFromCommunity: Bool
    public let creatorBlocked: Bool
    public let votes: VotesModel
    public let saved: Bool
    public let read: Bool
    public let hidden: Bool
    
    public var cacheId: Int { post.cacheId }
}
