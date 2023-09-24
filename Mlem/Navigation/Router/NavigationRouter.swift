//
//  NavigationRouter.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation

final class NavigationRouter<RouteValue: Routable>: ObservableObject {
    
    /// - Avoid directly manipulating this value, if alternate methods are provided.
    @Published var path: [RouteValue] = []
    
}
 
extension NavigationRouter: AnyNavigationPath {

    typealias Route = RouteValue
    
    static func makeRoute<V>(_ value: V) -> Route? where V: Hashable {
        RouteValue.makeRoute(value) ?? nil
    }
    
    var count: Int {
        path.count
    }
    
    var isEmpty: Bool {
        path.isEmpty
    }
    
    func append<V>(_ value: V) where V: Routable {
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
