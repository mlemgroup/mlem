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
    @Setting(\.behavior_upvoteOnSave) var upvoteOnSave
    @Setting(\.feed_markReadOnScroll) var markReadOnScroll
    @Setting(\.behavior_infiniteScroll) var infiniteScroll
    @Setting(\.feed_default) var defaultFeed
    @Setting(\.behavior_hapticLevel) var hapticLevel
    @Setting(\.markdown_wrapCodeBlockLines) var wrapCodeBlockLines
    @Setting(\.person_ageVisibility) var accountAgeVisibility
    @Setting(\.media_animatedAvatars) var animatedAvatars

    // gestures
    @Setting(\.behavior_enableQuickSwipes) var swipeActionsEnabled
    @Setting(\.navigation_swipeAnywhere) var swipeAnywhereToNavigate
    
    // avatars
    @Setting(\.person_showAvatar) var showPersonAvatar
    @Setting(\.community_showAvatar) var showCommunityAvatar
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "General",
                description: "Manage your overall setup for Mlem.",
                icon: .settings.general
            )
            .tint(.themedNeutralAccent)
            Section {
                NavigationLink(
                    "Default Feed",
                    value: .init(localized: defaultFeed.label),
                    fallbackValue: "",
                    icon: .lemmy.feed,
                    destination: .settings(.defaultFeed)
                )
                NavigationLink(
                    "Haptics",
                    value: .init(localized: hapticLevel?.label ?? "None"),
                    fallbackValue: "",
                    icon: .general.haptics,
                    destination: .settings(.haptics)
                )
            }
            Section {
                Toggle("Upvote on Save", icon: .settings.upvoteOnSave, isOn: $upvoteOnSave)
                Toggle("Mark Read on Scroll", icon: .settings.markReadOnScroll, isOn: $markReadOnScroll)
                Toggle("Infinite Scroll", icon: .settings.infiniteScroll, isOn: $infiniteScroll)
                Toggle("Wrap Code Block Lines", icon: .markdown.inlineCode, isOn: $wrapCodeBlockLines)
            }
            Section {
                Toggle(
                    "Swipe Actions",
                    icon: .settings.swipeActions,
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
                    icon: .settings.swipeAnywhere,
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
                NavigationLink(
                    "Show Account Age",
                    value: .init(localized: accountAgeVisibility.label),
                    fallbackValue: "",
                    icon: .lemmy.newAccountFlair,
                    destination: .settings(.accountAgeVisibility)
                )
            }
            
            Section {
                Toggle("User Avatar", icon: .lemmy.person, isOn: $showPersonAvatar)
                    .symbolVariant(.circle)
                Toggle("Community Avatar", icon: .lemmy.community, isOn: $showCommunityAvatar)
                    .symbolVariant(.circle)
                if #available(iOS 18, *) {
                    NavigationLink(
                        "Animated Avatars",
                        value: .init(localized: animatedAvatars.label),
                        fallbackValue: "",
                        icon: .general.playCircle,
                        destination: .settings(.animatedAvatars)
                    )
                }
            }
            
            NavigationLink(
                "Import/Export Settings",
                icon: .general.import,
                destination: .settings(.importExportSettings)
            )
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("General")
    }
}
