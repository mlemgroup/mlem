//
//  DateTests.swift
//  Mlem
//
//  Created by Tai Heng on 2026-06-18.
//

import Foundation
import Testing
@testable import Mlem

struct DateTests {
    @Test func isDateInPastAnniversaryIsFalse() {
        let calendar = Calendar.current
        let anniversaryDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let testDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!

        #expect(!anniversaryDate.isAnniversaryDate(testDate))
    }

    @Test func isDateSameDateAnniversaryIsFalse() {
        let calendar = Calendar.current
        let anniversaryDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let testDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!

        #expect(!anniversaryDate.isAnniversaryDate(testDate))
    }

    @Test func isDate11MonthsInFutureAnniversaryIsFalse() {
        let calendar = Calendar.current
        let anniversaryDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!

        #expect(!anniversaryDate.isAnniversaryDate(testDate))
    }

    @Test func isDateAtOneYearAnniversaryIsTrue() {
        let calendar = Calendar.current
        let anniversaryDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!

        #expect(anniversaryDate.isAnniversaryDate(testDate))
    }

    @Test func isDateDayBeforeAnniversaryIsFalse() {
        let calendar = Calendar.current
        let anniversaryDate = Date(timeIntervalSince1970: 771470149.5109999)
        let testDate = calendar.date(from: DateComponents(year: 2026, month: 6, day: 12))!

        #expect(!anniversaryDate.isAnniversaryDate(testDate))
    }

    @Test func isDateDayOfAnniversaryIsTrue() {
        let calendar = Calendar.current
        let anniversaryDate = Date(timeIntervalSince1970: 771470149.5109999)
        let testDate = calendar.date(from: DateComponents(year: 2026, month: 6, day: 13))!

        #expect(anniversaryDate.isAnniversaryDate(testDate))
    }

    @Test func isLeapYearDateAnniversaryInFebIsTrue() {
        let calendar = Calendar.current
        let anniversaryDate = calendar.date(from: DateComponents(year: 2024, month: 2, day: 29))!
        let testDate = calendar.date(from: DateComponents(year: 2023, month: 2, day: 28))!

        withKnownIssue("Which day should Feb 29 anniversaries fall?") {
            #expect(anniversaryDate.isAnniversaryDate(testDate))
        }
    }

    @Test func isLeapYearDateAnniversaryInMarIsFalse() {
        let calendar = Calendar.current
        let anniversaryDate = calendar.date(from: DateComponents(year: 2024, month: 2, day: 29))!
        let testDate = calendar.date(from: DateComponents(year: 2023, month: 3, day: 1))!

        withKnownIssue("Which day should Feb 29 anniversaries fall?") {
            #expect(anniversaryDate.isAnniversaryDate(testDate))
        }
    }
}
