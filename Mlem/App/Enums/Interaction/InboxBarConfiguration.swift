//
//  InboxInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Foundation

struct InboxBarConfiguration: InteractionBarConfiguration {
    enum ActionType {
        case upvote
        case downvote
        case save
    }
    
    enum CounterType {
        case score
        case upvote
        case downvote
    }
    
    enum ReadoutType: CaseIterable {
        case created
        case score
        case upvote
        case downvote
        case comment
    }

    let leading: [Item]
    let trailing: [Item]
    let readouts: [ReadoutType]
    
    static var `default`: Self {
        .init(
            leading: [.counter(.score)],
            trailing: [.action(.save)],
            readouts: [.created, .comment]
        )
    }
}
