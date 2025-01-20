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
    @Environment(Palette.self) var palette
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor: Bool
    
    @Setting(\.postSize) var postSize
    @Setting(\.thumbnailLocation) var thumbnailLocation
    @Setting(\.showPostCreator) var showCreator
    @Setting(\.showPersonAvatar) var showPersonAvatar
    @Setting(\.showCommunityAvatar) var showCommunityAvatar
    @Setting(\.showSubscribedStatus) var showSubscribedStatus
    
    @Setting(\.readPostIndicator) var readPostIndicator
    
    var body: some View {
        Form {
            PostSizePicker()
            
            Section {
                NavigationLink(.settings(.postInteractionBar)) {
                    SettingsInteractionBarSummaryView(configuration: InteractionBarTracker.main.postInteractionBar)
                }
            }
            
            Section {
                if postSize == .headline || postSize == .compact {
                    NavigationLink(
                        "Thumbnail",
                        value: .init(localized: thumbnailLocation.label),
                        fallbackValue: "",
                        systemImage: Icons.thumbnail,
                        destination: .settings(.postThumbnail)
                    )
                }
                
                NavigationLink(
                    "Subscription Indicator",
                    value: showSubscribedStatus ? "On" : "Off",
                    fallbackValue: "",
                    systemImage: Icons.subscribedFeed,
                    destination: .settings(.postSubscriptionIndicator)
                )
                
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
                Toggle("User Avatar", systemImage: Icons.personCircle, isOn: $showPersonAvatar)
                Toggle("Community Avatar", systemImage: Icons.communityCircle, isOn: $showCommunityAvatar)
            }
            
            if postSize != .tile, postSize != .compact {
                Section {
                    Toggle("Always Show Usernames", systemImage: Icons.author, isOn: $showCreator)
                }
            }
        }
        .navigationTitle("Posts")
        .labelStyle(ConditionalIconLabelStyle())
    }
}
