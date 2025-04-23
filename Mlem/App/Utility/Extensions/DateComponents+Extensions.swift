//
//  DateComponents+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-04-22.
//

import Foundation

extension DateComponents {
    // This is used to fix #1988
    func roundingDownToMostSignificantComponent() -> DateComponents {
        if let year, year >= 1 { return .init(year: year) }
        if let month, month >= 1 { return .init(month: month) }
        if let day, day >= 1 { return .init(day: day) }
        if let hour, hour >= 1 { return .init(hour: hour) }
        if let minute, minute >= 1 { return .init(minute: minute) }
        return self
    }
}
