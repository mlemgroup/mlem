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
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMYY", options: 0, locale: Locale.current)
        return dateFormatter.string(from: self)
    }
}
