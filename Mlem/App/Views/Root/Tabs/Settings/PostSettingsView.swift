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
                if postSize == .headline || postSize == .compact {
                    NavigationLink(
                        "Thumbnail",
                        value: .init(localized: thumbnailLocation.label),
                        fallbackValue: "",
                        destination: .settings(.postThumbnail)
                    )
                }
                NavigationLink(.settings(.postInteractionBar)) {
                    SettingsInteractionBarSummaryView(configuration: InteractionBarTracker.main.postInteractionBar)
                }
                NavigationLink(
                    "Subscription Indicator",
                    value: showSubscribedStatus ? "On" : "Off",
                    fallbackValue: "",
                    destination: .settings(.postSubscriptionIndicator)
                )
                if differentiateWithoutColor {
                    NavigationLink(
                        "Read Indicator",
                        value: .init(localized: readPostIndicator.label),
                        fallbackValue: "",
                        destination: .settings(.postReadIndicator)
                    )
                }
            }
            
            if postSize != .tile, postSize != .compact {
                Section {
                    Toggle(isOn: $showCreator) {
                        Text("Always Show Usernames")
                    }
                }
            }
            
            Section {
                Toggle(isOn: $showPersonAvatar) {
                    Text("User Avatar")
                }
                Toggle(isOn: $showCommunityAvatar) {
                    Text("Community Avatar")
                }
            }
        }
        .navigationTitle("Posts")
    }
}
