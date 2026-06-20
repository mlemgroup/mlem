//
//  PersonSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-05-29.
//

import SwiftUI

struct PersonSettingsView: View {
    @Setting(\.person_showAvatar) var showPersonAvatar
    @Setting(\.person_ageVisibility) var accountAgeVisibility

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Users",
                description: "Customize the appearance of users.",
                icon: .lemmy.person
            )
            .gradientTint(.themedPersonAccent)
            Section {
                NavigationLink("Swipe Actions", destination: .settings(.swipeActions(.person)))
                NavigationLink("Context Menu", destination: .settings(.contextMenu(\.interactionBar_person)))
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
            } footer: {
                Text("Choose whether to show user avatars on posts.")
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Users")
    }
}
