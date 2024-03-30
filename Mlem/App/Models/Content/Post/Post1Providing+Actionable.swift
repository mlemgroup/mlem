//
//  Post1Providing+Actionable.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

enum PostActionKey {
    case upvote, downvote
}

extension Post1Providing where ActionKey == PostActionKey {
    func action(forKey key: PostActionKey) -> Action {
        switch key {
        case .upvote:
            upvoteAction
        case .downvote:
            downvoteAction
        }
    }
}
