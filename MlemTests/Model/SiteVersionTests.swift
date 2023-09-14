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
        // suffixed
        XCTAssertEqual(SiteVersion("0.18.2-beta.2"), .suffixed(major: 0, minor: 18, patch: 2, suffix: .beta(2)))
        XCTAssertEqual(SiteVersion("0.18.2-rc.2"), .suffixed(major: 0, minor: 18, patch: 2, suffix: .releaseCandidate(2)))
        XCTAssertEqual(SiteVersion("0.18.2-kt.2"), .suffixed(major: 0, minor: 18, patch: 2, suffix: .other("kt", 2)))
        XCTAssertEqual(SiteVersion("0.18.2-kt"), .suffixed(major: 0, minor: 18, patch: 2, suffix: .other("kt")))
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
        // suffixed
        XCTAssertEqual(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .beta(2)).description,
            "0.18.2-beta.2"
        )
        XCTAssertEqual(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .releaseCandidate(2)).description,
            "0.18.2-rc.2"
        )
        XCTAssertEqual(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("kt", 2)).description,
            "0.18.2-kt.2"
        )
        XCTAssertEqual(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("kt")).description,
            "0.18.2-kt"
        )
        // other
        XCTAssertEqual(
            SiteVersion.other("abc").description,
            "abc"
        )
    }
    
    // swiftlint:disable function_body_length
    func testComparisons() {
        // release
        XCTAssertTrue(SiteVersion.release(major: 0, minor: 0, patch: 0) < SiteVersion.release(major: 1, minor: 0, patch: 0))
        XCTAssertTrue(SiteVersion.release(major: 0, minor: 0, patch: 0) < SiteVersion.release(major: 0, minor: 1, patch: 0))
        XCTAssertTrue(SiteVersion.release(major: 0, minor: 0, patch: 0) < SiteVersion.release(major: 0, minor: 0, patch: 1))
        XCTAssertFalse(SiteVersion.release(major: 0, minor: 0, patch: 0) < SiteVersion.release(major: 0, minor: 0, patch: 0))
        XCTAssertFalse(SiteVersion.release(major: 1, minor: 0, patch: 0) < SiteVersion.release(major: 0, minor: 0, patch: 0))
        // suffixed
        XCTAssertTrue(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .beta(1))
            < SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .beta(2))
        )
        XCTAssertFalse(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .beta(2))
            < SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .beta(1))
        )
        XCTAssertTrue(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .beta(5))
            < SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .releaseCandidate(1))
        )
        XCTAssertTrue(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .beta(1))
            < SiteVersion.release(major: 0, minor: 18, patch: 2)
        )
        XCTAssertTrue(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .releaseCandidate(5))
            < SiteVersion.release(major: 0, minor: 18, patch: 2)
        )
        XCTAssertTrue(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .releaseCandidate(5))
            < SiteVersion.release(major: 0, minor: 18, patch: 3)
        )
        XCTAssertFalse(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .releaseCandidate(5))
            < SiteVersion.release(major: 0, minor: 18, patch: 1)
        )
        XCTAssertFalse(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("test"))
            < SiteVersion.release(major: 0, minor: 18, patch: 2)
        )
        XCTAssertTrue(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("test"))
            < SiteVersion.release(major: 0, minor: 18, patch: 3)
        )
        XCTAssertTrue(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("test", 1))
            < SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("test", 2))
        )
        XCTAssertFalse(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("test", 2))
            < SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("test", 1))
        )
        XCTAssertFalse(
            SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("abc", 1))
            < SiteVersion.suffixed(major: 0, minor: 18, patch: 2, suffix: .other("test", 2))
        )
    }
    // swiftlint:enable function_body_length
}
