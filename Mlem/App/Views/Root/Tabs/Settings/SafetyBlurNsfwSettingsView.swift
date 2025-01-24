//
//  SafetyBlurNsfwSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-24.
//

import SwiftUI

struct SafetyBlurNsfwSettingsView: View {
    @Environment(Palette.self) var palette
    @Setting(\.blurNsfw) var blurNsfw
    
    var body: some View {
        Form {
            headerView
            Picker("Blur NSFW Content", selection: $blurNsfw) {
                ForEach(NsfwBlurBehavior.allCases, id: \.self) { type in
                    Label(String(localized: type.label), systemImage: type.systemImage)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .contentMargins(.top, 16)
        .labelStyle(.conditional)
    }
    
    @ViewBuilder
    var headerView: some View {
        SettingsHeaderView(
            title: "Blur NSFW Content",
            description: "Choose when Not Safe For Work content should be blurred.",
            systemImage: Icons.blurNsfw
        )
        .tint(palette.warning)
    }
}
