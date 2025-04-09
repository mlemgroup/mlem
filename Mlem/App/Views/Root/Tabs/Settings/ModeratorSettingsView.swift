//
//  ModeratorSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 01/10/2024.
//

import SwiftUI

struct ModeratorSettingsView: View {
    @Setting(\.menus_modActionGrouping) var moderatorActionGrouping
    @Setting(\.menus_allModActions) var showAllModActions
    @Setting(\.tab_inbox_badgeIncludedTypes) var tabInboxBadgeIncludedTypes
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Moderation",
                description: "Manage settings related to content moderation.",
                systemImage: Icons.moderationFill
            )
            .tint(.themedModeration)
            Section {
                NavigationLink(
                    "Moderator Actions",
                    value: .init(localized: moderatorActionGrouping.label),
                    fallbackValue: "",
                    systemImage: Icons.menuItems,
                    destination: .settings(.separateModeratorActions)
                )
            }
            Section {
                Toggle("Show All Actions in Feed", systemImage: Icons.menuCircle, isOn: $showAllModActions)
            } footer: {
                Text("When disabled, some moderator actions will only be accessible from the post page.")
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
            Section {
                NavigationLink(
                    "Mod Mail Action Layouts",
                    systemImage: Icons.interactionBar,
                    destination: .settings(.modMailInteractionBar)
                )
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Moderation")
    }
}

enum ModeratorActionGrouping: String, Codable, CaseIterable {
    case divider, disclosureGroup, separateMenu
    
    init?(rawValue: String) {
        switch rawValue {
        // Decode v1 case
        case "none", "divider":
            self = .divider
        case "disclosureGroup":
            self = .disclosureGroup
        case "separateMenu":
            self = .separateMenu
        default:
            return nil
        }
    }
    
    var label: LocalizedStringResource {
        switch self {
        case .divider: "Divider"
        case .disclosureGroup: "Disclosure Group"
        case .separateMenu: "Separate Menu"
        }
    }
    
    var systemImage: String {
        switch self {
        case .divider: "minus"
        case .disclosureGroup: Icons.dropDown
        case .separateMenu: Icons.moderation
        }
    }
}
