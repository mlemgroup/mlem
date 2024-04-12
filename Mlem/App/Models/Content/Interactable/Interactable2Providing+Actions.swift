//
//  Interactable2Providing+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

extension Interactable2Providing {
    var upvoteAction: BasicAction {
        var action = BasicAction.upvote(isOn: votes.myVote == .upvote)
        action.callback = toggleUpvote
        return action
    }
    
    var downvoteAction: BasicAction {
        var action = BasicAction.downvote(isOn: votes.myVote == .downvote)
        action.callback = toggleDownvote
        return action
    }
    
    var saveAction: BasicAction {
        var action = BasicAction.save(isOn: isSaved)
        action.callback = toggleSave
        return action
    }
}
