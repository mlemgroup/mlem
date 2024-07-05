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
    var label: String
    var subtitle: String
    var color: Color?
    var iconNameFill: String
    var iconScaleFactor: CGFloat
    
    static var all: FeedDescription = .init(
        label: "All",
        subtitle: "Posts from all federated instances",
        color: Palette.main.federatedFeed,
        iconNameFill: Icons.federatedFeedFill,
        iconScaleFactor: 0.6
    )
    
    static var local: FeedDescription = .init(
        label: "Local",
        subtitle: "Posts from \(AppState.main.firstApi.host ?? "your instance's") communities",
        color: Palette.main.localFeed,
        iconNameFill: Icons.localFeedFill,
        iconScaleFactor: 0.6
    )
    
    static var subscribed: FeedDescription = .init(
        label: "Subscribed",
        subtitle: "Posts from communities you subscribe to",
        color: Palette.main.subscribedFeed,
        iconNameFill: Icons.subscribedFeedFill,
        iconScaleFactor: 0.5
    )
    
    static var moderated: FeedDescription = .init(
        label: "Moderated",
        subtitle: "Posts from communities you moderate",
        color: Palette.main.moderatedFeed,
        iconNameFill: Icons.moderationFill,
        iconScaleFactor: 0.5
    )
    
    static var saved: FeedDescription = .init(
        label: "Saved",
        subtitle: "Your saved posts and comments",
        color: Palette.main.savedFeed,
        iconNameFill: Icons.moderationFill,
        iconScaleFactor: 0.55
    )
}
