//
//  InstanceSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-05-29.
//

import SwiftUI

struct InstanceSettingsView: View {
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Instances",
                description: "Customize the appearance of instances.",
                icon: .lemmy.instance
            )
            .gradientTint(.themedInstanceAccent)
            Section {
                NavigationLink("Swipe Actions", destination: .settings(.swipeActions(.instance)))
                NavigationLink("Context Menu", destination: .settings(.contextMenu(\.interactionBar_instance)))
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Instances")
    }
}
