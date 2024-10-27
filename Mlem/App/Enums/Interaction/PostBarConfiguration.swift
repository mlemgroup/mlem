//
//  PostInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Foundation

struct PostBarConfiguration: InteractionBarConfiguration {
    enum ActionType: String, ActionTypeProviding {
        case upvote
        case downvote
        case save
        case reply
        case share
        case selectText
        case hide
        case block
        case report
        case crossPost
        case lock
        case pin
        case remove
        
        var appearance: ActionAppearance {
            switch self {
            case .upvote: .upvote(isOn: false)
            case .downvote: .downvote(isOn: false)
            case .save: .save(isOn: false)
            case .reply: .reply()
            case .share: .share()
            case .selectText: .selectText()
            case .hide: .hide(isOn: false)
            case .block: .block(isOn: false)
            case .report: .report()
            case .crossPost: .crossPost()
            case .lock: .lock(isOn: false)
            case .pin: .pin(isOn: false)
            case .remove: .remove(isOn: false)
            }
        }
    }
    
    enum CounterType: String, CounterTypeProviding {
        case score
        case upvote
        case downvote
        case reply
        
        var appearance: CounterAppearance {
            switch self {
            case .score: .init(value: 7, leading: .upvote(isOn: false), trailing: .downvote(isOn: false))
            case .upvote: .init(value: 9, leading: .upvote(isOn: false), trailing: nil)
            case .downvote: .init(value: 2, leading: .downvote(isOn: false), trailing: nil)
            case .reply: .init(value: 1, leading: .reply(), trailing: nil)
            }
        }
    }
    
    enum ReadoutType: String, ReadoutTypeProviding {
        case created
        case score
        case upvote
        case downvote
        case comment
        case saved
        
        var appearance: MockReadoutAppearance {
            switch self {
            case .created: .init(icon: Icons.time, label: "18h")
            case .score: .init(icon: Icons.votes, label: "7")
            case .upvote: .init(icon: Icons.upvoteSquare, label: "9")
            case .downvote: .init(icon: Icons.downvoteSquare, label: "2")
            case .comment: .init(icon: Icons.replies, label: "1")
            case .saved: .init(icon: Icons.save, label: "")
            }
        }
        
        func compatibleWith(otherReadouts: Set<Self>) -> Bool {
            switch self {
            case .score: otherReadouts.isDisjoint(with: [.upvote, .downvote])
            case .upvote, .downvote: !otherReadouts.contains(.score)
            default: true
            }
        }
    }

    var leading: [Item]
    var trailing: [Item]
    var readouts: [ReadoutType]
    
    var all: [Item] { leading + trailing }
    
    static var `default`: Self {
        .init(
            leading: [.counter(.score)],
            trailing: [.action(.save), .action(.reply)],
            readouts: [.created, .comment]
        )
    }
}
