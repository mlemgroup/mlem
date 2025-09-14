//
//  HapticSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-31.
//

import Haptics
import SwiftUI
import Theming

struct HapticSettingsView: View {
    @Setting(\.behavior_hapticLevel) var hapticLevel
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Haptics",
                description: "Customize how often Mlem plays haptic feedback.",
                icon: .general.haptics
            )
            .gradientTint(.themedColorfulAccent(1))
            Picker("Haptic Level", selection: $hapticLevel) {
                ForEach(HapticTier.allCases, id: \.self) { level in
                    Text(level.label)
                        .tag(level as HapticTier?)
                }
                Text("None").tag(nil as HapticTier?)
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .contentMargins(.top, 16)
        .withConditionalLabelStyle()
        .hiddenNavigationTitle("Haptics")
    }
}
