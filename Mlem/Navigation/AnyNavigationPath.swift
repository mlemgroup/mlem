//
//  AnyNavigationPath.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation
import SwiftUI

protocol AnyNavigationPath {
    
    /// The number of elements in this path.
    var count: Int { get }
    
    /// A Boolean that indicates whether this path is empty.
    var isEmpty: Bool { get }
    
    /// Appends a new value to the end of this path.
    mutating func append<V>(_ value: V) where V: Hashable
    
    // swiftlint:disable identifier_name
    /// Removes values from the end of this path.
    mutating func removeLast(_ k: Int)
    // swiftlint:enable identifier_name
}

extension NavigationPath: AnyNavigationPath {}
