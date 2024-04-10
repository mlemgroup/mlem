//
//  FeedType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-08.
//

import Dependencies
import Foundation
import SwiftUI

// maybe a slight misnomer because .saved can include comments?
enum PostFeedType: FeedType {
    case all, local, subscribed, moderated, saved
    case community(CommunityModel)
    
    static var allShortcutFeedCases: [PostFeedType] = [.all, .local, .subscribed, .saved]
    static var allAggregateFeedCases: [PostFeedType] = [.all, .local, .subscribed, .moderated, .saved]
    
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
    
    var subtitle: String {
        @Dependency(\.siteInformation) var siteInformation
        switch self {
        case .all:
            return "Posts from all federated instances"
        case .local:
            return "Posts from \(siteInformation.instance?.url.host() ?? "your instance's") communities"
        case .subscribed:
            return "Posts from all subscribed communities"
        case .moderated:
            return "Posts from communities you moderate"
        case .saved:
            return "Your saved posts and comments"
        default:
            assertionFailure("We shouldn't be here...")
            return ""
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
    
    static func fromShortcutString(shortcut: String?) -> PostFeedType? {
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

extension PostFeedType: Hashable, Identifiable {
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

extension PostFeedType: AssociatedIcon {
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

extension PostFeedType: AssociatedColor {
    var color: Color? {
        switch self {
        case .all: .blue
        case .local: .purple
        case .subscribed: .red
        case .moderated: Color.moderation
        case .saved: .green
        case .community: .blue
        }
    }
}
