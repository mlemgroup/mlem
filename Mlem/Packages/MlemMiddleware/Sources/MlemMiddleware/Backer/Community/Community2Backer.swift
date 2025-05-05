//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-04.
//

import Foundation

public struct Community2Backer: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Community2.
    public let community: Community1Backer
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Community2!
    public let subscription: SubscriptionModel
    public let postCount: Int
    public let commentCount: Int
    public let activeUserCount: Int
    
    public var cacheId: Int { community.cacheId }
    
    init(from community: ApiCommunityView) throws(ApiClientError) {
        self.community = try .init(from: community.community)
        
        self.subscription = .init(from: community.counts, subscribedType: community.subscribed ?? .subscribed)
    }
}
