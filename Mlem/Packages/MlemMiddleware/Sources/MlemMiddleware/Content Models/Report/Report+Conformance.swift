//
//  Report+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-10-12.
//

import Foundation

// MARK: CacheIdentifiable

public extension Report {
    var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(target.type)
        hasher.combine(id)
        return hasher.finalize()
    }
}

// MARK: FeedLoadable

public extension Report {
    typealias FilterType = ModMailItemFilterType
    
    static func == (lhs: Report, rhs: Report) -> Bool {
        lhs.target.case == rhs.target.case && lhs.id == rhs.id
    }
    
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new: .new(created)
        }
    }
}
