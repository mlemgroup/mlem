//
//  FeedType.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12.06.2023.
//

import SwiftUI

enum FeedType: String, Encodable, SettingsOptions {
    var id: Self { self }

    var label: String {
        return rawValue
    }
    
    var color: Color {
        switch self {
        case .all:
            return .blue
        case .local:
            return .orange
        case .subscribed:
            return .red
        }
    }
    
    case all = "All"
    case local = "Local"
    case subscribed = "Subscribed"
}

extension FeedType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .all: return Icons.federatedFeed
        case .local: return Icons.localFeed
        case .subscribed: return Icons.subscribedFeed
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .all: return Icons.federatedFeedFill
        case .local: return Icons.localFeedFill
        case .subscribed: return Icons.subscribedFeedFill
        }
    }
    
    var iconNameCircle: String {
        switch self {
        case .all: return Icons.federatedFeedCircle
        case .local: return Icons.localFeedCircle
        case .subscribed: return Icons.subscribedFeedCircle
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
