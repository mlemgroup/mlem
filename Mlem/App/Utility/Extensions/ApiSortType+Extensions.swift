//
//  ApiSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import Foundation
import MlemMiddleware

extension ApiSortType: @retroactive CaseIterable {
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
    
    public static let allCases: [Self] = nonTopCases + topCases
    
    enum TopSortModeFormatStyle {
        case topOnly
        case timescaleAbbreviated
        case timescaleFull
        case topAndTimescale
    }
    
    static let communitySearchCases: [Self] = [.controversial, .new, .old] + topCases
    static let personSearchCases: [Self] = [.new, .old, .topAll]
    
    var minimumVersion: SiteVersion {
        switch self {
        case .controversial, .scaled: .v19_0
        case .topThreeMonths, .topSixMonths, .topNineMonths: .v18_1
        default: .zero
        }
    }
    
    private func basicLabel(abbreviateUnits: Bool = false) -> String {
        switch self {
        case .active:
            .init(localized: "Active")
        case .hot:
            .init(localized: "Hot")
        case .new:
            .init(localized: "New")
        case .old:
            .init(localized: "Old")
        case .topAll:
            .init(localized: "All Time")
        case .mostComments:
            .init(localized: "Most Comments")
        case .newComments:
            .init(localized: "New Comments")
        case .controversial:
            .init(localized: "Controversial")
        case .scaled:
            .init(localized: "Scaled")
        default:
            formatter(unitsStyle: abbreviateUnits ? .abbreviated : .full)
                .string(for: dateComponents)?
                .capitalized ?? ""
        }
    }
    
    func label(topFormat: TopSortModeFormatStyle = .timescaleFull) -> String {
        if ApiSortType.topCases.contains(self) {
            switch topFormat {
            case .topOnly:
                return String(localized: "Top")
            case .topAndTimescale:
                return String(localized: "Top: \(basicLabel(abbreviateUnits: true))")
            default: break
            }
        }
        return basicLabel(abbreviateUnits: topFormat != .timescaleFull)
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
    
    var dateComponents: DateComponents? {
        switch self {
        case .topHour: .init(hour: 1)
        case .topSixHour: .init(hour: 6)
        case .topTwelveHour: .init(hour: 12)
        case .topDay: .init(day: 1)
        case .topWeek: .init(weekOfMonth: 1)
        case .topMonth: .init(month: 1)
        case .topThreeMonths: .init(month: 3)
        case .topSixMonths: .init(month: 6)
        case .topNineMonths: .init(month: 9)
        case .topYear: .init(year: 1)
        default: nil
        }
    }
    
    var explanation: LocalizedStringResource? {
        switch self {
        case .hot: "Ranks posts based on the post score and creation time."
        case .scaled: "Similar to \"Hot\", but ranks posts from smaller communities higher."
        case .active: "Ranks posts based on the post score and the time since the last comment was created."
        default: nil
        }
    }
    
    private func formatter(unitsStyle: DateComponentsFormatter.UnitsStyle) -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        return formatter
    }
}
