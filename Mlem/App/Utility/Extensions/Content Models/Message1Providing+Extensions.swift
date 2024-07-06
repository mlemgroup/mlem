//
//  Message1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import MlemMiddleware

extension Message1Providing {
    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        let trailingActions: [BasicAction] = api.willSendToken ? [
            markReadAction(feedback: [.haptic])
        ] : .init()
        
        return .init(leadingActions: [], trailingActions: trailingActions, behavior: behavior)
    }
}
