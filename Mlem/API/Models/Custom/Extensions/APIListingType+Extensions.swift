//
//  ApiListingType+ToFeedType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18.
//

import Foundation

extension ApiListingType {
    var toFeedType: FeedType {
        switch self {
        case .all:
            return .all
        case .local:
            return .local
        case .subscribed:
            return .subscribed
        default:
            return .all
        }
    }
}
