//
//  AnotherTabItemLabelPrefKey.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-18.
//

import Foundation
import SwiftUI

struct AnotherTabItemLabelPrefKey: PreferenceKey {
    static var defaultValue: [AnotherTabItem: AnotherTabItemLabelBuilder] { [:] }
    
    static func reduce(value: inout [AnotherTabItem: AnotherTabItemLabelBuilder],
                       nextValue: () -> [AnotherTabItem: AnotherTabItemLabelBuilder]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct AnotherTabItemLabelBuilder: Equatable {
    let id: AnotherTabItem
    
    let label: () -> AnyView
    
    static func == (lhs: AnotherTabItemLabelBuilder, rhs: AnotherTabItemLabelBuilder) -> Bool {
        lhs.id == rhs.id
    }
}
