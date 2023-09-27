//
//  RoutableTests.swift
//  MlemTests
//
//  Created by Bosco Ho on 2023-09-25.
//

@testable import Mlem
import XCTest

final class RoutableTests: XCTestCase {
    
    // MARK: - AppRoutes
    
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
}
