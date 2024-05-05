//
//  Date+DaysFromNow.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-16.
//

import Foundation

extension Date {
    static func getEpochDate(daysFromNow: Int) -> Int {
        let targetDate = Date.now.advanced(by: .days(Double(daysFromNow)))
        return Int(targetDate.timeIntervalSince1970)
    }
}
