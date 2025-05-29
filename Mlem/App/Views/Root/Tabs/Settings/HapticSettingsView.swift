//
//  HapticSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-31.
//

import Haptics
import SwiftUI

struct HapticSettingsView: View {
    @Setting(\.behavior_hapticLevel) var hapticLevel
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Haptics",
                description: "Customize how often Mlem plays haptic feedback.",
                icon: .general.haptics
            )
            .tint(.themedColorfulAccent(1))
            Picker("Haptic Level", selection: $hapticLevel) {
                ForEach(HapticLevel.allCases, id: \.self) { level in
                    Text(level.label)
                }
                Text("None").tag(nil as HapticLevel?)
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .contentMargins(.top, 16)
        .labelStyle(.conditional)
        .hiddenNavigationTitle("Haptics")
    }
}
