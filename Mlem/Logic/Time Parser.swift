//
//  Time Parser.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import Foundation

func getTimeIntervalFromNow(originalTime: String) -> String {
    let timeFormatter = ISO8601DateFormatter()
    timeFormatter.formatOptions = [
        .withFractionalSeconds,
        .withFullDate,
        .withTime,
        .withColonSeparatorInTime,
        .withDashSeparatorInDate
    ]
    
    let convertedDate = timeFormatter.date(from: originalTime)
    
    let timeDifference = (convertedDate?.timeIntervalSinceNow)!
    
    let timeIntervalFormatter = DateComponentsFormatter()
    timeIntervalFormatter.unitsStyle = .abbreviated
    timeIntervalFormatter.maximumUnitCount = 1
    timeIntervalFormatter.zeroFormattingBehavior = .dropAll
    
    return timeIntervalFormatter.string(from: timeDifference)!
}
