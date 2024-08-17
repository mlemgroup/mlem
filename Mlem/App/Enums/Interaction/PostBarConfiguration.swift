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
    
    enum CounterType: CounterTypeProviding {
        case score
        case upvote
        case downvote
        
        var appearance: CounterAppearance {
            switch self {
            case .score: .init(value: 7, leading: .upvote(isOn: false), trailing: .downvote(isOn: false))
            case .upvote: .init(value: 9, leading: .upvote(isOn: false), trailing: nil)
            case .downvote: .init(value: 2, leading: .upvote(isOn: false), trailing: nil)
            }
        }
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
