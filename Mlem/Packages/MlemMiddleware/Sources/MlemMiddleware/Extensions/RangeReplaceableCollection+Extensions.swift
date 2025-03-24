//
//  RangeReplaceableCollection+Extensions.swift
//
//
//  Created by Sjmarf on 11/05/2024.
//

import Foundation

extension RangeReplaceableCollection {
    @discardableResult
    mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: predicate) else { return nil }
        return remove(at: index)
    }
}
