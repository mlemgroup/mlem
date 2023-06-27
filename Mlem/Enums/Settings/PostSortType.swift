//
//  Sorting Options.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

enum PostSortType: String, Codable, CaseIterable, Identifiable {
    case active = "Active"
    case hot = "Hot"
    case new = "New"
    case topHour = "TopHour"
    case topSixHour = "TopSixHour"
    case topTwelveHour = "TopTwelveHour"
    case topDay = "TopDay"
    case topWeek = "TopWeek"
    case topMonth = "TopMonth"
    case topYear = "TopYear"
    case topAll = "TopAll"
    case old = "Old"
    case newComments = "NewComments"
    case mostComments = "MostComments"
    
    var id: Self { self }
    
    static var outerTypes: [PostSortType] {[.active, .hot, .new, .newComments, .mostComments, .old]}
    static var topTypes: [PostSortType] {[.topHour, .topSixHour, .topTwelveHour, .topDay, .topWeek, .topMonth, .topYear, .topAll]}

    var shortDescription: String {
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
            return self.rawValue
        }
    }
    
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
            return self.shortDescription
        }
    }
    
    var imageName: String {
        switch self {
        case .active:
            return "bubble.left.and.bubble.right"
        case .hot:
            return "flame"
        case .new:
            return "sun.max"
        case .newComments:
            return "ellipsis.bubble"
        case .mostComments:
            return "chart.line.uptrend.xyaxis"
        case .old:
            return "books.vertical"
        default:
            return "calendar.day.timeline.left"
        }
    }
}
