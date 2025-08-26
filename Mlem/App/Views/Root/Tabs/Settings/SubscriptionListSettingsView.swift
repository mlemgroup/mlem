//
//  SubscriptionListSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 23/06/2024.
//

import SwiftUI

struct SubscriptionListSettingsView: View {
    @Setting(\.subscriptions_sort) private var sort
    @Setting(\.subscriptions_instanceLocation) var instanceLocation
    @Setting(\.navigation_sidebarVisibleByDefault) var sidebarVisibleByDefault

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Subscription List",
                description: "Customize how your subscription list is sorted.",
                icon: .lemmy.subscriptionList
            )
            .tint(.themedCommunityAccent)
            Section("Sort by...") {
                Picker("Sort by...", selection: $sort) {
                    ForEach(SubscriptionListSort.allCases, id: \.self) { item in
                        Label(String(localized: item.label), icon: item.icon)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            if sort == .alphabetical {
                Section("Row Size") {
                    Picker("Row Size", icon: .settings.qualifiedLabel, selection: $instanceLocation) {
                        Label("Large", icon: .settings.postSizeLarge).tag(InstanceLocation.bottom)
                        Label("Compact", icon: .settings.postSizeCompact).tag(InstanceLocation.trailing)
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
            }
            if UIDevice.isPad {
                Toggle("Show Sidebar on App Launch", icon: .settings.sidebar, isOn: $sidebarVisibleByDefault)
            }
        }
        .animation(.easeOut(duration: 0.1), value: sort)
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Subscription List")
    }
}
