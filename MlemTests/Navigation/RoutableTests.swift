//
//  RoutableTests.swift
//  MlemTests
//
//  Created by Bosco Ho on 2023-09-25.
//

@testable import Mlem
import XCTest

final class RoutableTests: XCTestCase {
    private enum MockRoute: Routable {
        case routeA
        case routeB(Int)
        case routeC(MockNestedRoute)
    }
    
    private enum MockNestedRoute: Routable {
        case route1(Bool)
    }

    // MARK: - MockRoute
    
    func testMockRoute_handlesNoAssociatedValueEnumCase() throws {
        let value = MockRoute.routeA
        let route = try MockRoute.makeRoute(value)
        XCTAssert(route == value)
    }
    
    func testMockRoute_handlesNonNestedAssociatedValueEnumCase() throws {
        let data = 1
        let value = MockRoute.routeB(data)
        let route = try MockRoute.makeRoute(value)
        XCTAssert(route == value)
    }
    
    func testMockRoute_handlesNestedAssociatedValueEnumCase() throws {
        let data = true
        let value = MockRoute.routeC(.route1(data))
        let route = try MockRoute.makeRoute(value)
        XCTAssert(route == value)
    }
    
    func testMockRoute_handlesUnsupportedValue() throws {
        let value = "Mock Unsupported Value"
        XCTAssertThrowsError(try MockRoute.makeRoute(value))
    }
    
    func testMockRoute_handlesNestedUnsupportedValue() throws {
        let data = "Mock Unsupported Value"
        XCTAssertThrowsError(try MockRoute.routeC(.makeRoute(data)))
    }
}
