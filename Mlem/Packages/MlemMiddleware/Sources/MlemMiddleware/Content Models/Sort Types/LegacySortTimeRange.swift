//
//  LegacySortTimeRange.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-25.
//

import Foundation

/// Represents the available "top" sort time ranges available before Lemmy 1.0.0.
/// After 1.0.0, the top sort time range can be any number of seconds.
public enum LegacySortTimeRangeLimit: CaseIterable {
    case hour
    case sixHour
    case twelveHour
    case day
    case week
    case month
    case threeMonth
    case sixMonth
    case nineMonth
    case year
}

public extension LegacySortTimeRangeLimit {
    init?(_ timeInterval: TimeInterval?) {
        if let match = Self.allCases.first(where: { $0.timeInterval == timeInterval }) {
            self = match
        } else {
            return nil
        }
    }
    
    var timeInterval: TimeInterval {
        let hour = 3600.0
        let day = hour * 24
        let month = day * 30
        
        return switch self {
        case .hour: hour
        case .sixHour: hour * 6
        case .twelveHour: hour * 12
        case .day: day
        case .week: day * 7
        case .month: month
        case .threeMonth: month * 3
        case .sixMonth: month * 6
        case .nineMonth: month * 9
        case .year: day * 365
        }
    }
}
