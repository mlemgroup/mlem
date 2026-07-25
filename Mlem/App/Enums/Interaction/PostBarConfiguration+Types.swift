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
    enum ActionType: String, LegacyActionTypeProviding {
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
        
        static var defaultReportWidgets: [ActionType] { [
            .share,
            .lock,
            .pin,
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
}
