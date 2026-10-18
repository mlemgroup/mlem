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
        myPersonId: Int
    ) -> Report {
        if let item = retrieveModel(cacheId: snapshot.cacheId) {
            updateModel(item, with: snapshot, myPersonId: myPersonId)
            return item
        }
        
        let newItem = performModelTranslation(api: api, from: snapshot, myPersonId: myPersonId)
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from snapshots: [ReportSnapshot],
        myPersonId: Int
    ) -> [Report] {
        snapshots.map { getModel(api: api, from: $0, myPersonId: myPersonId) }
    }
    
    @MainActor
    func performModelTranslation(api: ApiClient, from apiType: ReportSnapshot, myPersonId: Int) -> Report {
        return .init(api: api, properties: .init(api: api, snapshot: apiType, myPersonId: myPersonId))
    }
    
    func updateModel(_ item: Report, with apiType: ReportSnapshot, myPersonId: Int) {
        // attempt a direct update through the queue to avoid overwriting more recent data
        Task {
            await item.updateQueue.attemptDirectUpdate(with: .init(api: item.api, snapshot: apiType, myPersonId: myPersonId))
        }
    }
}
