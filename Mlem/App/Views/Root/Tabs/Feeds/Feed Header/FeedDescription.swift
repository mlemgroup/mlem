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
    
    static var subscribed: FeedDescription = .init(
        label: "Subscribed",
        subtitle: "Posts from communities you subscribe to",
        color: .red, // TODO: Palette.main.subscribed
        iconNameFill: Icons.subscribedFeedFill,
        iconScaleFactor: 0.5
    )
    
    static var all: FeedDescription = .init(
        label: "All",
        subtitle: "Posts from all federated instances",
        color: .blue,
        iconNameFill: Icons.federatedFeedFill,
        iconScaleFactor: 0.6
    )
    
    static var local: FeedDescription = .init(
        label: "Local",
        subtitle: "Posts from \(AppState.main.firstApi.host ?? "your instance's") communities",
        color: .purple,
        iconNameFill: Icons.localFeedFill,
        iconScaleFactor: 0.6
    )
    
    static var moderated: FeedDescription = .init(
        label: "Moderated",
        subtitle: "Posts from communities you moderate",
        color: Palette.main.moderation,
        iconNameFill: Icons.moderationFill,
        iconScaleFactor: 0.5
    )
}
