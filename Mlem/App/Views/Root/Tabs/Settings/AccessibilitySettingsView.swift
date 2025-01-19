//
//  AccessibilitySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-19.
//

import SwiftUI

struct AccessibilitySettingsView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor: Bool

    @Setting(\.readPostIndicator) var readPostIndicator
    
    var body: some View {
        Form {
            if differentiateWithoutColor {
                NavigationLink(
                    "Post Read Indicator",
                    value: .init(localized: readPostIndicator.label),
                    fallbackValue: "",
                    destination: .settings(.postReadIndicator)
                )
            }
        }
        .navigationTitle("Accessibility")
    }
}
