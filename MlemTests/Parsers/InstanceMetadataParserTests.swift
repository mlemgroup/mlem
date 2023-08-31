//
//  InstanceMetadataParserTests.swift
//  MlemTests
//
//  Created by mormaer on 31/08/2023.
//
//

@testable import Mlem
import XCTest

final class InstanceMetadataParserTests: XCTestCase {
    func testParserHandlesExpectedData() throws {
        // construct some test data
        let data = """
        Instance,NU,NC,Fed,Adult,↓V,Users,BI,BB,UT,MO,Version
        [Lemmy.world](https://lemmy.world),Yes,Yes,Yes,Yes,Yes,18431,53,3,97%,2,0.18.4
        [lemm.ee](https://lemm.ee),Yes,No,Yes,No,Yes,3710,34,0,100%,2,0.1.2
        """.data(using: .utf8)!
        
        // ask the parser to parse it
        let metadata = try InstanceMetadataParser.parse(from: data)
        
        // assert we got the expected values back
        XCTAssert(metadata.count == 2)
        
        // assert the first one parsed correctly...
        let lemmyWorldInstance = metadata[0]
        XCTAssert(lemmyWorldInstance.name == "Lemmy.world")
        XCTAssert(lemmyWorldInstance.url == URL(string: "https://lemmy.world")!)
        XCTAssertTrue(lemmyWorldInstance.newUsers)
        XCTAssertTrue(lemmyWorldInstance.newCommunities)
        XCTAssertTrue(lemmyWorldInstance.federated)
        XCTAssertTrue(lemmyWorldInstance.adult)
        XCTAssertTrue(lemmyWorldInstance.downvotes)
        XCTAssert(lemmyWorldInstance.users == 18431)
        XCTAssert(lemmyWorldInstance.blocking == 53)
        XCTAssert(lemmyWorldInstance.blockedBy == 3)
        XCTAssert(lemmyWorldInstance.uptime == "97%")
        XCTAssert(lemmyWorldInstance.version == "0.18.4")
        
        // assert the second worked too...
        let lemmeeInstance = metadata[1]
        XCTAssert(lemmeeInstance.name == "lemm.ee")
        XCTAssert(lemmeeInstance.url == URL(string: "https://lemm.ee")!)
        XCTAssertTrue(lemmeeInstance.newUsers)
        XCTAssertFalse(lemmeeInstance.newCommunities)
        XCTAssertTrue(lemmeeInstance.federated)
        XCTAssertFalse(lemmeeInstance.adult)
        XCTAssertTrue(lemmeeInstance.downvotes)
        XCTAssert(lemmeeInstance.users == 3710)
        XCTAssert(lemmeeInstance.blocking == 34)
        XCTAssert(lemmeeInstance.blockedBy == 0)
        XCTAssert(lemmeeInstance.uptime == "100%")
        XCTAssert(lemmeeInstance.version == "0.1.2")
    }
    
    func testParserIsNotReliantOnHeaderFieldOrder() throws {
        // construct some test data with some the fields moved around
        let data = """
        Users,NU,NC,Fed,Version,Adult,↓V,BI,BB,UT,MO,Instance
        18431,Yes,Yes,Yes,0.18.4,Yes,Yes,53,3,97%,2,[Lemmy.world](https://lemmy.world)
        3710,Yes,No,Yes,0.1.2,No,Yes,34,0,100%,2,[lemm.ee](https://lemm.ee)
        """.data(using: .utf8)!
        
        // ask the parser to parse it
        let metadata = try InstanceMetadataParser.parse(from: data)
        
        // assert we got the expected values back
        XCTAssert(metadata.count == 2)
        
        // assert the first one parsed correctly despite the changed header order...
        let lemmyWorldInstance = metadata[0]
        XCTAssert(lemmyWorldInstance.name == "Lemmy.world")
        XCTAssert(lemmyWorldInstance.url == URL(string: "https://lemmy.world")!)
        XCTAssertTrue(lemmyWorldInstance.newUsers)
        XCTAssertTrue(lemmyWorldInstance.newCommunities)
        XCTAssertTrue(lemmyWorldInstance.federated)
        XCTAssertTrue(lemmyWorldInstance.adult)
        XCTAssertTrue(lemmyWorldInstance.downvotes)
        XCTAssert(lemmyWorldInstance.users == 18431)
        XCTAssert(lemmyWorldInstance.blocking == 53)
        XCTAssert(lemmyWorldInstance.blockedBy == 3)
        XCTAssert(lemmyWorldInstance.uptime == "97%")
        XCTAssert(lemmyWorldInstance.version == "0.18.4")
        
        // assert the second worked too...
        let lemmeeInstance = metadata[1]
        XCTAssert(lemmeeInstance.name == "lemm.ee")
        XCTAssert(lemmeeInstance.url == URL(string: "https://lemm.ee")!)
        XCTAssertTrue(lemmeeInstance.newUsers)
        XCTAssertFalse(lemmeeInstance.newCommunities)
        XCTAssertTrue(lemmeeInstance.federated)
        XCTAssertFalse(lemmeeInstance.adult)
        XCTAssertTrue(lemmeeInstance.downvotes)
        XCTAssert(lemmeeInstance.users == 3710)
        XCTAssert(lemmeeInstance.blocking == 34)
        XCTAssert(lemmeeInstance.blockedBy == 0)
        XCTAssert(lemmeeInstance.uptime == "100%")
        XCTAssert(lemmeeInstance.version == "0.1.2")
    }
}
