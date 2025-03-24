//
//  CoreCache.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation
import Semaphore

/// Class providing common caching behavior
open class CoreCache<Content: CacheIdentifiable & AnyObject> {
    public var itemCache: ItemCache = .init()
    
    public init() {
        self.itemCache = .init()
    }
    
    public class ItemCache {
        private var cachedItems: Atomic<[Int: WeakReference<Content>]> = .init(.init())
        private let cleaningSemaphore: AsyncSemaphore = .init(value: 1)
        
        var value: [Int: WeakReference<Content>] {
            cachedItems.value
        }
        
        public func put(_ item: Content, overrideCacheId: Int? = nil) {
            let cacheId = overrideCacheId ?? item.cacheId
            cachedItems.value[cacheId] = .init(content: item)
        }
        
        public func get(_ cacheId: Int) -> Content? {
            cachedItems.value[cacheId]?.content
        }
        
        public func remove(_ cacheId: Int) {
            // print("Removed \(cacheId)")
            cachedItems.value[cacheId] = nil
        }
        
        public func clean() async {
            await cleaningSemaphore.wait()
            defer { cleaningSemaphore.signal() }
            for (key, value) in cachedItems.value where value.content == nil {
                remove(key)
            }
        }
    }
    
    /// Retrieves the cached model with the given cacheId, if present
    /// - Parameter cacheId: cacheId of the model to retrieve
    /// - Returns: cached model if present, nil otherwise
    public func retrieveModel(cacheId: Int) -> Content? {
        itemCache.get(cacheId)
    }
    
    /// Remove dead references
    public func clean() {
        Task {
            await itemCache.clean()
        }
    }
}
