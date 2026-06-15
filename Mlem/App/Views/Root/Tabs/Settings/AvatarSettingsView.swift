//
//  AvatarSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-08.
//

import SwiftUI
import Theming

struct AvatarSettingsView: View {
    @Setting(\.person_showAvatar) var showPersonAvatar
    @Setting(\.community_showAvatar) var showCommunityAvatar
    @Setting(\.media_animatedAvatars) var animatedAvatars
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Avatars",
                description: "Choose whether avatars should be shown, and whether they should animate.",
                icon: .settings.avatar
            )
            .gradientTint(.themedColorfulAccent(4))
            
            Section("Show avatars for...") {
                Toggle("Users", icon: .lemmy.person, isOn: $showPersonAvatar)
                    .symbolVariant(.circle)
                Toggle("Communities", icon: .lemmy.community, isOn: $showCommunityAvatar)
                    .symbolVariant(.circle)
            }
            Section {
                NavigationLink(
                    "Animated Avatars",
                    value: .init(localized: animatedAvatars.label),
                    fallbackValue: "",
                    icon: .general.playCircle,
                    destination: .settings(.animatedAvatars)
                )
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Avatars")
    }
}
