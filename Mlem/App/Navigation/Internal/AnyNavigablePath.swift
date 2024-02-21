//
//  AnyNavigablePath.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation
import SwiftUI

protocol AnyNavigablePath {
    associatedtype Route: Routable
    
    /// Implementation should make a route that makes sense for the passed-in data value and can be appended to the navigation path.
    static func makeRoute(
        _ value: some Hashable
    
        /// The number of elements in this path.
        var count: Int
    ) throws -> Route { get }
    
    /// A Boolean that indicates whether this path is empty.
    var isEmpty: Bool { get }
    
    /// Appends a new value to the end of this path.
    mutating func append<V>(_ value: V) where V: Routable
    
    // swiftlint:disable identifier_name
    /// Removes values from the end of this path.
    mutating func removeLast(_ k: Int)
    // swiftlint:enable identifier_name
}
