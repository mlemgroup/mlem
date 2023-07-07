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
    
    let value = AppConstants.dateComponentsFormatter.string(from: abs(date.timeIntervalSinceNow))
    return value ?? "Unknown"
}
