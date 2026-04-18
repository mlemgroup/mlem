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

// MARK: ContentIdentifiable

public extension Instance {
    static var modelTypeId: ContentType { .instance }
}

// MARK: ProfileProviding

public extension Instance {
    var profileCreated: Date? { created }
}

// MARK: Blockable

public extension Instance {
    var updateBlocked: ((Bool, ((Bool) -> Void)?) -> Void)? {
        self.api.token == nil ? nil : self._updateBlocked
    }
    
    private func _updateBlocked(_ newValue: Bool, callback: ((Bool) -> Void)? = nil) {
        let oldValue = blocked.realizedValue
        blocked_.set(newValue)
        
        Task {
            await updateQueue.addItem { properties in
                do {
                    try await self.api.repository.blockInstance(instanceId: self.instanceId, block: newValue)
                    callback?(true)
                    if newValue {
                        self.api.blocks?.instances[self.actorId] = self.instanceId
                    } else {
                        self.api.blocks?.instances.removeValue(forKey: self.actorId)
                    }
                    return properties
                } catch {
                    self.blocked_.set(oldValue)
                    callback?(false)
                    throw error
                }
            }
        }
    }
}

// MARK: Sharable

public extension Instance {
    func url() -> URL {
        actorId.url
    }
}
