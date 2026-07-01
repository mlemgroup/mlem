//
//  PostBarConfiguration+Types.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-15.
//

import Actions
import Foundation
import MlemMiddleware
import SwiftUI

extension PostBarConfiguration {
    enum ActionType: String, ActionTypeProviding {
        typealias Configuration = PostBarConfiguration // swiftlint:disable:this nesting
        
        case upvote
        case downvote
        case save
        case reply
        case share
        case selectText
        case postDetails
        case hide
        case block
        case report
        case crossPost
        case lock
        case pin
        case resolve
        case remove
        case ban
        
        static var defaultWidgets: [ActionType] { [
            .upvote,
            .downvote,
            .save,
            .reply,
            .share
        ] }
        
        static var defaultReportWidgets: [ActionType] { [
            .share,
            .lock,
            .pin,
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
            case .postDetails: .postDetails()
            case .hide: .hide(isOn: false)
            case .block: .block(isOn: false)
            case .report: .report()
            case .crossPost: .crossPost()
            case .lock: .lock(isOn: false)
            case .pin: .pin(isOn: false)
            case .resolve: .resolve(isOn: false)
            case .remove: .remove(isOn: false)
            case .ban: .banFromCommunity(isOn: false)
            }
        }
        
        func associatedReadouts(context: any InteractableProviding) -> Set<PostBarConfiguration.ReadoutType> {
            switch self {
            case .upvote: context.votes.value?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
            case .downvote: context.votes.value?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
            case .save: [.saved]
            case .reply, .share, .selectText, .postDetails, .hide, .block, .report, .crossPost, .lock, .pin, .resolve, .remove, .ban: []
            }
        }
        
        func associatedReadouts(context: Post) -> Set<PostBarConfiguration.ReadoutType> {
            switch self {
            case .upvote: context.votes.value?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
            case .downvote: context.votes.value?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
            case .save: [.saved]
            case .reply, .share, .selectText, .postDetails, .hide, .block, .report, .crossPost, .lock, .pin, .resolve, .remove, .ban: []
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
            case .postDetails: .details
            case .hide: .hide
            case .block: .blockCreator
            case .report: .report
            case .crossPost: .crosspost
            case .lock: .lock
            case .pin: .pin
            case .resolve: .resolveReport
            case .remove: .remove
            case .ban: .banCreator
            }
        }
    }
    
    enum CounterType: String, CounterTypeProviding {
        typealias Configuration = PostBarConfiguration // swiftlint:disable:this nesting
        
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
        
        func associatedReadouts(context: any InteractableProviding) -> Set<PostBarConfiguration.ReadoutType> {
            switch self {
            case .score: [.upvote, .downvote, .score]
            case .upvote: context.votes.value?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
            case .downvote: context.votes.value?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
            case .reply: []
            }
        }
        
        func associatedReadouts(context: Post) -> Set<PostBarConfiguration.ReadoutType> {
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
