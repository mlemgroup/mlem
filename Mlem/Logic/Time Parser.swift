//
//  Time Parser.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import Foundation

func getTimeIntervalFromNow(date: Date, unitsStyle: RelativeDateTimeFormatter.UnitsStyle = .abbreviated) -> String {
    AppConstants.relativeDateFormatter.unitsStyle = unitsStyle
    return AppConstants.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
}
