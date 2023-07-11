//
//  Time Parser.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import Foundation

func getTimeIntervalFromNow(date: Date, unitsStyle: DateComponentsFormatter.UnitsStyle = .abbreviated) -> String {
    AppConstants.dateComponentsFormatter.unitsStyle = unitsStyle
    AppConstants.dateComponentsFormatter.maximumUnitCount = 1
    
    let interval = date.timeIntervalSinceNow
    if interval > -1 {
        return "Now"
    }
    
    let value = AppConstants.dateComponentsFormatter.string(from: abs(interval))
    return value ?? "Unknown"
}
