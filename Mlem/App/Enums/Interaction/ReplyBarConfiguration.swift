//
//  InboxInteraction.swift
//  Mlem
//
//  Created by Sjmarf on 14/06/2024.
//

import Foundation

struct ReplyBarConfiguration: InteractionBarConfiguration {
    enum ActionType: String, ActionTypeProviding {
        case upvote
        case downvote
        case save
        case reply
        case markRead
        case selectText
        case report
        
        var appearance: ActionAppearance {
            switch self {
            case .upvote: .upvote(isOn: false)
            case .downvote: .downvote(isOn: false)
            case .save: .save(isOn: false)
            case .reply: .reply()
            case .markRead: .markRead(isOn: false)
            case .selectText: .selectText()
            case .report: .report()
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
        
        var appearance: MockReadoutAppearance {
            switch self {
            case .created: .init(icon: Icons.time, label: "18h")
            case .score: .init(icon: Icons.votes, label: "7")
            case .upvote: .init(icon: Icons.upvoteSquare, label: "9")
            case .downvote: .init(icon: Icons.downvoteSquare, label: "2")
            case .comment: .init(icon: Icons.replies, label: "1")
            }
        }
    }

    var leading: [Item]
    var trailing: [Item]
    var readouts: [ReadoutType]
    
    static var `default`: Self {
        .init(
            leading: [.counter(.score)],
            trailing: [.action(.save), .action(.reply)],
            readouts: [.created, .comment]
        )
    }
}
