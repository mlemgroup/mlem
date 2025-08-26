//
//  ModeratorActionSeparationSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-01.
//

import SwiftUI

struct ModeratorActionSeparationSettingsView: View {
    @Setting(\.menus_modActionGrouping) var moderatorActionGrouping
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Moderator Actions",
                description: "Customize how moderator actions are separated from regular actions in context menus."
            ) {}
            Section {
                Picker("Separate Actions Using", icon: .settings.menuItems, selection: $moderatorActionGrouping) {
                    ForEach(ModeratorActionGrouping.allCases, id: \.self) { item in
                        Label(item.label.key, icon: item.icon)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Moderator Actions")
    }
}
