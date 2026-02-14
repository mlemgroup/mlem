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
    
