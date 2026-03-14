//
//  Instance+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-03-13.
//

// MARK: CacheIdentifiable

public extension Instance {
    var cacheId: Int { id }
}

// MARK: ContentModel

// TODO: NOW remove this requirement from ContentModel
public extension Instance {
    static var tierNumber: Int = 4
}
