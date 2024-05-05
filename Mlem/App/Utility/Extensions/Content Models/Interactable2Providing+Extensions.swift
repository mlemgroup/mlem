//
//  Interactable2Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-02.
//

import Foundation
import MlemMiddleware

extension Interactable2Providing {
    var upvoteAction: BasicAction {
        .upvote(isOn: votes.myVote == .upvote, callback: api.willSendToken ? toggleUpvote : nil)
    }
    
    var downvoteAction: BasicAction {
        .downvote(isOn: votes.myVote == .downvote, callback: api.willSendToken ? toggleDownvote : nil)
    }

    var saveAction: BasicAction {
        .save(isOn: isSaved, callback: api.willSendToken ? toggleSave : nil)
    }
}
