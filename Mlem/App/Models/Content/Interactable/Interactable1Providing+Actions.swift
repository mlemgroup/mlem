//
//  Interactable1Providing+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

extension Interactable1Providing {
    var upvoteAction: BasicAction {
        .init(configuration: ActionType.upvoteConfiguration(isOn: false))
    }
    
    var downvoteAction: BasicAction {
        .init(configuration: ActionType.downvoteConfiguration(isOn: false))
    }
    
    var saveAction: BasicAction {
        .init(configuration: ActionType.saveConfiguration(isOn: false))
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
