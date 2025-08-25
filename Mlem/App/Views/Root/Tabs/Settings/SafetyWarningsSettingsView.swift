//
//  SafetyWarningsSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-24.
//

import SwiftUI

struct SafetyWarningsSettingsView: View {
    @Setting(\.safety_enableNsfwCommunityWarning) var showNsfwCommunityWarning
    @Setting(\.safety_enableModlogWarning) var showModlogWarning

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Content Warnings",
                description: "Choose whether to show a warning when opening a page that is likely to contain sensitive content.",
                icon: .general.warning
            )
            .tint(.themedWarning)
            Section("Show warnings when opening...") {
                Toggle("NSFW Communities", icon: .lemmy.community, isOn: $showNsfwCommunityWarning)
                Toggle("Modlogs", icon: .lemmy.modlog, isOn: $showModlogWarning)
            }
        }
        .contentMargins(.top, 16)
                .labelStyle(.conditional)
        .toggleStyle(.conditional)
        .hiddenNavigationTitle("Content Warnings")
    }
}
