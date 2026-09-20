//
//  Counter.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Actions
import Foundation

struct Counter: Identifiable {
    let id: UUID = .init()
    let value: Int?
    
    let leadingAction: ActionSeed?
    let trailingAction: ActionSeed?
    
    var appearance: CounterAppearance {
        .init(
            value: value,
            leading: leadingAction?.appearance,
            trailing: trailingAction?.appearance,
            label: "Unknown",
            singleIcon: ""
        )
    }
}
