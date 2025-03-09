//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-05.
//

import SwiftUI

struct TabBarSettingsView: View {
    @Environment(AppState.self) var appState
    
    @Setting(\.tabProfileLabelType) var profileTabLabel: ProfileTabLabel
    @Setting(\.tabProfileShowAvatar) var showUserAvatar: Bool
    @Setting(\.tabInboxBadgeIncludedTypes) var tabInboxBadgeIncludedTypes
    
    var account: any Account {
        appState.firstAccount
    }
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Tab Bar",
                description: "Customize the appearance of the tab bar.",
                systemImage: "platter.filled.bottom.iphone"
            )
            .tint(.themedColorfulAccent(5))
            Section("Profile Tab Label") {
                Picker("Profile Tab Label", selection: $profileTabLabel) {
                    profileTabLabelItem("Name", value: account.nickname, systemImage: Icons.alphabeticalSort)
                        .tag(ProfileTabLabel.nickname)
                    profileTabLabelItem("Instance", value: account.host, systemImage: Icons.qualifiedLabel)
                        .tag(ProfileTabLabel.instance)
                    profileTabLabelItem("Anonymous", value: .init(localized: "Profile"), systemImage: "circle")
                        .tag(ProfileTabLabel.anonymous)
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            Section {
                Toggle("Show Avatar", systemImage: Icons.personCircle, isOn: $showUserAvatar)
            }
            Section {
                NavigationLink(
                    "Notification Badge",
                    value: tabInboxBadgeIncludedTypes.label(accountType: AccountsTracker.main.highestLevelAccountType),
                    fallbackValue: .init(localized: "Some"),
                    systemImage: Icons.unreadBadge,
                    destination: .settings(.inboxBadge)
                )
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
    
    @ViewBuilder
    func profileTabLabelItem(_ title: LocalizedStringKey, value: String, systemImage: String) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(title)
                Text(value)
                    .font(.footnote)
                    .foregroundStyle(.themedSecondary)
            }
        } icon: {
            Image(systemName: systemImage)
        }
    }
}

enum ProfileTabLabel: String, Codable, CaseIterable {
    case nickname, instance, anonymous
}
