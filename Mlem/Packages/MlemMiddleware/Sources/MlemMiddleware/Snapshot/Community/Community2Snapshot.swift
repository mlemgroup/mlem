//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-04.
//

import Foundation

public struct Community2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Community2.
    public let community: Community1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Community2!
    public let subscription: SubscriptionModel
    public let postCount: Int
    public let commentCount: Int
    public let activeUserCount: ActiveUserCount
    public let bannedFromCommunity: Bool?
    
    public var cacheId: Int { community.cacheId }
    
    public init(
        community: Community1Snapshot,
        subscription: SubscriptionModel,
        postCount: Int,
        commentCount: Int,
        activeUserCount: ActiveUserCount,
        bannedFromCommunity: Bool?
    ) {
        self.community = community
        self.subscription = subscription
        self.postCount = postCount
        self.commentCount = commentCount
        self.activeUserCount = activeUserCount
        self.bannedFromCommunity = bannedFromCommunity
    }
}
