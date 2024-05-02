//
//  Post1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-02.
//

import Foundation
import MlemMiddleware

extension Post1Providing {
    var menuActions: ActionGroup {
        ActionGroup(children: [
            ActionGroup(
                children: [upvoteAction, downvoteAction]
            ),
            saveAction
        ])
    }
}
