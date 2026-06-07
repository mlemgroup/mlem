//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension LegacySortTimeRangeLimit {
    var pieFedSearchSortType: PieFedSearchSortType {
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

    var pieFedSortType: PieFedSortType {
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
