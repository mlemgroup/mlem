//
//  FeedSelection.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-12.
//

import Foundation
import MlemMiddleware

enum FeedSelection: String, CaseIterable {
    case all, local, subscribed, saved
    // TODO: moderated
    
    static var guestCases: [FeedSelection] {
        [.all, .local]
    }
    
    var description: FeedDescription {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .saved: .saved
        }
    }
    
    var associatedApiType: ApiListingType {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .saved: .all // dummy value
        }
    }
}
