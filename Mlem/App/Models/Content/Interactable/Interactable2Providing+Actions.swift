//
//  Interactable2Providing+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

extension Interactable2Providing {
    var upvoteAction: BasicAction {
        var action = ActionType.upvoteAction(isOn: votes.myVote == .upvote)
        action.callback = toggleUpvote
        return action
    }
    
    var downvoteAction: BasicAction {
        var action = ActionType.downvoteAction(isOn: votes.myVote == .downvote)
        action.callback = toggleDownvote
        return action
    }
    
    var saveAction: BasicAction {
        var action = ActionType.saveAction(isOn: isSaved)
        action.callback = toggleSave
        return action
    }
}
