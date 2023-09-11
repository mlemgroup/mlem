//
//  Sorting Options.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

enum PostSortType: String, Codable, CaseIterable, Identifiable {
    case hot = "Hot"
    case active = "Active"
    case new = "New"
    case old = "Old"
    case newComments = "NewComments"
    case mostComments = "MostComments"
    
    case topHour = "TopHour"
    case topSixHour = "TopSixHour"
    case topTwelveHour = "TopTwelveHour"
    case topDay = "TopDay"
    case topWeek = "TopWeek"
    case topMonth = "TopMonth"
    case topThreeMonth = "TopThreeMonth"
    case topSixMonth = "TopSixMonth"
    case topNineMonth = "TopNineMonth"
    case topYear = "TopYear"
    case topAll = "TopAll"
    
    var id: Self { self }
    
    static var outerTypes: [PostSortType] { [.hot, .active, .new, .old, .newComments, .mostComments] }
    static var topTypes: [PostSortType] { [.topHour, .topSixHour, .topTwelveHour, .topDay, .topWeek, .topMonth, .topYear, .topAll] }
    
    var description: String {
        switch self {
        case .newComments:
            return "New comments"
        case .mostComments:
            return "Most comments"
        case .topHour:
            return "Top of the last hour"
        case .topSixHour:
            return "Top of the last six hours"
        case .topTwelveHour:
            return "Top of the last twelve hours"
        case .topDay:
            return "Top of today"
        case .topWeek:
            return "Top of the week"
        case .topMonth:
            return "Top of the month"
        case .topThreeMonth:
            return "Top of the last three months"
        case .topSixMonth:
            return "Top of the last six months"
        case .topNineMonth:
            return "Top of the last nine months"
        case .topYear:
            return "Top of the year"
        case .topAll:
            return "Top of all time"
        default:
            return label
        }
    }
    
    var switcherLabel: String {
        switch self {
        case .newComments:
            return "New"
        case .mostComments:
            return "Most"
        case .topHour:
            return "Hour"
        case .topSixHour:
            return "Hours"
        case .topTwelveHour:
            return "12 Hours"
        case .topDay:
            return "Day"
        case .topWeek:
            return "Week"
        case .topMonth:
            return "Month"
        case .topThreeMonth:
            return "Months"
        case .topSixMonth:
            return "Months"
        case .topNineMonth:
            return "Months"
        case .topYear:
            return "Year"
        case .topAll:
            return "All Time"
        default:
            return rawValue
        }
    }
    
    var minimumVersion: APISiteVersion {
        switch self {
        case .topThreeMonth, .topSixMonth, .topNineMonth:
            return APISiteVersion(major: 0, minor: 18, patch: 1)
        default:
            return .zero
        }
    }
}

extension PostSortType: SettingsOptions {
    var label: String {
        switch self {
        case .newComments:
            return "New"
        case .mostComments:
            return "Most"
        case .topHour:
            return "Top • Hour"
        case .topSixHour:
            return "Top • 6 Hours"
        case .topTwelveHour:
            return "Top • 12 Hours"
        case .topDay:
            return "Top • Day"
        case .topWeek:
            return "Top • Week"
        case .topMonth:
            return "Top • Month"
        case .topThreeMonth:
            return "Top • 3 Months"
        case .topSixMonth:
            return "Top • 6 Months"
        case .topNineMonth:
            return "Top • 9 Months"
        case .topYear:
            return "Top • Year"
        case .topAll:
            return "Top • All Time"
        default:
            return rawValue
        }
    }
}

extension PostSortType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .active: return AppConstants.activeSortSymbolName
        case .hot: return AppConstants.hotSortSymbolName
        case .new: return AppConstants.newSortSymbolName
        case .old: return AppConstants.oldSortSymbolName
        case .newComments: return AppConstants.newCommentsSymbolName
        case .mostComments: return AppConstants.mostCommentsSymbolName
        default: return AppConstants.topSymbolName
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .active: return AppConstants.activeSortSymbolNameFill
        case .hot: return AppConstants.hotSortSymbolNameFill
        case .new: return AppConstants.newSortSymbolNameFill
        case .old: return AppConstants.oldSortSymbolNameFill
        case .newComments: return AppConstants.newCommentsSymbolNameFill
        case .mostComments: return AppConstants.mostCommentsSymbolNameFill
        default: return AppConstants.topSymbolNameFill
        }
    }
}
