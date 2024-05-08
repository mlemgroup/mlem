//
//  Interactable1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-02.
//

import Foundation
import MlemMiddleware

extension Interactable1Providing {
    private var self2: (any Interactable2Providing)? { self as? any Interactable2Providing }
        
    var upvoteAction: BasicAction {
        .upvote(
            isOn: (self2?.votes.myVote ?? .none == .upvote),
            callback: api.willSendToken ? self2?.toggleUpvote : nil
        )
    }
    
    var downvoteAction: BasicAction {
        .downvote(
            isOn: (self2?.votes.myVote ?? .none == .downvote),
            callback: api.willSendToken ? self2?.toggleDownvote : nil
        )
    }

    var saveAction: BasicAction {
        .save(
            isOn: self2?.isSaved ?? false,
            callback: api.willSendToken ? self2?.toggleSave : nil
        )
    }
}
