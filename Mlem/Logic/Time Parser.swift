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
    
    AppConstants.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    
    convertedDate = AppConstants.dateFormatter.date(from: responseDate)
    
    if convertedDate == nil /// Sometimes, the API returns a different date format. If that happens, try the alternative formatter
    {
        AppConstants.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        convertedDate = AppConstants.dateFormatter.date(from: responseDate)
    }
    
    #warning("TODO: Remove this in favor of figuring out WTF is crashing it")
    if convertedDate == nil
    {
        convertedDate = Date()
    }
    
    return convertedDate!
}

func getTimeIntervalFromNow(date: Date) -> String
{
    AppConstants.relativeDateFormatter.dateTimeStyle = .numeric
    AppConstants.relativeDateFormatter.unitsStyle = .short
    AppConstants.relativeDateFormatter.formattingContext = .standalone
    
    return String(AppConstants.relativeDateFormatter.localizedString(for: date, relativeTo: .now).dropLast(4)) /// Drop the last 4 characters, because all of these strings have "ago" (for example "3 hr ago"), and we don't want that "ago" to be there
}
