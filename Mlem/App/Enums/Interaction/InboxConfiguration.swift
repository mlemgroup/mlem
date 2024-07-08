//
//  InboxInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Foundation

struct InboxBarConfiguration {
    enum Item {
        case action(InboxActionType)
        case counter(InboxCounterType)
    }
    
    let leading: [Item]
    let trailing: [Item]
    let readouts: [InboxReadoutType]
}

enum InboxCounterType {
    case score
    case upvote
    case downvote
}

enum InboxActionType {
    case upvote
    case downvote
    case save
}

enum InboxReadoutType: CaseIterable {
    case created
    case score
    case upvote
    case downvote
    case comment
}
