//
//  Array+SafeIndexing.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-29.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}
