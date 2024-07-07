//
//  CommentInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Foundation

struct CommentBarConfiguration {
    enum Item {
        case action(CommentActionType)
        case counter(CommentCounterType)
    }
    
    let leading: [Item]
    let trailing: [Item]
    let readouts: [CommentReadoutType]
}

enum CommentCounterType {
    case score
    case upvote
    case downvote
}

enum CommentActionType {
    case upvote
    case downvote
    case save
    case reply
    case share
    case selectText
}

enum CommentReadoutType: CaseIterable {
    case created
    case score
    case upvote
    case downvote
    case comment
}
