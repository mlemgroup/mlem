//
//  PostSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-28.
//

import Foundation
import MlemMiddleware

// Formatting extension
extension PostSortType {
    enum TopSortModeFormatStyle {
        case topOnly
        case timescaleAbbreviated
        case timescaleFull
        case topAndTimescale
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
        case let .top(interval):
            if interval != nil {
                dateComponentsLabel(abbreviateUnits: abbreviateUnits)
            } else {
                // swiftlint:disable:next void_function_in_ternary
                abbreviateUnits ? .init(localized: "All") : .init(localized: "All Time")
            }
        case .mostComments:
            .init(localized: "Most Comments")
        case .newComments:
            .init(localized: "New Comments")
        case .controversial:
            .init(localized: "Controversial")
        case .scaled:
            .init(localized: "Scaled")
        }
    }
    
    private func dateComponentsLabel(abbreviateUnits: Bool) -> String {
        let dateComponents: DateComponents
        switch self {
        case let .top(seconds):
            if let seconds {
                var seconds = Int(seconds)
                // Convert a year to exactly 365 days
                let years = seconds / (3600 * 24 * 365)
                seconds %= (3600 * 24 * 365)
                // Convert a month to exactly 30 days
                let months = seconds / (3600 * 24 * 30)
                seconds %= (3600 * 24 * 30)
                dateComponents = .init(year: years, month: months, second: seconds)
            } else {
                return ""
            }
        default:
            return ""
        }
        
        if abbreviateUnits {
            return formatter(unitsStyle: .abbreviated).string(for: dateComponents) ?? ""
        } else {
            return formatter(unitsStyle: .full)
                .string(for: dateComponents)?
                .capitalized ?? ""
        }
    }
    
    func label(topFormat: TopSortModeFormatStyle = .timescaleFull) -> String {
        switch self {
        case .top:
            switch topFormat {
            case .topOnly:
                String(localized: "Top")
            case .topAndTimescale:
                String(localized: "Top: \(basicLabel(abbreviateUnits: false))")
            case .timescaleAbbreviated:
                basicLabel(abbreviateUnits: true)
            case .timescaleFull:
                basicLabel(abbreviateUnits: false)
            }
        default:
            basicLabel(abbreviateUnits: topFormat != .timescaleFull)
        }
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
        case .top: Icons.topSort
        }
    }
    
    var explanation: LocalizedStringResource? {
        switch self {
        case .hot: "Ranks posts based on the post score and creation time."
        case .scaled: "Similar to Hot, but ranks posts from smaller communities higher."
        case .active: "Ranks posts based on the post score and the time since the last comment was created."
        default: nil
        }
    }
    
    private func formatter(unitsStyle: DateComponentsFormatter.UnitsStyle) -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitsStyle
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        return formatter
    }
}
