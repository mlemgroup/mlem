//
//  CounterAppearance.swift
//  Mlem
//
//  Created by Sjmarf on 17/08/2024.
//

import Actions
import Foundation
import Icons

struct CounterAppearance {
    let value: Int?
    let leading: ActionAppearance?
    let trailing: ActionAppearance?
    let label: LocalizedStringResource
    let singleIcon: Icon
}
