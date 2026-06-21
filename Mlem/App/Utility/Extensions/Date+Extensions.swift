//
//  Date+Extensions.swift
//  Mlem
//
//  Created by Jake Shirley on 6/22/23.
//

import SwiftUI

extension Date {
    /// Forges a localized `String` with inside the computed elapsed time between `self` and another `Date`.
    /// Uses a `RelativeDateTimeFormatter` and a given units style.
    ///
    /// For example, if the `self` is date 04/11/2023 and `date` is 15/05/2025, will return "1 year ago" (localized).
    ///
    /// - Parameters:
    ///    - date: The date to compare with `self`, by default `Date.now`
    ///    - unitsStyle: The style of the string to forge, by default `RelativeDateTimeFormatter.UnitsStyle.full`
    /// - Returns String: The localized string based.
    public func getRelativeTime(date: Date = .now, unitsStyle: RelativeDateTimeFormatter.UnitsStyle = .full) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = unitsStyle
        return formatter.localizedString(for: self, relativeTo: date)
    }

    /// Returns the current `Date` as a shorter version in `String`.
    /// For example if the date in the 5th of October 2023, returns "5/10/2023".
    /// Uses the current locale to let the `DateFormatter` apply the suitable date format depending to the user needs.
    public var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.gmt
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
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self,
            to: date
        ).roundingDownToMostSignificantComponent()

        let value = formatter.string(from: components)
        return value ?? String(localized: "Unknown")
    }
    
    var isAnniversaryToday: Bool {
        return isAnniversaryDate(.now)
    }

    func isAnniversaryDate(_ otherDate: Date) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.gmt
        let date = calendar.dateComponents([.month, .day, .year], from: self)
        let current = calendar.dateComponents([.month, .day, .year], from: otherDate)

        // Year component must be explicitly unwrapped for less than comparison
        guard let dateYear = date.year, let currentYear = current.year else { return false }

        // If our target day occurred in a leap year, adjust to Feb 28 if it
        // is being compared to a non leap year
        let targetDay: Int?
        if date.month == 2,
           date.day == 29,
           !otherDate.isLeapYear {
            targetDay = 28
        } else {
            targetDay = date.day
        }

        return date.month == current.month &&
        targetDay == current.day &&
        dateYear < currentYear
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

    var isLeapYear: Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.gmt
        let date = calendar.dateComponents([.year], from: self)
        guard let year = date.year else { return false }

        let isDivisible400 = year % 400 == 0
        let isDivisible100 = year % 100 == 0

        if isDivisible100 {
            return isDivisible400
        } else {
            return year % 4 == 0
        }
    }
}
