//
//  InboxSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct InboxSettingsView: View {
    @Setting(\.tab_inbox_badgeIncludedTypes) var tabInboxBadgeIncludedTypes
    @Setting(\.interactionBar_reply) var replyInteractionBar
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Inbox",
                // swiftlint:disable:next line_length
                description: "Customize the interaction bar for inbox items, and choose which types of notification are included in the tab bar badge.",
                icon: .lemmy.inbox
            )
            .tint(.themedInbox)
            Section {
                NavigationLink(.settings(.interactionBar(.reply))) {
                    SettingsInteractionBarSummaryView(configuration: replyInteractionBar)
                }
                NavigationLink("Swipe Actions", destination: .settings(.swipeActions(.reply)))
            }
            if AccountsTracker.main.highestLevelAccountType >= .moderator {
                Section {
                    NavigationLink(
                        "Mod Mail Action Layouts",
                        icon: .settings.interactionBar,
                        destination: .settings(.modMailInteractionBar)
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
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Inbox")
    }
}
