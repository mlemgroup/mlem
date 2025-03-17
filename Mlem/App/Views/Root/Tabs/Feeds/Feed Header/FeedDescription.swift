//
//  SubscribedFeedIcon.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-27.
//

import Foundation
import MlemMiddleware
import SwiftUI
import Theming

struct FeedDescription {
    var label: LocalizedStringResource
    var subtitle: LocalizedStringResource
    var color: ThemedColor
    var iconName: String
    var iconNameFill: String
    var iconScaleFactor: CGFloat
    
    static var all: FeedDescription = .init(
        label: "All",
        subtitle: "Posts from all federated instances",
        color: .themedFederatedFeed,
        iconName: Icons.federatedFeed,
        iconNameFill: Icons.federatedFeedFill,
        iconScaleFactor: 0.6
    )
    
    static var local: FeedDescription {
        .init(
            label: "Local",
            subtitle: "Posts from \(AppState.main.firstApi.host) communities",
            color: .themedLocalFeed,
            iconName: Icons.instanceFeed,
            iconNameFill: Icons.instanceFeedFill,
            iconScaleFactor: 0.55
        )
    }
    
    static var subscribed: FeedDescription = .init(
        label: "Subscribed",
        subtitle: "Posts from communities you subscribe to",
        color: .themedSubscribedFeed,
        iconName: Icons.subscribedFeed,
        iconNameFill: Icons.subscribedFeedFill,
        iconScaleFactor: 0.5
    )
    
    static var moderated: FeedDescription = .init(
        label: "Moderated",
        subtitle: "Posts from communities you moderate",
        color: .themedModeratedFeed,
        iconName: Icons.moderation,
        iconNameFill: Icons.moderationFill,
        iconScaleFactor: 0.5
    )
    
    static var saved: FeedDescription = .init(
        label: "Saved",
        subtitle: "Your saved posts and comments",
        color: .themedSavedFeed,
        iconName: Icons.savedFeed,
        iconNameFill: Icons.savedFeedFill,
        iconScaleFactor: 0.55
    )
}
