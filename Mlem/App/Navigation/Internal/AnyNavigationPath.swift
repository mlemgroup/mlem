//
//  AnyNavigationPath.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation

/// For when the system `NavigationPath` doesn't meet your needs.
///
/// Technical Note:
/// - [2023.09] Initially, enum-based navigation routes were added during the development of tab-bar navigation. When using the system `NavigationPath`, the UI would exhibit a bug where views would randomly push onto view without any animations, after which the navigation path became corrupt, making programmatic navigation unreliable. Using enum-based navigation routes with custom navigation paths resulted in this issue disappearing on both iOS 16/17.
final class AnyNavigationPath<RouteValue: Routable>: ObservableObject {
    /// - Avoid directly manipulating this value, if alternate methods are provided.
    @Published var path: [RouteValue] = []
}
 
extension AnyNavigationPath: AnyNavigablePath {
    typealias Route = RouteValue
    
    static func makeRoute(_ value: some Hashable) throws -> Route {
        try RouteValue.makeRoute(value)
    }
    
    var count: Int {
        path.count
    }
    
    var isEmpty: Bool {
        path.isEmpty
    }
    
    func append(_ value: some Routable) {
        guard let route = value as? Route else {
            assert(value is Route)
            return
        }
        path.append(route)
    }
    
    // swiftlint:disable identifier_name
    func removeLast(_ k: Int = 1) {
        path.removeLast(k)
    }
    // swiftlint:enable identifier_name
}
