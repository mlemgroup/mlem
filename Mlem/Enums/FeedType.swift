//
//  FeedType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-08.
//

import Foundation
import SwiftUI

enum FeedType {
    case all, local, subscribed, moderated, saved
    case community(CommunityModel)
    
    static var allShortcutFeedCases: [FeedType] = [.all, .local, .subscribed, .saved]
    static var allAggregateFeedCases: [FeedType] = [.all, .local, .subscribed, .moderated, .saved]
    
    var label: String {
        switch self {
        case .all: "All"
        case .local: "Local"
        case .subscribed: "Subscribed"
        case .moderated: "Moderated"
        case .saved: "Saved"
        case let .community(communityModel): communityModel.name
        }
    }
    
    /// Maps FeedType to APIListingType
    var toApiListingType: APIListingType {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderated: .moderatorView
        case .saved: .all // TODO: change this?
        case .community: .subscribed
        }
    }
    
    /// String for use in shortcuts
    var toShortcutString: String {
        switch self {
        case .all: "All"
        case .local: "Local"
        case .subscribed: "Subscribed"
        case .moderated: "Moderated"
        case .saved: "Saved" // TODO: change this?
        case .community: "Subscribed"
        }
    }
    
    static func fromShortcutString(shortcut: String?) -> FeedType? {
        switch shortcut {
        case "All":
            return .all
        case "Local":
            return .local
        case "Subscribed":
            return .subscribed
        case "Moderated":
            return .moderated
        case "Saved":
            return .saved
        default:
            return nil
        }
    }
    
    var communityId: Int? {
        switch self {
        case let .community(communityModel): communityModel.communityId
        default: nil
        }
    }
}

extension FeedType: Hashable, Identifiable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .all:
            hasher.combine("all")
        case .local:
            hasher.combine("local")
        case .subscribed:
            hasher.combine("subscribed")
        case .moderated:
            hasher.combine("moderated")
        case .saved:
            hasher.combine("saved")
        case let .community(communityModel):
            hasher.combine("community")
            hasher.combine(communityModel.communityId)
        }
    }
    
    var id: Int { hashValue }
}

extension FeedType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .all: Icons.federatedFeed
        case .local: Icons.localFeed
        case .subscribed: Icons.subscribedFeed
        case .moderated: Icons.moderation
        case .saved: Icons.savedFeed
        case .community: Icons.community
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .all: Icons.federatedFeedFill
        case .local: Icons.localFeedFill
        case .subscribed: Icons.subscribedFeedFill
        case .moderated: Icons.moderationFill
        case .saved: Icons.savedFeedFill
        case .community: Icons.communityFill
        }
    }
    
    /// Icon to use in system settings. This should be removed when the "unified symbol handling" is closed
    var settingsIconName: String {
        switch self {
        case .all: "circle.hexagongrid"
        case .local: "house"
        case .subscribed: "newspaper"
        case .moderated: Icons.moderation
        case .saved: Icons.save
        case .community: Icons.community
        }
    }
    
    var iconScaleFactor: CGFloat {
        switch self {
        case .all:
            0.6
        case .local:
            0.6
        case .subscribed:
            0.5
        case .moderated:
            0.5
        case .saved:
            0.55
        default:
            0.5
        }
    }
}

extension FeedType: AssociatedColor {
    var color: Color? {
        switch self {
        case .all: .blue
        case .local: .purple
        case .subscribed: .red
        case .moderated: .green
        case .saved: .green
        case .community: .blue
        }
    }
}
