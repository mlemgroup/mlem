//
//  CommunitySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-05.
//

import SwiftUI

struct CommunitySettingsView: View {
    @Setting(\.community_showAvatar) var showCommunityAvatar

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Communities",
                description: "Customize the appearance of communities.",
                icon: .lemmy.community
            )
            .gradientTint(.themedCommunityAccent)
            Section {
                NavigationLink("Swipe Actions", destination: .settings(.swipeActions(.community)))
                NavigationLink("Context Menu", destination: .settings(.contextMenu(\.interactionBar_community)))
            }
            Section {
                NavigationLink("Subscription List", destination: .settings(.subscriptionList))
            }
            Section {
                Toggle("Community Avatar", icon: .lemmy.community, isOn: $showCommunityAvatar)
                    .symbolVariant(.circle)
            } footer: {
                Text("Choose whether to show community avatars on posts.")
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Communities")
    }
}
