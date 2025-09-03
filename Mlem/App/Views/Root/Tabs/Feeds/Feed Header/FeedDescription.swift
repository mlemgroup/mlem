//
//  SubscribedFeedIcon.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-27.
//

import Foundation
import Icons
import MlemMiddleware
import SwiftUI
import Theming

struct FeedDescription {
    var label: LocalizedStringResource
    var subtitle: LocalizedStringResource
    var color: ThemedColor
    var icon: Icon
    var iconScaleFactor: CGFloat
    
    static var all: FeedDescription = .init(
        label: "All",
        subtitle: "Posts from all federated instances",
        color: .themedFederatedFeed,
        icon: .lemmy.federatedFeed,
        iconScaleFactor: 0.6
    )
    
    static var local: FeedDescription {
        .init(
            label: "Local",
            subtitle: "Posts from \(AppState.main.firstApi.host) communities",
            color: .themedLocalFeed,
            icon: .lemmy.localFeed,
            iconScaleFactor: 0.55
        )
    }
    
    static var subscribed: FeedDescription = .init(
        label: "Subscribed",
        subtitle: "Posts from communities you subscribe to",
        color: .themedSubscribedFeed,
        icon: .lemmy.subscribedFeed,
        iconScaleFactor: 0.5
    )
    
    static var moderated: FeedDescription = .init(
        label: "Moderated",
        subtitle: "Posts from communities you moderate",
        color: .themedModeratedFeed,
        icon: .lemmy.moderatedFeed,
        iconScaleFactor: 0.5
    )
    
    static var saved: FeedDescription = .init(
        label: "Saved",
        subtitle: "Your saved posts and comments",
        color: .themedSavedFeed,
        icon: .lemmy.savedFeed,
        iconScaleFactor: 0.55
    )

    static var popular: FeedDescription = .init(
        label: "Popular",
        subtitle: "Posts from popular communities",
        color: .themedPopularFeed,
        icon: .lemmy.popularFeed,
        iconScaleFactor: 0.55
    )

    static var suggested: FeedDescription = .init(
        label: "Suggested",
        subtitle: "A selection of communities curated by \(AppState.main.firstApi.host) admins",
        color: .themedSuggestedFeed,
        icon: .lemmy.suggestedFeed,
        iconScaleFactor: 0.55
    )
}
