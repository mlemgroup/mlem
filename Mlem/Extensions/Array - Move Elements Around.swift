//
//  Array - Move Elements Around.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import Foundation

extension Array where Element: Equatable {
    mutating func move(_ element: Element, to newIndex: Index) {
        if let oldIndex: Int = firstIndex(of: element) { move(from: oldIndex, to: newIndex) }
    }
}

extension Array {
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        // Don't work for free and use swap when indices are next to each other - this
        // won't rebuild array and will be super efficient.
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return swapAt(oldIndex, newIndex) }
        insert(remove(at: oldIndex), at: newIndex)
    }
}
