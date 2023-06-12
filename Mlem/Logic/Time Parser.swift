//
//  Time Parser.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import Foundation

func getTimeIntervalFromNow(date: Date) -> String
{
    AppConstants.relativeDateFormatter.dateTimeStyle = .numeric
    AppConstants.relativeDateFormatter.unitsStyle = .short
    AppConstants.relativeDateFormatter.formattingContext = .standalone
    AppConstants.relativeDateFormatter.calendar = .autoupdatingCurrent
    
    // Drop the last 4 characters, because all of these strings have "ago" (for example "3 hr ago"), and we don't want that "ago" to be there
    let value = String(AppConstants.relativeDateFormatter.localizedString(for: date, relativeTo: .now).dropLast(4))
    return value.hasPrefix("in") ? "now" : value
}
