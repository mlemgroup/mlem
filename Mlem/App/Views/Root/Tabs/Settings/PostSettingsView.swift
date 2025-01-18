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
    
    @Setting(\.postSize) var postSize
    @Setting(\.thumbnailLocation) var thumbnailLocation
    @Setting(\.showPostCreator) var showCreator
    @Setting(\.showPersonAvatar) var showPersonAvatar
    @Setting(\.showCommunityAvatar) var showCommunityAvatar
    @Setting(\.showSubscribedStatus) var showSubscribedStatus
    
    var body: some View {
        Form {
            PostSizePicker()
            Section {
                if postSize == .headline || postSize == .compact {
                    NavigationLink("Thumbnail", value: "Left", fallbackValue: "", destination: .inbox)
                }
                NavigationLink(.settings(.postInteractionBar)) {
                    SettingsInteractionBarSummaryView(configuration: InteractionBarTracker.main.postInteractionBar)
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
            Section {
                NavigationLink("Subscription Indicator", value: "On", fallbackValue: "", destination: .inbox)
            }
        }
        .navigationTitle("Posts")
    }
}
