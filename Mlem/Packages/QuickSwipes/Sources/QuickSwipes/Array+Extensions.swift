//
//  File.swift
//  QuickSwipes
//
//  Created by Sjmarf on 2025-08-23.
//

import Foundation

extension Array {
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}
