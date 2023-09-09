//
//  NavigationRouter.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation

final class NavigationRouter: ObservableObject {
    @Published var routes: [NavigationRoute] = []
}

extension NavigationRouter: AnyNavigationPath {
    var count: Int {
        routes.count
    }
    
    var isEmpty: Bool {
        routes.isEmpty
    }
    
    func append<V>(_ value: V) where V: Hashable {
        assert(value is NavigationRoute)
        guard let route = value as? NavigationRoute else {
            return
        }
        routes.append(route)
    }
    
    // swiftlint:disable identifier_name
    func removeLast(_ k: Int = 1) {
        routes.removeLast(k)
    }
    // swiftlint:enable identifier_name
}
