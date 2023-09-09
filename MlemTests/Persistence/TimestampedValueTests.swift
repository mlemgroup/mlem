//
//  TimestampedValueTests.swift
//  MlemTests
//
//  Created by mormaer on 28/08/2023.
//
//

@testable import Mlem

import Dependencies
import XCTest

final class TimestampedValueTests: XCTestCase {
    
    func testValueIdentifiesAsStaleCorrectly() throws {
        let model = model(
            value: "stale",
            timestamp: .init(timeIntervalSince1970: 1234567800), // Fri Feb 13 2009 23:30:00 GMT+0000
            lifespan: .minutes(1)
        )

        // expectation is data will be stale, as stored 1m30s before 'now' with a lifespan of 1 minute
        XCTAssert(model.isStale)
    }
    
    func testValueIdentifiesAsNotStaleCorrectly() throws {
        let model = model(
            value: "fresh",
            timestamp: .init(timeIntervalSince1970: 1234567800), // Fri Feb 13 2009 23:30:00 GMT+0000
            lifespan: .minutes(2)
        )
        
        // expectation is data will _not_ be stale, as stored 1m30s before 'now' with a lifespan of 2 minutes
        XCTAssertFalse(model.isStale)
    }
    
    // MARK: - Helpers
    
    func model<T>(value: T, timestamp: Date, lifespan: TimeInterval) -> TimestampedValue<T> {
        return withDependencies {
            $0.date.now = .init(timeIntervalSince1970: 1234567890) // Fri Feb 13 2009 23:31:30 GMT+0000
        } operation: {
            TimestampedValue(value: value, timestamp: timestamp, lifespan: lifespan)
        }
    }
}
