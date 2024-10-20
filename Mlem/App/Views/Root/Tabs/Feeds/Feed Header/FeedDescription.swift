//
//  SubscribedFeedIcon.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-27.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct FeedDescription {
    var label: LocalizedStringResource
    var subtitle: LocalizedStringResource
    var color: (Palette) -> Color? // makes color change when palette changes
    var iconName: String
    var iconNameFill: String
    var iconScaleFactor: CGFloat
    
    static var all: FeedDescription = .init(
        label: "All",
        subtitle: "Posts from all federated instances",
        color: { $0.federatedFeed },
        iconName: Icons.federatedFeed,
        iconNameFill: Icons.federatedFeedFill,
        iconScaleFactor: 0.6
    )
    
    static var local: FeedDescription {
        let subtitle: LocalizedStringResource
        if let host = AppState.main.firstApi.host {
            subtitle = "Posts from \(host) communities"
        } else {
            subtitle = "Posts from your instance's communities"
        }
        return .init(
            label: "Local",
            subtitle: subtitle,
            color: { $0.localFeed },
            iconName: Icons.instanceFeed,
            iconNameFill: Icons.instanceFeedFill,
            iconScaleFactor: 0.55
        )
    }
    
    static var subscribed: FeedDescription = .init(
        label: "Subscribed",
        subtitle: "Posts from communities you subscribe to",
        color: { $0.subscribedFeed },
        iconName: Icons.subscribedFeed,
        iconNameFill: Icons.subscribedFeedFill,
        iconScaleFactor: 0.5
    )
    
    static var moderated: FeedDescription = .init(
        label: "Moderated",
        subtitle: "Posts from communities you moderate",
        color: { $0.moderatedFeed },
        iconName: Icons.moderation,
        iconNameFill: Icons.moderationFill,
        iconScaleFactor: 0.5
    )
    
    static var saved: FeedDescription = .init(
        label: "Saved",
        subtitle: "Your saved posts and comments",
        color: { $0.savedFeed },
        iconName: Icons.savedFeed,
        iconNameFill: Icons.savedFeedFill,
        iconScaleFactor: 0.55
    )
}
