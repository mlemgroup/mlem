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
        from apiType: any ReportApiBacker,
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> Report {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            item.update(with: apiType, semaphore: semaphore)
            return item
        }
        
        let newItem: Report = .init(
            api: api,
            id: apiType.id,
            creator: api.caches.person1.getModel(api: api, from: apiType.creator, semaphore: semaphore),
            resolver: api.caches.person1.getOptionalModel(api: api, from: apiType.resolver, semaphore: semaphore),
            target: apiType.createTarget(api: api, myPersonId: myPersonId),
            resolved: apiType.resolved,
            reason: apiType.reason,
            created: apiType.published,
            updated: apiType.updated
        )
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from apiTypes: [any ReportApiBacker],
        myPersonId: Int,
        semaphore: UInt? = nil
    ) -> [Report] {
        apiTypes.map { getModel(api: api, from: $0, myPersonId: myPersonId, semaphore: semaphore) }
    }
}
