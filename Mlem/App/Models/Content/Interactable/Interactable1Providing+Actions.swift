//
//  Interactable1Providing+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

extension Interactable1Providing {
    var upvoteAction: Action {
        .init(type: .upvote, isOn: false)
    }
    
    var downvoteAction: Action {
        .init(type: .upvote, isOn: false)
    }
    
    var saveAction: Action {
        .init(type: .upvote, isOn: false)
    }
    
    func action(ofType type: ActionType) -> Action? {
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
