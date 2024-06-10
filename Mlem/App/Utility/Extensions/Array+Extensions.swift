//
//  Array+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-10.
//

import Foundation

public extension Array {
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}
