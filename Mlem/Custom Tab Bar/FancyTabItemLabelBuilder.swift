//
//  FancyTabItemPreferenceKey.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

// preference key--this lets each view add itself to the map in FancyTabBar
struct FancyTabItemLabelBuilderPreferenceKey<Selection: Hashable>: PreferenceKey {
    static var defaultValue: [Selection: FancyTabItemLabelBuilder<Selection>] { [:] }
    
    static func reduce(
        value: inout [Selection: FancyTabItemLabelBuilder<Selection>],
        nextValue: () -> [Selection: FancyTabItemLabelBuilder<Selection>]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// preference key--this lets each view add itself to the list of keys
struct FancyTabItemPreferenceKey<Selection: Hashable>: PreferenceKey {
    static var defaultValue: [Selection] { [] }

    static func reduce(value: inout [Selection], nextValue: () -> [Selection]) {
        value.append(contentsOf: nextValue())
    }
}

struct FancyTabItemLabelBuilder<Selection: Hashable>: Hashable, Equatable {
    let tag: Selection
    let label: (_: Bool?) -> AnyView
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }
    
    static func == (lhs: FancyTabItemLabelBuilder, rhs: FancyTabItemLabelBuilder) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
