//
//  Community+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-14.
//

import Foundation

// MARK: CacheIdentifiable

public extension Community {
    var cacheId: Int { id }
}

// MARK: ContentModel

public extension Community {
    static var tierNumber: Int = 4
}

// MARK: CommunityOrPerson

public extension Community {
    static var identifierPrefix: String { "!" }
}

// MARK: Blockable

public extension Community {
    func updateBlocked(_ newValue: Bool, callback: ((Bool) -> Void)? = nil) {
        let oldValue = blocked
        blocked = newValue
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.blockCommunity(id: self.id, block: newValue)
                    callback?(true)
                    if newValue {
                        self.api.blocks?.communities[self.actorId] = self.id
                    } else {
                        self.api.blocks?.communities.removeValue(forKey: self.actorId)
                    }
                    return await .init(api: self.api, snapshot: .community2(snapshot))
                } catch {
                    // need to manually roll back because blocked is not included in snapshot informatoin
                    self.blocked = oldValue
                    callback?(false)
                    throw error
                }
            }
        }
    }
}

// MARK: Resolvable

public extension Community {
    /// Returns a `URL` that can be resolved by another `ApiClient`.
    func resolvableUrl(from instance: ContentModelUrlType) -> URL {
        switch instance {
        case .host: actorId.url
        case .provider: .community(host: api.host, name: name)
        }
    }
    
    @inlinable
    var allResolvableUrls: [URL] {
        ContentModelUrlType.allCases.map { resolvableUrl(from: $0) }
    }
}
