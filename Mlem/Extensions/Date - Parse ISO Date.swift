//
//  Date - Parse ISO Date.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

extension DateFormatter
{
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }()
}
