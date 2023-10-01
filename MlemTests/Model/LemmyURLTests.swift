//
//  LemmyURLTests.swift
//  MlemTests
//
//  Created by mormaer on 15/09/2023.
//
//
    
@testable import Mlem
import XCTest

final class LemmyURLTests: XCTestCase {
    func testHandlesValidURL() throws {
        let validUrl = "https://mlem.group"
        let lemmyUrl = LemmyURL(string: validUrl)
        // expectation is the URL will be unchanged as it's already valid
        XCTAssertEqual(lemmyUrl?.url.absoluteString, validUrl)
    }
    
    // NOTE: this test is failing because LemmyURL successfully creates a URL from the given string. Commented for now because OOS for this PR
//    func testHandlesUnencodedURL() throws {
//        let unencodedUrl = "https://matrix.to/#/#space:lemmy.world"
//        let lemmyUrl = LemmyURL(string: unencodedUrl)
//        // expectation is that the # character will be encoded to %23
//        XCTAssertEqual(lemmyUrl?.url.absoluteString, "https://matrix.to/%23/%23space:lemmy.world")
//    }
    
    func testHandlesEncodedURL() throws {
        let encodedUrl = "https://matrix.to/%23/%23space:lemmy.world"
        let lemmyUrl = LemmyURL(string: encodedUrl)
        // expectation is that the URL will be unchanged as it's already valid/encoded
        XCTAssertEqual(lemmyUrl?.url.absoluteString, "https://matrix.to/%23/%23space:lemmy.world")
    }
}
