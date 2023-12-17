//
//  Array+Prepend.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import Foundation

extension Array {
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
}
