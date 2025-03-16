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
    @Setting(\.hapticLevel) var hapticLevel
    @Setting(\.wrapCodeBlockLines) var wrapCodeBlockLines
    @Setting(\.animatedAvatars) var animatedAvatars
    
    // gestures
    @Setting(\.quickSwipesEnabled) var swipeActionsEnabled
    @Setting(\.swipeAnywhereToNavigate) var swipeAnywhereToNavigate
    
    // avatars
    @Setting(\.showPersonAvatar) var showPersonAvatar
    @Setting(\.showCommunityAvatar) var showCommunityAvatar
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "General",
                description: "Manage your overall setup for Mlem.",
                systemImage: "gear"
            )
            .tint(.themedNeutralAccent)
            Section {
                NavigationLink(
                    "Default Feed",
                    value: .init(localized: defaultFeed.label),
                    fallbackValue: "",
                    systemImage: Icons.feeds,
                    destination: .settings(.defaultFeed)
                )
                NavigationLink(
                    "Haptics",
                    value: .init(localized: hapticLevel.label),
                    fallbackValue: "",
                    systemImage: Icons.haptics,
                    destination: .settings(.haptics)
                )
            }
            Section {
                Toggle("Upvote on Save", systemImage: Icons.upvoteOnSave, isOn: $upvoteOnSave)
                Toggle("Mark Read on Scroll", systemImage: Icons.read, isOn: $markReadOnScroll)
                Toggle("Infinite Scroll", systemImage: Icons.infiniteScroll, isOn: $infiniteScroll)
                Toggle("Wrap Code Block Lines", systemImage: Icons.inlineCode, isOn: $wrapCodeBlockLines)
            }
            Section {
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
            
            Section {
                Toggle("User Avatar", systemImage: Icons.personCircle, isOn: $showPersonAvatar)
                Toggle("Community Avatar", systemImage: Icons.communityCircle, isOn: $showCommunityAvatar)
                if #available(iOS 18, *) {
                    NavigationLink(
                        "Animated Avatars",
                        value: .init(localized: animatedAvatars.label),
                        fallbackValue: "",
                        systemImage: Icons.playCircle,
                        destination: .settings(.animatedAvatars)
                    )
                }
            }
            
            NavigationLink("Import/Export Settings", systemImage: Icons.importSettings, destination: .settings(.importExportSettings))
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
