//
//  InstanceCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

public enum AnyInstanceSnapshot: CacheIdentifiable {
    case instance1(Instance1Snapshot)
    case instance2(Instance2Snapshot)
    case instance3(Instance3Snapshot)
    
    public var cacheId: Int {
        switch self {
        case let .instance1(snapshot): snapshot.cacheId
        case let .instance2(snapshot): snapshot.cacheId
        case let .instance3(snapshot): snapshot.cacheId
        }
    }
}

class InstanceCache: CoreCache<Instance> {
    public var instanceIdCache: ItemCache = .init()
    
    @MainActor
    func getModel(api: ApiClient, from snapshot: AnyInstanceSnapshot) -> Instance {
        if let item = retrieveModel(cacheId: snapshot.cacheId) {
            item.update(with: .init(api: api, snapshot: snapshot))
            return item
        }
    
        let newItem: Instance = .init(
            api: api,
            properties: .init(api: api, snapshot: snapshot)
        )
        
        itemCache.put(newItem)
        instanceIdCache.put(newItem, overrideCacheId: newItem.instanceId)
        return newItem
    }
    
    @MainActor
    func getModels(api: ApiClient, from snapshots: [AnyInstanceSnapshot]) -> [Instance] {
        snapshots.map { getModel(api: api, from: $0) }
    }
    
    /// Get an instance with the given `instanceId` - this is different from the `id` of the instance.
    public func retrieveModel(instanceId: Int) -> Instance? {
        instanceIdCache.get(instanceId)
    }
    
    override func clean() {
        Task {
            await itemCache.clean()
            await instanceIdCache.clean()
        }
    }
    
    /// Convenience method for getting an optional site
    @MainActor
    func getOptionalModel(api: ApiClient, from snapshot: AnyInstanceSnapshot?) -> Instance? {
        if let snapshot {
            return getModel(api: api, from: snapshot)
        }
        return nil
    }
}
