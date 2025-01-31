//
//  AccessibilitySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-19.
//

import SwiftUI

struct AccessibilitySettingsView: View {
    @Environment(Palette.self) var palette
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor: Bool

    @Setting(\.readPostIndicator) var readPostIndicator
    @Setting(\.websiteThumbnailIcon) var websiteThumbnailIcon
    @Setting(\.showSettingsIcons) var showSettingsIcons
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Accessibility",
                // swiftlint:disable:next line_length
                description: "Personalize Mlem in ways that work best for you. Some features are tied to system-wide accessibility settings.",
                systemImage: "hand.point.up.braille.fill"
            )
            .tint(palette.colorfulAccent(2))
            if differentiateWithoutColor {
                Section {
                    NavigationLink(
                        "Post Read Indicator",
                        value: .init(localized: readPostIndicator.label),
                        fallbackValue: "",
                        systemImage: Icons.read,
                        destination: .settings(.postReadIndicator)
                    )
                }
            }
            
            Section {
                Toggle("Website Thumbnail Indicator", systemImage: Icons.browser, isOn: $websiteThumbnailIcon)
                Toggle("Settings Icons", systemImage: Icons.icon, isOn: $showSettingsIcons)
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
