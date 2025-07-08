//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public enum PostFeedViewMode {
    case list, card, smallCard
    
    init(from listingMode: LemmyPostListingMode) {
        self = switch listingMode {
        case .list: .list
        case .card: .card
        case .smallCard: .smallCard
        }
    }
    
    var apiType: LemmyPostListingMode {
        switch self {
        case .list: .list
        case .card: .card
        case .smallCard: .smallCard
        }
    }
}
