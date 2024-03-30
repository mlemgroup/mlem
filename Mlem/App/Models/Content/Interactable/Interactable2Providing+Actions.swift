//
//  Interactable2Providing+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

extension Interactable2Providing {
    var upvoteAction: Action {
        .init(type: .upvote, isOn: votes.myVote == .upvote, callback: toggleUpvote)
    }
    
    var downvoteAction: Action {
        .init(type: .downvote, isOn: votes.myVote == .downvote, callback: toggleDownvote)
    }
    
    var saveAction: Action {
        .init(type: .save, isOn: isSaved, callback: toggleSave)
    }
}
