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
    
        let value = formatter.string(from: interval)
        return value ?? String(localized: "Unknown")
    }
    
    var isAnniversaryToday: Bool {
        let calendar = Calendar.current
        let date = calendar.dateComponents([.month, .day], from: self)
        let current = calendar.dateComponents([.month, .day], from: .now)
        return date.month == current.month && date.day == current.day && date.year != current.year
    }
}
