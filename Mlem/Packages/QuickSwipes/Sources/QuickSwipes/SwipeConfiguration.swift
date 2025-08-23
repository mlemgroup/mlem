//
//  SwipeConfiguration.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-11.
//

import Foundation

public struct SwipeConfiguration {
    /// In ascending order of appearance.
    public let leadingActions: [QuickSwipeAction]
    /// In ascending order of appearance.
    public let trailingActions: [QuickSwipeAction]
    
    public init(
        leadingActions: [QuickSwipeAction] = [],
        trailingActions: [QuickSwipeAction] = []
    ) {
        assert(
            leadingActions.count <= 3 && trailingActions.count <= 3,
            "Too many swipe actions!"
        )
        
        self.leadingActions = leadingActions.filter(\.enabled)
        self.trailingActions = trailingActions.filter(\.enabled)
    }
}
