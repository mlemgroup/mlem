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
    public var post: Post2Snapshot
    public let community: Community2Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Post3!
    public let crossPosts: [Post2Snapshot]
    
    public var cacheId: Int { post.cacheId }
    
    public func merge(with snapshot: any PostSnapshotProviding) -> any PostSnapshotProviding {
        return self
    }
}
