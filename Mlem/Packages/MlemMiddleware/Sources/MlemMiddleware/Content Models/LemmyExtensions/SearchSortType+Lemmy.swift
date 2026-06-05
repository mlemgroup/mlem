//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension SearchSortType {
    init?(_ legacyApiSortType: LemmySortType) {
        switch legacyApiSortType {
        case .new:
            self = .new
        case .old:
            self = .old
        default:
            if let timeRange = SortTimeRange(legacyApiSortType) {
                self = .top(timeRange)
            } else {
                return nil
            }
        }
    }
    
    internal var v3ApiType: LemmySortType? {
        switch self {
        case .new: .new
        case .old: .old
        case let .top(timeRange): timeRange.legacyApiSortType
        }
    }
}
