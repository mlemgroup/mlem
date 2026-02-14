//
//  PersonVote+CacheExtensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-18.
//

import Foundation

extension PersonVote: CacheIdentifiable {
    public var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(target)
        hasher.combine(creator.id)
        return hasher.finalize()
    }
    
    @MainActor
    func update(with snapshot: PersonVoteSnapshot, semaphore: UInt? = nil) {
        setIfChanged(\.vote, ScoringOperation(rawValue: snapshot.score) ?? .none)
        if let creatorBannedFromCommunity = snapshot.creatorBannedFromCommunity {
            creator.updateKnownCommunityBanState(id: communityId, banned: creatorBannedFromCommunity)
        }
        Task {
            await creator.updateQueue.attemptDirectUpdate(with: .init(api: api, snapshot: .person1(snapshot.creator)))
        }
    }
}
