//
//  PostInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Foundation

struct PostBarConfiguration: InteractionBarConfiguration {
    enum ActionType: ActionTypeProviding {
        case upvote
        case downvote
        case save
        case reply
        case share
        case selectText
        case hide
        
        var appearance: ActionAppearance {
            switch self {
            case .upvote: .upvote(isOn: false)
            case .downvote: .downvote(isOn: false)
            case .save: .save(isOn: false)
            case .reply: .reply()
            case .share: .share()
            case .selectText: .selectText()
            case .hide: .hide(isOn: false)
            }
        }
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
            trailing: [.action(.save), .action(.reply)],
            readouts: [.created, .comment]
        )
    }
}
