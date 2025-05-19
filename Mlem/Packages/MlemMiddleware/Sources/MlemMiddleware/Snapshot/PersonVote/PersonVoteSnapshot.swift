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
    
    public init(from vote: ApiVoteView) throws(ApiClientError) {
        self.creator = try .init(from: vote.creator)
        self.score = vote.score
        self.creatorBannedFromCommunity = vote.creatorBannedFromCommunity
    }
}
