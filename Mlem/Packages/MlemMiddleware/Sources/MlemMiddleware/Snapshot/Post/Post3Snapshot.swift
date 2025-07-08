//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-07.
//

import Foundation

public struct Post3Snapshot: CacheIdentifiable, PostSnapshotProviding {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Post2.
    public let post: Post2Snapshot
    public let community: Community2Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Post3!
    public let crossPosts: [Post2Snapshot]
    
    public var cacheId: Int { post.cacheId }
    
    public init(from post: ApiGetPostResponse) throws(ApiClientError) {
        self.post = try .init(from: post.postView)
        self.community = try .init(from: post.communityView)
        
        var crossPosts: [Post2Snapshot] = []
        for crossPost in post.crossPosts {
            try crossPosts.append(.init(from: crossPost))
        }
        self.crossPosts = crossPosts
    }
}
