//
//  InteractionBarWidget.swift
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
}
