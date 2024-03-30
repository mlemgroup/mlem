//
//  Post1Providing+Actionable.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

enum PostActionKey {
    case upvote, downvote, save
}

// This could be defined as an extension of Interactable1Providing at this point, but I am not doing so because in future we will have actions that only exist for posts/comments (e.g. "Crosspost") - sjmarf

extension Post1Providing where ActionKey == PostActionKey {
    func action(forKey key: PostActionKey) -> Action {
        switch key {
        case .upvote:
            upvoteAction
        case .downvote:
            downvoteAction
        case .save:
            saveAction
        }
    }
}
