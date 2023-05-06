//
//  Time Parser.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import Foundation

func convertResponseDateToDate(responseDate: String) -> Date
{
    var convertedDate: Date?
    
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    
    convertedDate = dateFormatter.date(from: responseDate)
    
    if convertedDate == nil /// Sometimes, the API returns a different date format. If that happens, try the alternative formatter
    {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        convertedDate = dateFormatter.date(from: responseDate)
    }
    
    return convertedDate!
}

func getTimeIntervalFromNow(date: Date) -> String
{
    let dateFormatter: RelativeDateTimeFormatter = RelativeDateTimeFormatter()
    dateFormatter.dateTimeStyle = .named
    dateFormatter.unitsStyle = .short
    dateFormatter.formattingContext = .standalone
    
    return String(dateFormatter.localizedString(for: date, relativeTo: .now).dropLast(4)) /// Drop the last 4 characters, because all of these strings have "ago" (for example "3 hr ago"), and we don't want that "ago" to be there
}
