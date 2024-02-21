//
//  Routable.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-22.
//

import Foundation

/// Conforming types can be added to `AnyNavigablePath`'s path.
protocol Routable: Hashable {
    /// - Parameter value: A data type for a given navigation destination. This value could be (but not limited to) some raw data, a view model, or an enum case (representing a route on a navigation path).
    /// - Returns: `nil` if data value cannot be mapped to a navigation route.
    static func makeRoute(
        _ value: some Hashable
    
        /// Generic error string
        static var makeRouteErrorString: String
    ) throws -> Self { get }
}

enum RoutableError<V: Hashable>: LocalizedError {
    case routeNotConfigured(value: V)
}

extension Routable {
    /// Default implementation.
    static func makeRoute(_ value: some Hashable) throws -> Self {
        switch value {
        case let value as Self:
            return value
        default:
            throw RoutableError.routeNotConfigured(value: value)
        }
    }
    
    static var makeRouteErrorString: String {
        "`makeRoute(...) implementation must return a valid route for all valid data values."
    }
}
