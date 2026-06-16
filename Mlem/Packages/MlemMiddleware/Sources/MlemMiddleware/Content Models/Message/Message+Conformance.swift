//
//  Message+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-06-15.
//

// MARK: CacheIdentifiable

public extension Message {
    var cacheId: Int { id }
}
