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
    case topYear = "TopYear"
    case topAll = "TopAll"
    
    var id: Self { self }
    
    static var outerTypes: [PostSortType] { [.hot, .active, .new, .old, .newComments, .mostComments] }
    static var topTypes: [PostSortType] { [.topHour, .topSixHour, .topTwelveHour, .topDay, .topWeek, .topMonth, .topYear, .topAll] }
    
    var description: String {
        switch self {
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
        case .topYear:
            return "Top of the year"
        case .topAll:
            return "Top of all time"
        default:
            return label
        }
    }
}

extension PostSortType: SettingsOptions {
    var label: String {
        switch self {
        case .newComments:
            return "New comments"
        case .mostComments:
            return "Most comments"
        case .topHour:
            return "Hour"
        case .topSixHour:
            return "Six hours"
        case .topTwelveHour:
            return "Twelve hours"
        case .topDay:
            return "Day"
        case .topWeek:
            return "Week"
        case .topMonth:
            return "Month"
        case .topYear:
            return "Year"
        case .topAll:
            return "All time"
        default:
            return rawValue
        }
    }
}

extension PostSortType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .active: return Icons.activeSortSymbolName
        case .hot: return Icons.hotSortSymbolName
        case .new: return Icons.newSortSymbolName
        case .old: return Icons.oldSortSymbolName
        case .newComments: return Icons.newCommentsSymbolName
        case .mostComments: return Icons.mostCommentsSymbolName
        default: return Icons.timeSymbolName
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .active: return Icons.activeSortSymbolNameFill
        case .hot: return Icons.hotSortSymbolNameFill
        case .new: return Icons.newSortSymbolNameFill
        case .old: return Icons.oldSortSymbolNameFill
        case .newComments: return Icons.newCommentsSymbolNameFill
        case .mostComments: return Icons.mostCommentsSymbolNameFill
        default: return Icons.timeSymbolNameFill
        }
    }
}
