//
//  Sorting Options.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Dependencies
import Foundation

enum PostSortType: String, Codable, CaseIterable, Identifiable {
    case hot = "Hot"
    case active = "Active"
    case new = "New"
    case old = "Old"
    case scaled = "Scaled"
    case controversial = "Controversial"
    case newComments = "NewComments"
    case mostComments = "MostComments"
    case topHour = "TopHour"
    case topSixHour = "TopSixHour"
    case topTwelveHour = "TopTwelveHour"
    case topDay = "TopDay"
    case topWeek = "TopWeek"
    case topMonth = "TopMonth"
    case topThreeMonths = "TopThreeMonths"
    case topSixMonths = "TopSixMonths"
    case topNineMonths = "TopNineMonths"
    case topYear = "TopYear"
    case topAll = "TopAll"
    
    var id: Self { self }
    
    static var outerTypes: [PostSortType] { [
        .hot,
        .scaled,
        .active,
        .new,
        .old,
        .newComments,
        .mostComments,
        .controversial
    ] }
    
    static var topTypes: [PostSortType] { [
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
    ] }
    
    static func availableOuterTypes(siteVersion: SiteVersion) -> [PostSortType] {
        filterTypes(outerTypes, siteVersion: siteVersion)
    }

    static func availableTopTypes(siteVersion: SiteVersion) -> [PostSortType] {
        filterTypes(topTypes, siteVersion: siteVersion)
    }
    
    /// An array of sort modes that have no minimum version
    static var alwaysAvailableTypes = allCases.filter { $0.minimumVersion == .zero }
    
    private static func filterTypes(_ types: [PostSortType], siteVersion: SiteVersion) -> [PostSortType] {
        types.filter { siteVersion >= $0.minimumVersion }
    }
    
    var minimumVersion: SiteVersion {
        switch self {
        case .controversial, .scaled:
            return .init("0.19.0")
        case .topThreeMonths, .topSixMonths, .topNineMonths:
            return .init("0.18.1")
        default:
            return .zero
        }
    }
    
    var description: String {
        switch self {
        case .topHour:
            return "Top of the last hour"
        case .topSixHour:
            return "Top of the last 6 hours"
        case .topTwelveHour:
            return "Top of the last 12 hours"
        case .topDay:
            return "Top of today"
        case .topWeek:
            return "Top of the week"
        case .topMonth:
            return "Top of the month"
        case .topThreeMonths:
            return "Top of the last 3 months"
        case .topSixMonths:
            return "Top of the last 6 months"
        case .topNineMonths:
            return "Top of the last 9 months"
        case .topYear:
            return "Top of the year"
        case .topAll:
            return "Top of all time"
        default:
            return label
        }
    }
    
    // Pre 0.18.0 it appears that they used integers instead of strings to represent sort types. We can remove this intialiser once we drop support for old versions. To fully support both systems, we'd also need to *encode* back into the correct integer or string format. I'd rather not go through the effort for instance versions that most people don't use any more, so I've disabled the option to edit account settings on instances running <0.18.0
    // - sjmarf
    
    // TODO: 0.17 deprecation remove this initialiser
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            guard let value = PostSortType(rawValue: stringValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid value"
                )
            }
            self = value
        } else if let intValue = try? container.decode(Int.self) {
            guard 0 ... 10 ~= intValue else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Must be an integer in range 0...10."
                )
            }
            let modes: [PostSortType] = [
                .hot,
                .active,
                .new,
                .old,
                .mostComments,
                .newComments,
                .topDay,
                .topWeek,
                .topMonth,
                .topYear,
                .topAll
            ]
            self = modes[intValue]
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid value"
            )
        }
    }
}

extension PostSortType: SettingsOptions {
    var label: String {
        switch self {
        case .newComments:
            return "New Comments"
        case .mostComments:
            return "Most Comments"
        case .topHour:
            return "Hour"
        case .topSixHour:
            return "6 Hours"
        case .topTwelveHour:
            return "12 Hours"
        case .topDay:
            return "Day"
        case .topWeek:
            return "Week"
        case .topMonth:
            return "Month"
        case .topThreeMonths:
            return "3 Months"
        case .topSixMonths:
            return "6 Months"
        case .topNineMonths:
            return "9 Months"
        case .topYear:
            return "Year"
        case .topAll:
            return "All Time"
        default:
            return rawValue
        }
    }
}

extension PostSortType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .active: return Icons.activeSort
        case .hot: return Icons.hotSort
        case .scaled: return Icons.scaledSort
        case .new: return Icons.newSort
        case .old: return Icons.oldSort
        case .newComments: return Icons.newCommentsSort
        case .mostComments: return Icons.mostCommentsSort
        case .controversial: return Icons.controversialSort
        default: return Icons.timeSort
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .active: return Icons.activeSortFill
        case .hot: return Icons.hotSortFill
        case .scaled: return Icons.scaledSortFill
        case .new: return Icons.newSortFill
        case .old: return Icons.oldSortFill
        case .newComments: return Icons.newCommentsSortFill
        case .mostComments: return Icons.mostCommentsSortFill
        case .controversial: return Icons.controversialSortFill
        default: return Icons.timeSortFill
        }
    }
}
