//
//  InboxBadgeSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-17.
//

import MlemMiddleware
import SwiftUI

struct InboxBadgeSettingsView: View {
    @Setting(\.tab_inbox_badgeIncludedTypes) var tabInboxBadgeIncludedTypes
    
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
        .withConditionalLabelStyle()
        .hiddenNavigationTitle("Notification Badge")
    }
    
    @ViewBuilder
    var headerView: some View {
        SettingsHeaderView(
            title: "Notification Badge",
            description: "Configure which types of notification should be included in the notification badge."
        ) {
            Image(icon: .lemmy.inbox)
                .resizable()
                .symbolVariant(.fill)
                .aspectRatio(contentMode: .fit)
                .frame(width: 64)
                .foregroundStyle(.tertiary)
                .padding([.trailing, .top], 20)
                .overlay(alignment: .topTrailing) {
                    Text(verbatim: "1")
                        .font(.title2)
                        .foregroundStyle(.themedContrastingLabel)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(10)
                        .background(.themedWarning, in: .circle)
                }
                .padding(.top, -10)
        }
    }
    
    @ViewBuilder
    func toggle(forType type: InboxItemType) -> some View {
        Toggle(type.label, icon: type.icon, isOn: .init(
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
