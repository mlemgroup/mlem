//
//  Person+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

// MARK: ContentModel

public extension Person {
    public static var tierNumber: Int { 4 }
}

// MARK: CacheIdentifiable

public extension Person {
    var cacheId: Int { id }
}
