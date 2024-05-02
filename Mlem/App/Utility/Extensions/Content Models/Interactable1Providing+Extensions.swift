//
//  Interactable1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-02.
//

import Foundation
import MlemMiddleware

extension Interactable1Providing {
    var upvoteAction: BasicAction {
        .upvote(isOn: false)
    }
    
    var downvoteAction: BasicAction {
        .downvote(isOn: false)
    }

    var saveAction: BasicAction {
        .save(isOn: false)
    }
}
