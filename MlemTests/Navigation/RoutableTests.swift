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
    
    // MARK: - NavigationRoutes
    
    /// Passing in raw data value should return a valid route.
    /// Assert `(Data) –> Route`.
    func testNavigationRouteHandlesDataValue() throws {
        let value = CommunityLinkWithContext(community: nil, feedType: .all)
        let route = try AppRoute.makeRoute(value)
        XCTAssert(route == .communityLinkWithContext(value))
    }
    
    /// Passing in a route enum with an associated value should return the passed in value.
    func testNavigationRouteHandlesNonNestedAssociatedValueEnumCase() throws {
        let data = CommunityLinkWithContext(community: nil, feedType: .all)
        let value = AppRoute.communityLinkWithContext(data)
        let route = try AppRoute.makeRoute(value)
        XCTAssert(route == value)
    }
    
    // MARK: - SettingsRoutes
    
    /// Passing in a route enum with no associated value should return the passed in value.
    func testSettingsRouteHandlesNoAssociatedValueEnumCase() throws {
        let value = SettingsRoute.general
        let route = try SettingsRoute.makeRoute(value)
        XCTAssert(route == value)
    }
    
    /// Passing in a route enum with an associated value should return the passed in value.
    func testSettingsRouteHandlesNonNestedAssociatedValueEnumCase() throws {
        let value = SettingsRoute.aboutPage(.contributors)
        let route = try SettingsRoute.makeRoute(value)
        XCTAssert(route == value)
    }
    
    /// Passing in a route enum with an associated value that also has an associated value should return the passed in value.
    func testSettingsRouteHandlesNestedAssociatedValueEnumCase() throws {
        let nestedValue = Document(body: "Mock EULA")
        let value = SettingsRoute.aboutPage(.eula(nestedValue))
        let route = try SettingsRoute.makeRoute(value)
        XCTAssert(route == value)
    }
}
