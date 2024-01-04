//
//  Date+RelativeTime.swift
//  Mlem
//
//  Created by Jake Shirley on 6/22/23.
//

import SwiftUI

extension Date {
    // Returns strings like "3 seconds ago" and "10 days ago"
    func getRelativeTime(date: Date, unitsStyle: RelativeDateTimeFormatter.UnitsStyle = .full) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = unitsStyle

        return formatter.localizedString(for: self, relativeTo: date)
    }
}
