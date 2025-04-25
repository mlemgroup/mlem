//
//  Date+Extensions.swift
//  Mlem
//
//  Created by Jake Shirley on 6/22/23.
//

import SwiftUI

extension Date {
    // Returns strings like "3 seconds ago" and "10 days ago"
    func getRelativeTime(date: Date = .now, unitsStyle: RelativeDateTimeFormatter.UnitsStyle = .full) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = unitsStyle

        return formatter.localizedString(for: self, relativeTo: date)
    }
    
    // Returns strings like "5/10/2023"
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
    
    func getShortRelativeTime(date: Date = .now, unitsStyle: DateComponentsFormatter.UnitsStyle = .abbreviated) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitsStyle
        formatter.maximumUnitCount = 1
        
        let interval = date.timeIntervalSince(self)
        if interval < 1 {
            return String(localized: "Now")
        }
        
        var components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self,
            to: date
        ).roundingDownToMostSignificantComponent()

        let value = formatter.string(from: components)
        return value ?? String(localized: "Unknown")
    }
    
    var isAnniversaryToday: Bool {
        let calendar = Calendar.current
        let date = calendar.dateComponents([.month, .day, .year], from: self)
        let current = calendar.dateComponents([.month, .day, .year], from: .now)
        return date.month == current.month && date.day == current.day && date.year != current.year
    }
    
    // https://stackoverflow.com/a/48652058/17629371
    func messagesRelativeDate() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true

        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .medium
        } else if calendar.isDateInYesterday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .medium
        } else if calendar.compare(Date(), to: self, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self).weekday ?? 0
            return dateFormatter.weekdaySymbols[weekday - 1]
        } else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        }

        return dateFormatter.string(from: self)
    }
}
