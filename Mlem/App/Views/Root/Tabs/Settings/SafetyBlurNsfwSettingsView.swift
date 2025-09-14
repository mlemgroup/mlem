//
//  SafetyBlurNsfwSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-24.
//

import SwiftUI
import Theming

struct SafetyBlurNsfwSettingsView: View {
    @Setting(\.safety_blurNsfw) var blurNsfw
    
    var body: some View {
        Form {
            headerView
            Picker("Blur NSFW Content", selection: $blurNsfw) {
                ForEach(NsfwBlurBehavior.allCases, id: \.self) { type in
                    Label(String(localized: type.label), icon: type.icon)
                        .symbolVariant(.circle)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .contentMargins(.top, 16)
        .withConditionalLabelStyle()
        .hiddenNavigationTitle("Blur NSFW Content")
    }
    
    @ViewBuilder
    var headerView: some View {
        SettingsHeaderView(
            title: "Blur NSFW Content",
            description: "Choose when Not Safe For Work content should be blurred.",
            icon: .general.hide
        )
        .gradientTint(ThemedColor.themedWarning)
    }
}
