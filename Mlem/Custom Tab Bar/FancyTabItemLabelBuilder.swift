//
//  FancyTabItemPreferenceKey.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

struct FancyTabItemLabelBuilder<Selection: FancyTabBarSelection>: Hashable, Equatable {
    let tag: Selection
    let label: () -> AnyView
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }
    
    static func == (lhs: FancyTabItemLabelBuilder, rhs: FancyTabItemLabelBuilder) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
