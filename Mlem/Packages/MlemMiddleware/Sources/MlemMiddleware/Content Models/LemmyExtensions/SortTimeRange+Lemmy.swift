//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension SortTimeRange {
    var legacyApiSortType: LemmySortType? {
        switch self {
        case .allTime: .topAll
        case let .limited(timeInterval): LegacySortTimeRangeLimit(timeInterval)?.legacyApiSortType
        }
    }
    
    var minimumVersion: SiteVersion {
        switch self {
        case .allTime: .zero
        case let .limited(timeInterval): LegacySortTimeRangeLimit(timeInterval)?.minimumVersion ?? .v1_0_0
        }
    }
}
