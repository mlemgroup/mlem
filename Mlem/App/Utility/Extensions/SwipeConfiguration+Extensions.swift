//
//  SwipeConfiguration+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-22.
//

import Foundation
import QuickSwipes

extension SwipeConfiguration {
    // Prevents ambiguous init declaration
    init() {
        self.init(leadingActions: [QuickSwipeAction](), trailingActions: [QuickSwipeAction]())
    }
    
    init(
        leadingActions: [any Action] = [],
        trailingActions: [any Action] = []
    ) {
        self.init(
            leadingActions: leadingActions.compactMap(QuickSwipeAction.init),
            trailingActions: trailingActions.compactMap(QuickSwipeAction.init)
        )
    }
    
    init(
        @ActionBuilder leadingActions: () -> [any Action] = { [] },
        @ActionBuilder trailingActions: () -> [any Action] = { [] }
    ) {
        self.init(
            leadingActions: leadingActions().compactMap(QuickSwipeAction.init),
            trailingActions: trailingActions().compactMap(QuickSwipeAction.init)
        )
    }
}
