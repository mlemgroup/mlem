//
//  DefaultFeedType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-22.
//

import Foundation

enum DefaultFeedType: String, SettingsOptions, CaseIterable {
    case all, local, subscribed, saved
    
    var label: String { rawValue.capitalized }
    
    var settingsIconName: String {
        switch self {
        case .all: Icons.federatedFeed
        case .local: Icons.localFeed
        case .subscribed: Icons.subscribedFeed
        case .saved: Icons.savedFeed
        }
    }
    
    var toFeedType: FeedType {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .saved: .saved
        }
    }
    
    var id: Self { self }
}
