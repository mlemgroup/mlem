//
//  CommentBarConfiguration+Types.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-15.
//

import Actions
import Foundation
import MlemMiddleware
import SwiftUI

extension CommentBarConfiguration {
    enum ActionType: String, ActionTypeProviding {
        typealias Configuration = CommentBarConfiguration // swiftlint:disable:this nesting
        
        case upvote
        case downvote
        case save
        case reply
        case share
        case selectText
        case report
        case resolve
        case remove
        case ban
        case collapse
        case collapseParent
        case collapseToTop
        
        static var defaultWidgets: [ActionType] { [
            .upvote,
            .downvote,
            .save,
            .reply,
            .share
        ] }
        
        static var defaultReportWidgets: [ActionType] { [
            .share,
            .resolve,
            .remove,
            .ban
        ] }
        
        var appearance: ActionAppearance {
            switch self {
            case .upvote: .upvote(isOn: false)
            case .downvote: .downvote(isOn: false)
            case .save: .save(isOn: false)
            case .reply: .reply()
            case .share: .share()
            case .selectText: .selectText()
            case .report: .report()
            case .resolve: .resolve(isOn: false)
            case .remove: .remove(isOn: false)
            case .ban: .banFromCommunity(isOn: false)
            case .collapse: .collapse()
            case .collapseParent: .collapseParent()
            case .collapseToTop: .collapseToTop()
            }
        }
        
        func associatedReadouts(context: any InteractableProviding) -> Set<Configuration.ReadoutType> {
            switch self {
            case .upvote: context.votes.value?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
            case .downvote: context.votes.value?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
            case .save: [.saved]
            case .reply, .share, .selectText, .report, .resolve, .remove, .ban: []
            case .collapse, .collapseParent, .collapseToTop: []
            }
        }
               
        var actionSeed: ActionSeed {
            switch self {
            case .upvote: .upvote
            case .downvote: .downvote
            case .save: .save
            case .reply: .reply
            case .share: .share
            case .selectText: .selectText
            case .report: .report
            case .resolve: .resolveReport
            case .remove: .remove
            case .ban: .ban
            case .collapse: .collapse
            case .collapseParent: .collapseParent
            case .collapseToTop: .save // TEMP; FIXME
            }
        }
    }
    
    enum CounterType: String, CounterTypeProviding {
        typealias Configuration = CommentBarConfiguration // swiftlint:disable:this nesting
        
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
        
        func associatedReadouts(context: any InteractableProviding) -> Set<Configuration.ReadoutType> {
            switch self {
            case .score: [.upvote, .downvote, .score]
            case .upvote: context.votes.value?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
            case .downvote: context.votes.value?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
            case .reply: []
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
            case .created: .init(icon: .general.time, label: "18h")
            case .score: .init(icon: .lemmy.votes, label: "7")
            case .upvote: .init(icon: .lemmy.upvoted, label: "9")
            case .downvote: .init(icon: .lemmy.downvoted, label: "2")
            case .comment: .init(icon: .lemmy.replies, label: "1")
            case .saved: .init(icon: .lemmy.saved, label: "")
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

}
