//
//  SiteVersionTests.swift
//  MlemTests
//
//  Created by Sjmarf on 13/09/2023.
//

@testable import Mlem
import XCTest

final class SiteVersionTests: XCTestCase {
    
    func testStringInitializer() {
        // release
        XCTAssertEqual(SiteVersion("0.18.2"), .release(major: 0, minor: 18, patch: 2))
        // other
        XCTAssertEqual(SiteVersion("0.18.2.4"), .other("0.18.2.4"))
        XCTAssertEqual(SiteVersion("0.18"), .other("0.18"))
        XCTAssertEqual(SiteVersion("0.a.1"), .other("0.a.1"))
        XCTAssertEqual(SiteVersion("ab-cd"), .other("ab-cd"))
        XCTAssertEqual(SiteVersion("abc"), .other("abc"))
    }
    
    func testStringDescription() {
        // release
        XCTAssertEqual(
            SiteVersion.release(major: 0, minor: 18, patch: 2).description,
            "0.18.2"
        )
        // other
        XCTAssertEqual(
            SiteVersion.other("abc").description,
            "abc"
        )
    }
    
    func testComparisons() {
        XCTAssertTrue(SiteVersion.release(major: 0, minor: 0, patch: 0) < SiteVersion.release(major: 1, minor: 0, patch: 0))
        XCTAssertTrue(SiteVersion.release(major: 0, minor: 0, patch: 0) < SiteVersion.release(major: 0, minor: 1, patch: 0))
        XCTAssertTrue(SiteVersion.release(major: 0, minor: 0, patch: 0) < SiteVersion.release(major: 0, minor: 0, patch: 1))
        XCTAssertFalse(SiteVersion.release(major: 0, minor: 0, patch: 0) < SiteVersion.release(major: 0, minor: 0, patch: 0))
        XCTAssertFalse(SiteVersion.release(major: 1, minor: 0, patch: 0) < SiteVersion.release(major: 0, minor: 0, patch: 0))
        
        XCTAssertTrue(
            SiteVersion.release(major: 0, minor: 18, patch: 2)
            < SiteVersion.infinity
        )
        XCTAssertFalse(
            SiteVersion.infinity
            < SiteVersion.release(major: 0, minor: 18, patch: 2)
        )
        XCTAssertFalse(
            SiteVersion.release(major: 0, minor: 18, patch: 2)
            < SiteVersion.zero
        )
        XCTAssertTrue(
            SiteVersion.zero
            < SiteVersion.release(major: 0, minor: 18, patch: 2)
        )
        XCTAssertTrue(
            SiteVersion.zero
            < SiteVersion.infinity
        )
    }
}
