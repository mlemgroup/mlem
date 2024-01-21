//
//  NEW FeedType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-08.
//

import Foundation
import SwiftUI

enum NewFeedType {
    case all, local, subscribed, saved
    case community(CommunityModel)
    
    static var allAggregateFeedCases: [NewFeedType] = [.all, .local, .subscribed, .saved]
    
    var label: String {
        switch self {
        case .all: "All"
        case .local: "Local"
        case .subscribed: "Subscribed"
        case .saved: "Saved"
        case let .community(communityModel): communityModel.name
        }
    }
    
    /// String to pass into the API call
    var typeString: String {
        switch self {
        case .all: "All"
        case .local: "Local"
        case .subscribed: "Subscribed"
        case .saved: "Saved" // TODO: change this?
        case .community: "Subscribed"
        }
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
            assertionFailure("Incompatible feed type!")
            return .all
        default:
            assertionFailure("Incompatible feed type!")
            return .all
        }
    }
    
    var communityId: Int? {
        switch self {
        case let .community(communityModel): communityModel.communityId
        default: nil
        }
    }
}

extension NewFeedType: Hashable, Identifiable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .all:
            hasher.combine("all")
        case .local:
            hasher.combine("local")
        case .subscribed:
            hasher.combine("subscribed")
        case .saved:
            hasher.combine("saved")
        case let .community(communityModel):
            hasher.combine("community")
            hasher.combine(communityModel.communityId)
        }
    }
    
    var id: Int { hashValue }
}

extension NewFeedType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .all: Icons.federatedFeed
        case .local: Icons.localFeed
        case .subscribed: Icons.subscribedFeed
        case .saved: Icons.savedFeed
        case .community: Icons.community
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .all: Icons.federatedFeedFill
        case .local: Icons.localFeedFill
        case .subscribed: Icons.subscribedFeedFill
        case .saved: Icons.savedFeedFill
        case .community: Icons.communityFill
        }
    }
    
    var iconNameCircle: String {
        switch self {
        case .all: Icons.federatedFeedCircle
        case .local: Icons.localFeedCircle
        case .subscribed: Icons.subscribedFeedCircle
        case .saved: Icons.savedFeedCircle
        case .community: Icons.community
        }
    }
    
    /// Icon to use in system settings. This should be removed when the "unified symbol handling" is closed
    var settingsIconName: String {
        switch self {
        case .all: "circle.hexagongrid"
        case .local: "house"
        case .subscribed: "newspaper"
        case .saved: Icons.save
        case .community: Icons.community
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
        case .community: .blue
        }
    }
}
