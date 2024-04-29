//
//  Interactable2Providing+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation
import MlemMiddleware

extension Interactable2Providing {
    var upvoteAction: BasicAction {
        var action = BasicAction.upvote(isOn: api.willSendToken && votes.myVote == .upvote)
        action.callback = api.willSendToken ? toggleUpvote : nil
        return action
    }
    
    var downvoteAction: BasicAction {
        var action = BasicAction.downvote(isOn: api.willSendToken && votes.myVote == .downvote)
        action.callback = api.willSendToken ? toggleDownvote : nil
        return action
    }
    
    var saveAction: BasicAction {
        var action = BasicAction.save(isOn: api.willSendToken && isSaved)
        action.callback = api.willSendToken ? toggleSave : nil
        return action
    }
}
