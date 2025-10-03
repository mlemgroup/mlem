//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-10.
//

import Foundation

public struct PersonVoteSnapshot: CacheIdentifiable {
    public let creator: Person1Snapshot
    public let score: Int
    public let creatorBannedFromCommunity: Bool?
    
    public var cacheId: Int { creator.id }
    
    public init(
        creator: Person1Snapshot,
        score: Int,
        creatorBannedFromCommunity: Bool?
    ) {
        self.creator = creator
        self.score = score
        self.creatorBannedFromCommunity = creatorBannedFromCommunity
    }
}
