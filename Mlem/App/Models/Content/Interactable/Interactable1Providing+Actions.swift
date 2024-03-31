//
//  Interactable1Providing+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

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
    
    func action(ofType type: ActionType) -> (any Action)? {
        switch type {
        case .upvote:
            upvoteAction
        case .downvote:
            downvoteAction
        case .save:
            saveAction
        default:
            nil
        }
    }
}
