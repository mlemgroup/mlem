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
         
        static var defaultReportWidgets: [ActionType] { [
            .share,
            .resolve,
            .remove,
            .ban
        ] }
   
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
            case .collapseToTop: .collapseToTop
            }
        }
    }
}
