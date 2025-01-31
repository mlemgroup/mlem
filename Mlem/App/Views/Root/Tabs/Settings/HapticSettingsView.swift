//
//  HapticSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-31.
//

import SwiftUI

struct HapticSettingsView: View {
    @Environment(Palette.self) var palette
    @Setting(\.hapticLevel) var hapticLevel
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Haptics",
                description: "Customize how often Mlem plays haptic feedback.",
                systemImage: Icons.haptics
            )
            .tint(palette.colorfulAccent(1))
            Picker("Haptic Level", selection: $hapticLevel) {
                ForEach(HapticPriority.allCases, id: \.self) { item in
                    Text(item.label)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .contentMargins(.top, 16)
        .labelStyle(.conditional)
    }
}
