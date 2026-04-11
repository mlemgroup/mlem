//
//  ModeratorSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 01/10/2024.
//

import Icons
import SwiftUI
import Theming

struct ModeratorSettingsView: View {
    @Setting(\.menus_modActionGrouping) var moderatorActionGrouping
    @Setting(\.menus_allModActions) var showAllModActions
    @Setting(\.tab_inbox_badgeIncludedTypes) var tabInboxBadgeIncludedTypes
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Moderation",
                description: "Manage settings related to content moderation.",
                icon: .lemmy.moderation
            )
            .gradientTint(.themedModeration)
            Section {
                NavigationLink(
                    "Moderator Actions",
                    value: .init(localized: moderatorActionGrouping.label),
                    fallbackValue: "",
                    icon: .settings.menuItems,
                    destination: .settings(.separateModeratorActions)
                )
            }
            Section {
                Toggle("Show All Actions in Feed", icon: .general.menu, isOn: $showAllModActions)
                    .symbolVariant(.circle)
            } footer: {
                Text("When disabled, some moderator actions will only be accessible from the post page.")
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
            Section {
                NavigationLink(
                    "Mod Mail Action Layouts",
                    icon: .settings.interactionBar,
                    destination: .settings(.modMailInteractionBar)
                )
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Moderation")
    }
}

enum ModeratorActionGrouping: String, Codable, CaseIterable {
    case divider, separateMenu
    
    init?(rawValue: String) {
        switch rawValue {
        // Decode v1 case
        case "none", "divider", "disclosureGroup":
            self = .divider
        case "separateMenu":
            self = .separateMenu
        default:
            return nil
        }
    }
    
    var label: LocalizedStringResource {
        switch self {
        case .divider: "Divider"
        case .separateMenu: "Separate Menu"
        }
    }
    
    var icon: Icon {
        switch self {
        case .divider: .general.remove
        case .separateMenu: .lemmy.moderation
        }
    }
}
