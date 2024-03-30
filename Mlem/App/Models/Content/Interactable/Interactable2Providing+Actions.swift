//
//  Interactable2Providing+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

extension Interactable2Providing {
    var upvoteAction: BasicAction {
        .init(
            configuration: ActionType.upvoteConfiguration(isOn: votes.myVote == .upvote),
            callback: toggleUpvote
        )
    }
    
    var downvoteAction: BasicAction {
        .init(
            configuration: ActionType.downvoteConfiguration(isOn: votes.myVote == .downvote),
            callback: toggleDownvote
        )
    }
    
    var saveAction: BasicAction {
        .init(
            configuration: ActionType.saveConfiguration(isOn: isSaved),
            callback: toggleSave
        )
    }
}
