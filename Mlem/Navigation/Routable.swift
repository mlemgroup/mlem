//
//  Routable.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-22.
//

import Foundation

/// Conforming types can be added to a `NavigationRouter`'s path.
protocol Routable: Hashable {
    
    /// - Parameter value: A data type for a given navigation destination.
    static func makeRoute<V>(_ value: V) -> Self where V: Hashable
    
    /// Generic error string
    static var makeRouteErrorString: String { get }
}

extension Routable {
    
    /// Default implementation.
    static func makeRoute<V>(_ value: V) -> Self where V: Hashable {
        switch value {
        case let value as Self:
            return value
        default:
            fatalError(Self.makeRouteErrorString)
        }
    }
    
    static var makeRouteErrorString: String {
        "`makeRoute(...) implementation must return a valid route for all values."
    }
}
