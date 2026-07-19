//
//  ReplyBarConfiguration+Types.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-15.
//

import Actions
import Foundation
import MlemMiddleware
import SwiftUI

extension ReplyBarConfiguration {
    enum ActionType: String, ActionTypeProviding {
        typealias Configuration = ReplyBarConfiguration // swiftlint:disable:this nesting
        
        case upvote
        case downvote
        case save
        case reply
        case markRead
        case selectText
        case report
        
        static var defaultWidgets: [ActionType] { [
            .upvote,
            .downvote,
            .save,
            .reply,
            .markRead
        ] }
        
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
        
        func associatedReadouts(context: any InteractableProviding) -> Set<ReadoutType> {
            switch self {
            case .upvote: context.votes.value?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
            case .downvote: context.votes.value?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
            case .save: [.saved]
            case .reply, .markRead, .selectText, .report: []
            }
        }

        var actionSeed: ActionSeed {
            switch self {
            case .upvote: .upvote
            case .downvote: .downvote
            case .save: .save
            case .reply: .reply
            case .markRead: .markRead
            case .selectText: .selectText
            case .report: .report
            }
        }
    }
    
    enum CounterType: String, CounterTypeProviding {
        typealias Configuration = ReplyBarConfiguration // swiftlint:disable:this nesting
        
        case score
        case upvote
        case downvote
        case reply
        
        static var defaultWidgets: [CounterType] { allCases }
        
        var appearance: CounterAppearance {
            switch self {
            case .score: .score()
            case .upvote: .upvote()
            case .downvote: .downvote()
            case .reply: .reply()
            }
        }
        
        func associatedReadouts(context: any InteractableProviding) -> Set<ReadoutType> {
            switch self {
            case .score: [.upvote, .downvote, .score]
            case .upvote: context.votes.value?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
            case .downvote: context.votes.value?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
            case .reply: []
            }
        }
    }
}
