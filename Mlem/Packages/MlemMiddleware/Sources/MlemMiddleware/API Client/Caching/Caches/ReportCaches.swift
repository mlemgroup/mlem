//
//  ReportCaches.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

// Report can be created from any ReportApiBacker, so we can't use ApiTypeBackedCache
class ReportCache: CoreCache<Report> {
    @MainActor
    func getModel(
        api: ApiClient,
        from snapshot: ReportSnapshot,
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> Report {
        if let item = retrieveModel(cacheId: snapshot.cacheId) {
            item.update(with: snapshot, semaphore: semaphore)
            return item
        }
        
        let newItem: Report = .init(
            api: api,
            id: snapshot.id,
            creator: api.caches.person1.getModel(api: api, from: snapshot.creator, semaphore: semaphore),
            resolver: api.caches.person1.getOptionalModel(api: api, from: snapshot.resolver, semaphore: semaphore),
            target: .init(from: snapshot.target, api: api, myPersonId: myPersonId),
            resolved: snapshot.resolved,
            reason: snapshot.reason,
            created: snapshot.created,
            updated: snapshot.updated
        )
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from snapshots: [ReportSnapshot],
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> [Report] {
        snapshots.map { getModel(api: api, from: $0, myPersonId: myPersonId, semaphore: semaphore) }
    }
}
