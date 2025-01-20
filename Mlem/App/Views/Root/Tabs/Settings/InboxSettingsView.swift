//
//  InboxSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct InboxSettingsView: View {
    @Setting(\.tabInboxBadgeIncludedTypes) var tabInboxBadgeIncludedTypes
    
    var body: some View {
        Form {
            Section {
                NavigationLink(
                    "Customize Interaction Bar",
                    systemImage: Icons.interactionBar,
                    destination: .settings(.replyInteractionBar)
                )
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
        .navigationTitle("Inbox")
    }
}
