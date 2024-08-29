//
//  Calendar+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-29.
//

import Foundation

extension Calendar {
    func daysSince(_ from: Date) -> Int? {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: Date.now)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day
    }
}
