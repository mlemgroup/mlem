//
//  SortTimeRange.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-03-01.
//

import Foundation

public enum SortTimeRange: Hashable, Sendable {
    case allTime
    case limited(TimeInterval)
    
    public static func limited(_ timeRangeLimit: LegacySortTimeRangeLimit) -> Self {
        .limited(timeRangeLimit.timeInterval)
    }
    
    init?(_ apiSortType: LemmySortType) {
        if apiSortType == .topAll {
            self = .allTime
        } else if let legacyTimeRange = LegacySortTimeRangeLimit(apiSortType) {
            self = .limited(legacyTimeRange)
        } else {
            return nil
        }
    }
    
    public static var legacyCases: [Self] = LegacySortTimeRangeLimit.allCases.map { .limited($0) } + [.allTime]
 
    // This should only be used internally within ApiClient
    var timeRangeSeconds: Int {
        switch self {
        case .allTime: Int(Int32.max) // Going higher than this value causes an error
        case let .limited(value): Int(value)
        }
    }
}
