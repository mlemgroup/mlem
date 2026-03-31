//
//  Instance+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-03-13.
//

import Foundation

// MARK: CacheIdentifiable

public extension Instance {
    var cacheId: Int { id }
}

// MARK: ContentModel

// TODO: NOW remove this requirement from ContentModel
public extension Instance {
    static var tierNumber: Int = 4
}

// MARK: ContentIdentifiable

public extension Instance {
    static var modelTypeId: ContentType { .instance }
}

// MARK: Blockable

public extension Instance {
    var blockedValue: Bool { blocked } // TODO: NOW replace with RealizedValueProviding, maybe tighten this logic
    
    func updateBlocked(_ newValue: Bool, callback: ((Bool) -> Void)? = nil) {
        let oldValue = blocked
        blocked = newValue
        
        Task {
            await updateQueue.addItem { properties in
                do {
                    try await self.api.repository.blockInstance(instanceId: self.id, block: newValue)
                    callback?(true)
                    if newValue {
                        self.api.blocks?.instances[self.actorId] = self.id
                    } else {
                        self.api.blocks?.instances.removeValue(forKey: self.actorId)
                    }
                    return properties
                } catch {
                    self.blocked = oldValue
                    callback?(false)
                    throw error
                }
            }
        }
    }
}

// MARK: Sharable

public extension Instance {
    var allResolvableUrls: [URL] { [url()] }
    
    func url() -> URL {
        actorId.url
    }
}
