//
//  Comment+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-19.
//

// MARK: CacheIdentifiable

public extension Comment {
    var cacheId: Int { id }
}

// MARK: ContentModel

public extension Comment {
    static var tierNumber: Int = 4
}

// MARK: SelectableContentProviding

public extension Comment {
    var selectableContent: String? { content }
}

// MARK: ContentIdentifiable

public extension Comment {
    static var modelTypeId: ContentType { .comment }
}
