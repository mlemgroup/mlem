//
//  Array+Prepend.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import Foundation

public extension Array {
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
    
    mutating func sortedInsert(_ newElement: Element, for predicate: (Element) -> Bool) {
        insert(newElement, at: insertionIndex(for: predicate))
    }
    
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}
