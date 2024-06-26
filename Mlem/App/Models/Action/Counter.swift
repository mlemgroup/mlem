//
//  Counter.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Foundation

struct Counter: Identifiable {
    let id: UUID = .init()
    let value: Int?
    
    let leadingAction: (any Action)?
    let trailingAction: (any Action)?
}
