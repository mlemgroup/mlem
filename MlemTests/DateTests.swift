//
// Software Name: Mlem
// SPDX-FileCopyrightText: Copyright (c) Mlem Group
// SPDX-License-Identifier: GPL-3.0
//
// This software is distributed under the GNU General Public License v3.0 license,
// the text of which is available at https://www.gnu.org/licenses/gpl-3.0-standalone.html
// or see the "LICENSE" file for more details.
//

import SwiftUI
import Testing

/// Contains tests cases to check some `Date` extensions utils
struct DateTests {
    @Test(
        "Get relative time must return the localized expected elapsed time for not cake day and more than one year",
        .bug("https://github.com/mlemgroup/mlem/issues/2032")
    )
    func get_relative_time_returns_localized_string_for_more_than_one_year() {
        let dateFormatter = DateFormatter()
        var profileCreationDate: Date, someDate: Date

        // Given
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        profileCreationDate = dateFormatter.date(from: "2023-11-14 12:05:00 +0000")!
        dateFormatter.dateFormat = "dd/MM/yyyy"
        someDate = dateFormatter.date(from: "15/05/2025")!
        
        // When
        let relativeTimeString = profileCreationDate.getRelativeTime(date: someDate, unitsStyle: .full)
        
        // Then
        // NOTE: Supposed the language of the device / simulator under tests is english
        #expect(relativeTimeString == "1 year ago")
    }
    
    @Test("Shortered date must have same day, month and year")
    func shortered_date_must_have_same_day_month_and_year() {
        let dateFormatter = DateFormatter()
        var someDate: Date, shortered: Date
        var someDateComponents: DateComponents, shorteredComponents: DateComponents

        // Given
        dateFormatter.dateFormat = "dd/mm/yyyy"
        someDate = dateFormatter.date(from: "04/11/2023")!
        // When
        shortered = someDate.shortered
        // Then
        someDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: someDate)
        shorteredComponents = Calendar.current.dateComponents([.month, .day, .year], from: shortered)
        #expect(someDateComponents.day == shorteredComponents.day)
        #expect(someDateComponents.month == shorteredComponents.month)
        #expect(someDateComponents.year == shorteredComponents.year)
        
        // Given
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        someDate = dateFormatter.date(from: "2025-01-14 23:05:00 +0000")!
        // When
        shortered = someDate.shortered
        // Then
        someDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: someDate)
        shorteredComponents = Calendar.current.dateComponents([.month, .day, .year], from: shortered)
        #expect(someDateComponents.day == shorteredComponents.day)
        #expect(someDateComponents.month == shorteredComponents.month)
        #expect(someDateComponents.year == shorteredComponents.year)
    }
    
    @Test("Date string of some date must be in dd/mm/yyyy format")
    func date_string_must_be_in_ddmmyyy_format() {
        // Given
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let someDate = dateFormatter.date(from: "2023-11-04 10:05:00 +0000")!
        
        // When
        let dateString = someDate.dateString
        
        // Then
        #expect(dateString == "04/11/2023")
    }
}
