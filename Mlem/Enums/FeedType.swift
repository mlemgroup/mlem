//
//  FeedType.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12.06.2023.
//

import Foundation

enum FeedType: String, Encodable, SettingsOptions {
    var id: Self { self }

    var label: String { rawValue }
//    var label: String {
//        switch self {
//        case .all: return rawValue
//        case .local: return rawValue
//        case .subscribed: return rawValue
//        case .saved: return rawValue
//        }
//    }
    
    case all = "All"
    case local = "Local"
    case subscribed = "Subscribed"
    case saved = "Saved"
}

extension FeedType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .all: return Icons.federatedFeed
        case .local: return Icons.localFeed
        case .subscribed: return Icons.subscribedFeed
        case .saved: return Icons.save
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .all: return Icons.federatedFeed
        case .local: return Icons.localFeedFill
        case .subscribed: return Icons.subscribedFeedFill
        case .saved: return Icons.save
        }
    }
    
    /// Icon to use in system settings. This should be removed when the "unified symbol handling" is closed
    var settingsIconName: String {
        switch self {
        case .all: return "circle.hexagongrid"
        case .local: return "house"
        case .subscribed: return "newspaper"
        case .saved: return Icons.save
        }
    }
}
