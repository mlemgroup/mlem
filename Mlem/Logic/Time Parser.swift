//
//  Time Parser.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import Foundation

func getTimeIntervalFromNow(originalTime: String) -> String
{
    let timeFormatter = ISO8601DateFormatter()
    timeFormatter.formatOptions = [
        .withFractionalSeconds,
        .withFullDate,
        .withTime,
        .withColonSeparatorInTime,
        .withDashSeparatorInDate,
    ] // Setting up the formatter

    let convertedDate = timeFormatter.date(from: originalTime) // Convert the string to a date

    let timeDifference = (convertedDate?.timeIntervalSinceNow)! // Get the time difference between now and the date gotten from the API

    let timeIntervalFormatter = DateComponentsFormatter() // Now that we know the difference, we now have to say how we want it displayed
    timeIntervalFormatter.unitsStyle = .abbreviated // One-letter units
    timeIntervalFormatter.maximumUnitCount = 1 // Only display one unit
    timeIntervalFormatter.zeroFormattingBehavior = .dropAll // Drop whenever we pass in a zero

    var finalDateAsString = timeIntervalFormatter.string(from: timeDifference)! // Convert the difference to string
    finalDateAsString.remove(at: finalDateAsString.startIndex) // Remove the first letter of the string, because it returns everything with a minus at the beginning of the string
    // TODO: See if I can somehow skip this step

    return finalDateAsString
}
