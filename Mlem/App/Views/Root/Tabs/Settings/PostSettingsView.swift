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
    
    @Setting(\.postSize) var postSize
    @Setting(\.allowMultiplePostColumns) var allowMultipleColumns
    @Setting(\.thumbnailLocation) var thumbnailLocation
    @Setting(\.showPostCreator) var showCreator
    @Setting(\.showSubscribedStatus) var showSubscribedStatus
    @Setting(\.showDownvotesCompact) var showDownvotesCompact
    @Setting(\.tapPostsToCollapse) var tapPostsToCollapse
    
    @Setting(\.readPostIndicator) var readPostIndicator
    
    var body: some View {
        Form {
            PostSizePicker()
            if UIDevice.isPad {
                Toggle("Multiple Columns", systemImage: "square.grid.2x2", isOn: $allowMultipleColumns)
            }
            
            Section {
                NavigationLink(.settings(.interactionBar(.post))) {
                    SettingsInteractionBarSummaryView(configuration: InteractionBarTracker.main.postInteractionBar)
                }
                NavigationLink("Swipe Actions", destination: .settings(.swipeActions(.post)))
            }
            
            Section {
                NavigationLink(
                    "Subscription Indicator",
                    value: showSubscribedStatus ? .init(localized: "On") : .init(localized: "Off"),
                    fallbackValue: "",
                    systemImage: Icons.subscribedFeed,
                    destination: .settings(.postSubscriptionIndicator)
                )
                
                if postSize == .headline || postSize == .compact {
                    NavigationLink(
                        "Thumbnail",
                        value: .init(localized: thumbnailLocation.label),
                        fallbackValue: "",
                        systemImage: Icons.thumbnail,
                        destination: .settings(.postThumbnail)
                    )
                }
                
                if postSize == .compact {
                    Toggle("Show Downvotes Separately", systemImage: Icons.votes, isOn: $showDownvotesCompact)
                }
                
                if differentiateWithoutColor {
                    NavigationLink(
                        "Read Indicator",
                        value: .init(localized: readPostIndicator.label),
                        fallbackValue: "",
                        systemImage: Icons.readIndicatorSetting,
                        destination: .settings(.postReadIndicator)
                    )
                }
            }
            
            Section {
                Toggle("Tap to Collapse", systemImage: Icons.collapseComment, isOn: $tapPostsToCollapse)
            }
            
            if postSize != .tile, postSize != .compact {
                Section {
                    Toggle("Always Show Usernames", systemImage: Icons.author, isOn: $showCreator)
                }
            }
        }
        .labelStyle(.conditional)
        .navigationTitle("Posts")
    }
}
