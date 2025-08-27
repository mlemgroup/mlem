//
//  FeedContext.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-27.
//

import Foundation

enum FeedContext {
    case all, local, subscribed, saved, moderated, popular, suggested, community, search, person, post

    var showSubscriptionIndicator: Bool {
        switch self {
        case .all, .local, .popular, .suggested, .saved, .search, .person, .post:
            return true
        default:
            return false
        }
    }
}
