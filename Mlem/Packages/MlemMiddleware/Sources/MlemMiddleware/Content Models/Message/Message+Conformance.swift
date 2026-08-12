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

// MARK: ContentIdentifiable

public extension Message {
    static var modelTypeId: ContentType { .message }
}

// MARK: OwnershipProviding

public extension Message {
    func isOwnContent(myPersonId: Int) -> Bool { isOwnMessage }
}

// MARK: FeedLoadable

public extension Message {
    typealias FilterType = InboxItemFilterType
    
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
}
