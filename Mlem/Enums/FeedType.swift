//
//  FeedType.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12.06.2023.
//

import Foundation

enum FeedType: String, Encodable, SettingsOptions {
    
    var id: Self { self }

    var label: String {
        switch self {
        case .all: return self.rawValue
        case .local: return self.rawValue
        case .subscribed: return self.rawValue
        }
    }
    
    case all = "All"
    case local = "Local"
    case subscribed = "Subscribed"
}

extension FeedType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .all: return AppConstants.federatedFeedSymbolName
        case .local: return AppConstants.localFeedSymbolName
        case .subscribed: return AppConstants.subscribeSymbolName
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .all: return AppConstants.federatedFeedSymbolName
        case .local: return AppConstants.localFeedSymbolNameFill
        case .subscribed: return AppConstants.subscribedFeedSymbolNameFill
        }
    }
}
