//
//  FancyTabItemPreferenceKeys.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-18.
//

import Foundation
import SwiftUI

// preference key--this lets each view add itself an its label builder to the map in FancyTabBar
struct FancyTabItemLabelBuilderPreferenceKey<Selection: FancyTabBarSelection>: PreferenceKey {
    static var defaultValue: [Selection: FancyTabItemLabelBuilder<Selection>] { [:] }
    
    static func reduce(
        value: inout [Selection: FancyTabItemLabelBuilder<Selection>],
        nextValue: () -> [Selection: FancyTabItemLabelBuilder<Selection>]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// preference key--this lets each view add itself to the list of keys
struct FancyTabItemPreferenceKey<Selection: FancyTabBarSelection>: PreferenceKey {
    static var defaultValue: [Selection] { [] }

    static func reduce(value: inout [Selection], nextValue: () -> [Selection]) {
        value.append(contentsOf: nextValue())
        value.sort() // preserve stability of view order
    }
}
