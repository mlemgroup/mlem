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

/// Contains tests cases to check some `Date` extensions utils.
/// NOTE: Supposed the language of the device / simulator under tests is english
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
        #expect(relativeTimeString == "1 year ago")
    }
    
    @Test("Get relative time must return the elapsed days for accounts of several days old")
    func get_relative_time_must_return_elapsed_days_for_accounts_of_several_days_old() {
        let dateFormatter = DateFormatter()
        var profileCreationDate: Date, profileCreationDateABitLater: Date

        // Given
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        profileCreationDate = dateFormatter.date(from: "2025-05-16 12:05:00 +0000")!
        profileCreationDateABitLater = dateFormatter.date(from: "2025-05-20 15:30:22 +0000")!
        
        // When
        let relativeTimeString = profileCreationDate.getRelativeTime(date: profileCreationDateABitLater, unitsStyle: .full)
        
        // Then
        #expect(relativeTimeString == "4 days ago")
    }

    @Test("Get relative time must return the elapsed weeks for accounts of several weeks old")
    func get_relative_time_must_return_elapsed_days_for_accounts_of_several_weeks_old() {
        let dateFormatter = DateFormatter()
        var profileCreationDate: Date, profileCreationDateABitLater: Date

        // Given
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        profileCreationDate = dateFormatter.date(from: "2025-05-01 12:05:00 +0000")!
        profileCreationDateABitLater = dateFormatter.date(from: "2025-05-15 15:30:22 +0000")!
        
        // When
        let relativeTimeString = profileCreationDate.getRelativeTime(date: profileCreationDateABitLater, unitsStyle: .full)
        
        // Then
        #expect(relativeTimeString == "2 weeks ago")
    }

    @Test("Get relative time must return the elapsed months for accounts of several months old")
    func get_relative_time_must_return_elapsed_months_for_accounts_of_several_months_old() {
        let dateFormatter = DateFormatter()
        var profileCreationDate: Date, profileCreationDateABitLater: Date

        // Given
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        profileCreationDate = dateFormatter.date(from: "2025-05-16 12:05:00 +0000")!
        profileCreationDateABitLater = dateFormatter.date(from: "2025-12-16 15:30:22 +0000")!
        
        // When
        let relativeTimeString = profileCreationDate.getRelativeTime(date: profileCreationDateABitLater, unitsStyle: .full)
        
        // Then
        #expect(relativeTimeString == "7 months ago")
    }
    
    @Test("Get relative time must return the elapsed hours for accounts younger than one day but older than one hour")
    func get_relative_time_must_return_elapsed_hours_for_accounts_of_several_hours_old() {
        let dateFormatter = DateFormatter()
        var profileCreationDate: Date, profileCreationDateABitLater: Date

        // Given
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        profileCreationDate = dateFormatter.date(from: "2025-05-16 12:05:00 +0000")!
        profileCreationDateABitLater = dateFormatter.date(from: "2025-05-16 15:30:22 +0000")!
        
        // When
        let relativeTimeString = profileCreationDate.getRelativeTime(date: profileCreationDateABitLater, unitsStyle: .full)
        
        // Then
        #expect(relativeTimeString == "3 hours ago")
    }

    @Test("Get relative time must return the elapsed minutes for accounts younger than one hour")
    func get_relative_time_must_return_elapsed_hours_for_accounts_of_less_one_hour_old() {
        let dateFormatter = DateFormatter()
        var profileCreationDate: Date, profileCreationDateABitLater: Date

        // Given
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        profileCreationDate = dateFormatter.date(from: "2025-05-16 12:05:00 +0000")!
        profileCreationDateABitLater = dateFormatter.date(from: "2025-05-16 12:30:22 +0000")!
        
        // When
        let relativeTimeString = profileCreationDate.getRelativeTime(date: profileCreationDateABitLater, unitsStyle: .full)

        // Then
        #expect(relativeTimeString == "25 minutes ago")
    }

    @Test("Get relative time must return the elapsed seconds for accounts of some seconds old")
    func get_relative_time_must_return_elapsed_seconds_for_accounts_of_some_seconds_old() {
        let dateFormatter = DateFormatter()
        var profileCreationDate: Date, profileCreationDateABitLater: Date

        // Given
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        profileCreationDate = dateFormatter.date(from: "2025-05-16 12:05:00 +0000")!
        profileCreationDateABitLater = dateFormatter.date(from: "2025-05-16 12:05:42 +0000")!
        
        // When
        let relativeTimeString = profileCreationDate.getRelativeTime(date: profileCreationDateABitLater, unitsStyle: .full)

        // Then
        #expect(relativeTimeString == "42 seconds ago")
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
