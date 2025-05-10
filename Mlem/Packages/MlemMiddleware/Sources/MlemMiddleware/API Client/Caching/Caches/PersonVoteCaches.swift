//
//  PersonVoteCaches.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-18.
//

import Foundation

class PersonVoteCache: CoreCache<PersonVote> {
    @MainActor
    func getModel(
        api: ApiClient,
        from snapshot: PersonVoteSnapshot,
        target: PersonVote.Target,
        communityId: Int,
        semaphore: UInt? = nil
    ) -> PersonVote {
        if let item = retrieveModel(cacheId: getCacheId(target: target, creatorId: snapshot.creator.id)) {
            item.update(with: snapshot, semaphore: semaphore)
            return item
        }
        
        let newItem: PersonVote = .init(
            api: api,
            target: target,
            communityId: communityId,
            creator: api.caches.person1.getModel(api: api, from: snapshot.creator),
            vote: .init(rawValue: snapshot.score) ?? .none,
            creatorBannedFromCommunity: snapshot.creatorBannedFromCommunity
        )
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from apiTypes: [ApiVoteView],
        target: PersonVote.Target,
        communityId: Int,
        semaphore: UInt? = nil
    ) -> [PersonVote] {
        apiTypes.map {
            getModel(
                api: api,
                from: $0,
                target: target,
                communityId: communityId,
                semaphore: semaphore
            )
        }
    }
    
    private func getCacheId(target: PersonVote.Target, creatorId: Int) -> Int {
        var hasher = Hasher()
        hasher.combine(target)
        hasher.combine(creatorId)
        return hasher.finalize()
    }
}
