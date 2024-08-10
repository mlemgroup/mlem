//
//  ApiSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import Foundation
import MlemMiddleware

extension ApiSortType {
    static let nonTopCases: [Self] = [
        .hot,
        .scaled,
        .active,
        .new,
        .old,
        .controversial,
        .newComments,
        .mostComments
    ]
    
    static let topCases: [Self] = [
        .topHour,
        .topSixHour,
        .topTwelveHour,
        .topDay,
        .topWeek,
        .topMonth,
        .topThreeMonths,
        .topSixMonths,
        .topNineMonths,
        .topYear,
        .topAll
    ]
    
    var minimumVersion: SiteVersion {
        switch self {
        case .controversial, .scaled: .v19_0
        case .topThreeMonths, .topSixMonths, .topNineMonths: .v18_1
        default: .zero
        }
    }
    
    var label: LocalizedStringResource {
        switch self {
        case .active: "Active"
        case .hot: "Hot"
        case .new: "New"
        case .old: "Old"
        case .topDay: "Day"
        case .topWeek: "Week"
        case .topMonth: "Month"
        case .topYear: "Year"
        case .topAll: "All Time"
        case .mostComments: "Most Comments"
        case .newComments: "New Comments"
        case .topHour: "Hour"
        case .topSixHour: "6 Hours"
        case .topTwelveHour: "12 Hours"
        case .topThreeMonths: "3 Months"
        case .topSixMonths: "6 Months"
        case .topNineMonths: "9 Months"
        case .controversial: "Controversial"
        case .scaled: "Scaled"
        }
    }
    
    var fullLabel: String {
        if ApiSortType.topCases.contains(self) {
            return String(localized: "Top: \(String(localized: label))")
        }
        return String(localized: label)
    }
    
    var systemImage: String {
        switch self {
        case .active: Icons.activeSort
        case .hot: Icons.hotSort
        case .new: Icons.newSort
        case .old: Icons.oldSort
        case .mostComments: Icons.mostCommentsSort
        case .newComments: Icons.newCommentsSort
        case .controversial: Icons.controversialSort
        case .scaled: Icons.scaledSort
        default: Icons.topSort
        }
    }
}
