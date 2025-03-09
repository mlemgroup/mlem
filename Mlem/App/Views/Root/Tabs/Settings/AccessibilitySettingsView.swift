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
    @Setting(\.websiteThumbnailIcon) var websiteThumbnailIcon
    @Setting(\.showSettingsIcons) var showSettingsIcons
    @Setting(\.zoomSliderLocation) var zoomSliderLocation
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Accessibility",
                description: "Customize Mlem to work best for you. Some features are tied to system-wide accessibility settings.",
                systemImage: "hand.point.up.braille.fill"
            )
            .tint(.themedColorfulAccent(2))
            if differentiateWithoutColor {
                Section {
                    NavigationLink(
                        "Post Read Indicator",
                        value: .init(localized: readPostIndicator.label),
                        fallbackValue: "",
                        systemImage: Icons.read,
                        destination: .settings(.postReadIndicator)
                    )
                } header: {
                    Text("Differentiate Without Color")
                }
            }
            
            Section {
                Toggle("Website Thumbnail Indicator", systemImage: Icons.browser, isOn: $websiteThumbnailIcon)
                Toggle("Settings Icons", systemImage: Icons.icon, isOn: $showSettingsIcons)
            } header: {
                Text("Non-Text Indicators")
            }
            
            Section {
                NavigationLink(
                    "Slide to Zoom Images",
                    value: .init(localized: zoomSliderLocation.label),
                    fallbackValue: "",
                    systemImage: Icons.zoomSlider,
                    destination: .settings(.zoomSlider)
                )
            } header: {
                Text("Gestures")
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
