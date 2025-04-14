//
//  PostSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-27.
//

import Foundation
import SwiftUI

// note: this is a very lazy categorization of "properties that affect posts"
struct PostSettingsView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor: Bool
    
    @Setting(\.post_size) var postSize
    @Setting(\.post_allowMultipleColumns) var allowMultipleColumns
    @Setting(\.post_thumbnailLocation) var thumbnailLocation
    @Setting(\.post_showCreator) var showCreator
    @Setting(\.post_showSubscribedStatus) var showSubscribedStatus
    @Setting(\.post_showDownvotesCompact) var showDownvotesCompact
    @Setting(\.post_gestures_tapToCollapse) var tapPostsToCollapse
    
    @Setting(\.interactionBar_post) var postInteractionBar
    
    @Setting(\.a11y_readPostIndicator) var readPostIndicator
    
    var body: some View {
        Form {
            PostSizePicker()
            if UIDevice.isPad {
                Toggle("Multiple Columns", systemImage: "square.grid.2x2", isOn: $allowMultipleColumns)
            }
            
            Section {
                NavigationLink(.settings(.interactionBar(.post))) {
                    SettingsInteractionBarSummaryView(configuration: postInteractionBar)
                }
                NavigationLink("Swipe Actions", destination: .settings(.swipeActions(.post)))
            }
            
            Section {
                NavigationLink(
                    "Subscription Indicator",
                    value: showSubscribedStatus ? .init(localized: "On") : .init(localized: "Off"),
                    fallbackValue: "",
                    icon: .lemmy.subscribedFeed,
                    destination: .settings(.postSubscriptionIndicator)
                )
                
                if postSize == .headline || postSize == .compact {
                    NavigationLink(
                        "Thumbnail",
                        value: .init(localized: thumbnailLocation.label),
                        fallbackValue: "",
                        icon: .settings.thumbnail,
                        destination: .settings(.postThumbnail)
                    )
                }
                
                if postSize == .compact {
                    Toggle("Show Downvotes Separately", icon: .lemmy.votes, isOn: $showDownvotesCompact)
                }
                
                if differentiateWithoutColor {
                    NavigationLink(
                        "Read Indicator",
                        value: .init(localized: readPostIndicator.label),
                        fallbackValue: "",
                        icon: .settings.readIndicatorSetting,
                        destination: .settings(.postReadIndicator)
                    )
                }
            }
            
            Section {
                Toggle("Tap to Collapse", icon: .general.collapse, isOn: $tapPostsToCollapse)
            }
            
            if postSize != .tile, postSize != .compact {
                Section {
                    Toggle("Always Show Usernames", icon: .settings.author, isOn: $showCreator)
                }
            }
        }
        .labelStyle(.conditional)
        .navigationTitle("Posts")
    }
}
