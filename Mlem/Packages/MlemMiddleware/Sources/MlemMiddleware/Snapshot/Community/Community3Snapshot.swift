//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-05.
//

import Foundation

public struct Community3Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Community3.
    public let community: Community2Snapshot
    
    public let instance: Instance1Snapshot?
    public let moderators: [Person1Snapshot]
    public let discussionLanguageIds: Set<Int>
    
    public var cacheId: Int { community.cacheId }
}
