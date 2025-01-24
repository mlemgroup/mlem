//
//  SafetyWarningsSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-24.
//

import SwiftUI

struct SafetyWarningsSettingsView: View {
    @Environment(Palette.self) var palette
    
    @Setting(\.showNsfwCommunityWarning) var showNsfwCommunityWarning
    @Setting(\.showModlogWarning) var showModlogWarning

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Content Warnings",
                description: "Choose whether to show a warning when opening a page that is likely to contain sensitive content.",
                systemImage: Icons.warning
            )
            .tint(palette.warning)
            Section("Show warnings when opening...") {
                Toggle("NSFW Communities", systemImage: Icons.community, isOn: $showNsfwCommunityWarning)
                Toggle("Modlogs", systemImage: Icons.modlog, isOn: $showModlogWarning)
            }
        }
        .contentMargins(.top, 16)
        .labelStyle(.conditional)
    }
}
