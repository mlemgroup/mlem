//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//  

import Foundation

internal extension LegacySortTimeRangeLimit {
    init?(_ legacyApiSortType: LemmySortType) {
        if let value: Self = switch legacyApiSortType {
        case .topHour: .hour
        case .topSixHour: .sixHour
        case .topTwelveHour: .twelveHour
        case .topDay: .day
        case .topWeek: .week
        case .topMonth: .month
        case .topThreeMonths: .threeMonth
        case .topSixMonths: .sixMonth
        case .topNineMonths: .nineMonth
        case .topYear: .year
        default: nil
        } {
            self = value
        } else {
            return nil
        }
    }
    
    var legacyApiSortType: LemmySortType {
        switch self {
        case .hour: .topHour
        case .sixHour: .topSixHour
        case .twelveHour: .topTwelveHour
        case .day: .topDay
        case .week: .topWeek
        case .month: .topMonth
        case .threeMonth: .topThreeMonths
        case .sixMonth: .topSixMonths
        case .nineMonth: .topNineMonths
        case .year: .topYear
        }
    }
}
