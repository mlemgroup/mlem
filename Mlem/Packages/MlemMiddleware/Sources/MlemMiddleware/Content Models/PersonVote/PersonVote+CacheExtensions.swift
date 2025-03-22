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
    func update(with voteView: ApiVoteView, semaphore: UInt? = nil) {
        setIfChanged(\.vote, ScoringOperation(rawValue: voteView.score) ?? .none)
        creator.update(with: voteView.creator, semaphore: semaphore)
        if let creatorBannedFromCommunity = voteView.creatorBannedFromCommunity {
            creator.updateKnownCommunityBanState(id: communityId, banned: creatorBannedFromCommunity)
        }
    }
}
