//
//  GeneralSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import Dependencies
import SwiftUI

struct GeneralSettingsView: View {
    // behavior
    @Setting(\.upvoteOnSave) var upvoteOnSave
    @Setting(\.markReadOnScroll) var markReadOnScroll
    @Setting(\.infiniteScroll) var infiniteScroll
    @Setting(\.defaultFeed) var defaultFeed
    @Setting(\.sidebarVisibleByDefault) var sidebarVisibleByDefault
    @Setting(\.hapticLevel) var hapticLevel
    @Setting(\.wrapCodeBlockLines) var wrapCodeBlockLines
    
    // gestures
    @Setting(\.quickSwipesEnabled) var swipeActionsEnabled
    @Setting(\.swipeAnywhereToNavigate) var swipeAnywhereToNavigate
    
    // avatars
    @Setting(\.showPersonAvatar) var showPersonAvatar
    @Setting(\.showCommunityAvatar) var showCommunityAvatar
    
    var body: some View {
        Form {
            Section {
                Picker("Default Feed", systemImage: Icons.feeds, selection: $defaultFeed) {
                    ForEach(FeedSelection.allCases, id: \.self) { item in
                        Text(item.rawValue.capitalized)
                    }
                }
                if UIDevice.isPad {
                    Toggle("Show Sidebar on App Launch", systemImage: Icons.sidebar, isOn: $sidebarVisibleByDefault)
                }
                Toggle("Mark Read on Scroll", systemImage: Icons.read, isOn: $markReadOnScroll)
                Toggle("Infinite Scroll", systemImage: Icons.infiniteScroll, isOn: $infiniteScroll)
                Toggle("Upvote on Save", systemImage: Icons.upvoteOnSave, isOn: $upvoteOnSave)
                Picker("Haptic Level", systemImage: Icons.haptics, selection: $hapticLevel) {
                    ForEach(HapticPriority.allCases, id: \.self) { item in
                        Text(item.label)
                    }
                }
                Toggle("Wrap Code Block Lines", systemImage: Icons.inlineCode, isOn: $wrapCodeBlockLines)
            } header: {
                Text("Behavior")
            }
            
            Section("Gestures") {
                Toggle(
                    "Swipe Actions",
                    systemImage: Icons.swipeActions,
                    isOn: .init(
                        get: { swipeActionsEnabled },
                        set: {
                            swipeActionsEnabled = $0
                            if $0 {
                                swipeAnywhereToNavigate = false
                            }
                        }
                    )
                )
                Toggle(
                    "Swipe Anywhere to Navigate",
                    systemImage: Icons.swipeAnywhere,
                    isOn: .init(
                        get: { swipeAnywhereToNavigate },
                        set: {
                            swipeAnywhereToNavigate = $0
                            if $0 {
                                swipeActionsEnabled = false
                            }
                        }
                    )
                )
            }
            
            Section("Avatars") {
                Toggle("User Avatar", systemImage: Icons.personCircle, isOn: $showPersonAvatar)
                Toggle("Community Avatar", systemImage: Icons.communityCircle, isOn: $showCommunityAvatar)
            }
            
            NavigationLink("Import/Export Settings", systemImage: Icons.importSettings, destination: .settings(.importExportSettings))
        }
        .labelStyle(.conditional)
        .navigationTitle("General")
    }
}
