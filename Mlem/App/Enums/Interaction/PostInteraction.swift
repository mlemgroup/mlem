//
//  PostInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Foundation

struct PostBarConfiguration {
    enum Item {
        case action(PostActionType)
        case counter(PostCounterType)
    }
    
    let leading: [Item]
    let trailing: [Item]
    let readouts: [PostReadoutType]
}

enum PostCounterType {
    case score
    case upvote
    case downvote
}

enum PostActionType {
    case upvote
    case downvote
    case save
    case reply
    case share
    case selectText
    case hide
}

enum PostReadoutType: CaseIterable {
    case created
    case score
    case upvote
    case downvote
    case comment
}
