//
//  NavigationRouter.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation

final class NavigationRouter<Route: Hashable>: ObservableObject {
    @Published var path: [Route] = []
}

extension NavigationRouter: AnyNavigationPath {
    var count: Int {
        path.count
    }
    
    var isEmpty: Bool {
        path.isEmpty
    }
    
    func append<V>(_ value: V) where V: Hashable {
        assert(value is Route)
        guard let route = value as? Route else {
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
