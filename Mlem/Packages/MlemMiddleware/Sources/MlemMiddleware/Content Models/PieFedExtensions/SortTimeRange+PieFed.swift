//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension SortTimeRange {
    var pieFedSearchSortType: PieFedSearchSortType? {
        switch self {
        case .allTime: .topAll
        case let .limited(timeInterval):
            LegacySortTimeRangeLimit(timeInterval)?.pieFedSearchSortType
        }
    }

    var pieFedSortType: PieFedSortType? {
        switch self {
        case .allTime: .topAll
        case let .limited(timeInterval):
            LegacySortTimeRangeLimit(timeInterval)?.pieFedSortType
        }
    }
}
