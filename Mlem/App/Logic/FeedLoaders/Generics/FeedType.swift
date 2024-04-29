//
//  FeedType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-08.
//

import Foundation
import MlemMiddleware
import SwiftUI

enum FeedType: Equatable {
    case all, local, subscribed, saved
    case community(any CommunityStubProviding)
    
    static func == (lhs: FeedType, rhs: FeedType) -> Bool {
        switch (lhs, rhs) {
        case let (.community(comm1), .community(comm2)):
            return comm1.actorId == comm2.actorId
        case (.all, .all), (.local, .local), (.subscribed, .subscribed), (.saved, .saved):
            return true
        default:
            return false
        }
    }
    
    static var allAggregateFeedCases: [FeedType] = [.all, .local, .subscribed, .saved]
    
    var label: String {
        switch self {
        case .all: "All"
        case .local: "Local"
        case .subscribed: "Subscribed"
        case .saved: "Saved"
        case let .community(communityModel): communityModel.name
        }
    }
    
    /// Maps FeedType to ApiListingType
    var toApiListingType: ApiListingType {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
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
        case "Saved":
            return .saved
        default:
            return nil
        }
    }
    
    var communityId: Int? {
        switch self {
        case let .community(community): community.id_
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
        case .saved:
            hasher.combine("saved")
        case let .community(community):
            hasher.combine("community")
            hasher.combine(community.actorId)
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

extension FeedType: AssociatedColor {
    var color: Color? {
        switch self {
        case .all: .blue
        case .local: .purple
        case .subscribed: .red
        case .saved: .green
        case .community: .blue
        }
    }
}
