//
//  SubscriptionListSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 23/06/2024.
//

import SwiftUI

struct SubscriptionListSettingsView: View {
    @Environment(Palette.self) var palette
    
    @Setting(\.subscriptionSort) private var sort
    @Setting(\.subscriptionInstanceLocation) var instanceLocation
    @Setting(\.sidebarVisibleByDefault) var sidebarVisibleByDefault

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Subscription List",
                description: "Customize how your subscription list is sorted.",
                systemImage: "list.bullet"
            )
            .tint(palette.communityAccent)
            Section("Sort by...") {
                Picker("Sort by...", selection: $sort) {
                    ForEach(SubscriptionListSort.allCases, id: \.self) { item in
                        Label(String(localized: item.label), systemImage: item.systemImage)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            if sort == .alphabetical {
                Section("Row Size") {
                    Picker("Row Size", systemImage: Icons.qualifiedLabel, selection: $instanceLocation) {
                        Label("Large", systemImage: "rectangle.expand.vertical").tag(InstanceLocation.bottom)
                        Label("Compact", systemImage: "rectangle.compress.vertical").tag(InstanceLocation.trailing)
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
            }
            if UIDevice.isPad {
                Toggle("Show Sidebar on App Launch", systemImage: Icons.sidebar, isOn: $sidebarVisibleByDefault)
            }
        }
        .animation(.easeOut(duration: 0.1), value: sort)
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
