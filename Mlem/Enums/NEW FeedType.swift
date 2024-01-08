//
//  NEW FeedType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-08.
//

import Foundation
import SwiftUI

enum NewFeedType: String, CaseIterable {
    case all, local, subscribed, saved
    
    var label: String {
        rawValue.capitalized
    }
    
    static func fromShortcut(shortcut: String?) -> NewFeedType? {
        switch shortcut {
        case "All":
            return .all
        case "Local":
            return .local
        case "Subscribed":
            return .subscribed
        case "Saved":
            return .saved
        default:
            return nil
        }
    }
    
    var toLegacyFeedType: FeedType {
        switch self {
        case .all:
            return .all
        case .local:
            return .local
        case .subscribed:
            return .subscribed
        case .saved:
            return .all
        }
    }
}

extension NewFeedType: Identifiable {
    var id: Self { self }
}

extension NewFeedType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .all: Icons.federatedFeed
        case .local: Icons.localFeed
        case .subscribed: Icons.subscribedFeed
        case .saved: Icons.savedFeed
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .all: Icons.federatedFeedFill
        case .local: Icons.localFeedFill
        case .subscribed: Icons.subscribedFeedFill
        case .saved: Icons.savedFeedFill
        }
    }
    
    var iconNameCircle: String {
        switch self {
        case .all: Icons.federatedFeedCircle
        case .local: Icons.localFeedCircle
        case .subscribed: Icons.subscribedFeedCircle
        case .saved: Icons.savedFeedCircle
        }
    }
    
    /// Icon to use in system settings. This should be removed when the "unified symbol handling" is closed
    var settingsIconName: String {
        switch self {
        case .all: "circle.hexagongrid"
        case .local: "house"
        case .subscribed: "newspaper"
        case .saved: Icons.save
        }
    }
}

extension NewFeedType: AssociatedColor {
    var color: Color? {
        switch self {
        case .all: .blue
        case .local: .red
        case .subscribed: .red
        case .saved: .green
        }
    }
}
