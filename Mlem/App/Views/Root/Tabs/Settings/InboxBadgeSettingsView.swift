//
//  InboxBadgeSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-17.
//

import MlemMiddleware
import SwiftUI

struct InboxBadgeSettingsView: View {
    @Setting(\.tabInboxBadgeIncludedTypes) var tabInboxBadgeIncludedTypes
    
    var body: some View {
        Form {
            headerView
            Section {
                toggle(forType: .reply)
                toggle(forType: .mention)
                toggle(forType: .message)
            }
            if AccountsTracker.main.highestLevelAccountType >= .moderator {
                Section {
                    toggle(forType: .postReport)
                    toggle(forType: .commentReport)
                    if AccountsTracker.main.highestLevelAccountType == .admin {
                        toggle(forType: .messageReport)
                        toggle(forType: .registrationApplication)
                    }
                }
            }
        }
        .contentMargins(.top, 16, for: .scrollContent)
        .labelStyle(.conditional)
    }
    
    @ViewBuilder
    var headerView: some View {
        SettingsHeaderView(
            title: "Notification Badge",
            description: "Configure which types of notification should be included in the notification badge."
        ) {
            Image(systemName: Icons.inboxFill)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64)
                .foregroundStyle(.tertiary)
                .padding([.horizontal, .top], 20)
                .overlay(alignment: .topTrailing) {
                    Text(verbatim: "1")
                        .font(.title2)
                        .foregroundStyle(.themedContrastingLabel)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(10)
                        .background(.themedWarning, in: .circle)
                }
        }
    }
    
    @ViewBuilder
    func toggle(forType type: InboxItemType) -> some View {
        Toggle(String(localized: type.label), systemImage: type.systemImage, isOn: .init(
            get: { tabInboxBadgeIncludedTypes.contains(type) },
            set: {
                if $0 {
                    tabInboxBadgeIncludedTypes.insert(type)
                } else {
                    tabInboxBadgeIncludedTypes.remove(type)
                }
            }
        ))
    }
}
