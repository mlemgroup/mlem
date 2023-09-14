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
        case .all: return rawValue
        case .local: return rawValue
        case .subscribed: return rawValue
        }
    }
    
    case all = "All"
    case local = "Local"
    case subscribed = "Subscribed"
}

extension FeedType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .all: return Icons.federatedFeedSymbolName
        case .local: return Icons.localFeedSymbolName
        case .subscribed: return Icons.subscribedFeedSymbolName
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .all: return Icons.federatedFeedSymbolName
        case .local: return Icons.localFeedSymbolNameFill
        case .subscribed: return Icons.subscribedFeedSymbolNameFill
        }
    }
    
    /// Icon to use in system settings. This should be removed when the "unified symbol handling" is closed
    var settingsIconName: String {
        switch self {
        case .all: return "circle.hexagongrid"
        case .local: return "house"
        case .subscribed: return "newspaper"
        }
    }
}
