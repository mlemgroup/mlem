//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-05.
//

import Icons
import SwiftUI
import Theming

struct TabBarSettingsView: View {
    @Environment(AppState.self) var appState
    
    @Setting(\.tab_profile_labelType) var profileTabLabel: ProfileTabLabel
    @Setting(\.tab_profile_showAvatar) var showUserAvatar: Bool
    @Setting(\.tab_gestures_longPressAction) var longPressAction: TabBarLongPressAction
    @Setting(\.tab_inbox_badgeIncludedTypes) var tabInboxBadgeIncludedTypes
    
    var account: any Account {
        appState.firstAccount
    }
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Tab Bar",
                description: "Customize the appearance of the tab bar.",
                icon: .settings.tabBar
            )
            .gradientTint(.themedColorfulAccent(5))
            Section("Profile Tab Label") {
                Picker("Profile Tab Label", selection: $profileTabLabel) {
                    profileTabLabelItem("Name", value: account.nickname, icon: .lemmy.alphabeticalSort)
                        .tag(ProfileTabLabel.nickname)
                    profileTabLabelItem("Instance", value: account.host, icon: .settings.qualifiedLabel)
                        .tag(ProfileTabLabel.instance)
                    profileTabLabelItem("Anonymous", value: .init(localized: "Profile"), icon: .general.circle)
                        .tag(ProfileTabLabel.anonymous)
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            Section {
                Toggle("Show Avatar", icon: .lemmy.person, isOn: $showUserAvatar)
                    .symbolVariant(.circle)
            }
            
            if !UIDevice.isIos26 {
                Section {
                    NavigationLink(
                        "Long Press Action",
                        value: .init(localized: longPressAction.label),
                        fallbackValue: "",
                        icon: .settings.longPress,
                        destination: .settings(.longPressAction)
                    )
                }
            }
                
            Section {
                NavigationLink(
                    "Notification Badge",
                    value: tabInboxBadgeIncludedTypes.label(accountType: AccountsTracker.main.highestLevelAccountType),
                    fallbackValue: .init(localized: "Some"),
                    icon: .settings.unreadBadge,
                    destination: .settings(.inboxBadge)
                )
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Tab Bar")
    }
    
    @ViewBuilder
    func profileTabLabelItem(_ title: LocalizedStringKey, value: String, icon: Icon) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(title)
                Text(value)
                    .font(.footnote)
                    .foregroundStyle(.themedSecondary)
            }
        } icon: {
            Image(icon: icon)
        }
    }
}

enum ProfileTabLabel: String, Codable, CaseIterable {
    case nickname, instance, anonymous
}
