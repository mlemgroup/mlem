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
        case upvote
        case downvote
        case save
        case reply
        case markRead
        case selectText
        case report
        
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
}
