//
//  ModeratorActionSeparationSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-01.
//

import SwiftUI

struct ModeratorActionSeparationSettingsView: View {
    @Setting(\.moderatorActionGrouping) var moderatorActionGrouping
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Moderator Actions",
                description: "Customize how moderator actions are separated from regular actions in context menus."
            ) {}
            Section {
                Picker("Separate Actions Using", systemImage: Icons.menuItems, selection: $moderatorActionGrouping) {
                    ForEach(ModeratorActionGrouping.allCases, id: \.self) { item in
                        Label(String(localized: item.label), systemImage: item.systemImage)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
