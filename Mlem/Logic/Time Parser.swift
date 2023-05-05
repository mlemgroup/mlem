//
//  Time Parser.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import Foundation

func convertResponseDateToDate(responseDate: String) -> Date
{
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    
    return dateFormatter.date(from: responseDate)!
}

func getTimeIntervalFromNow(date: Date) -> String
{
    let dateFormatter: RelativeDateTimeFormatter = RelativeDateTimeFormatter()
    dateFormatter.dateTimeStyle = .named
    dateFormatter.unitsStyle = .short
    dateFormatter.formattingContext = .standalone
    
    return String(dateFormatter.localizedString(for: date, relativeTo: .now).dropLast(4)) /// Drop the last 4 characters, because all of these strings have "ago" (for example "3 hr ago"), and we don't want that "ago" to be there
}
