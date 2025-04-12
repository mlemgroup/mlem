//
//  AccessibilitySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-19.
//

import SwiftUI

struct AccessibilitySettingsView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor: Bool

    @Setting(\.a11y_readPostIndicator) var readPostIndicator
    @Setting(\.a11y_websiteThumbnailIcon) var websiteThumbnailIcon
    @Setting(\.a11y_showSettingsIcons) var showSettingsIcons
    @Setting(\.a11y_zoomSliderLocation) var zoomSliderLocation
    @Setting(\.media_animatedAvatars) var animatedAvatars
    
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
                       
            if #available(iOS 18, *) {
                Section {
                    NavigationLink(
                        "Animated Avatars",
                        value: .init(localized: animatedAvatars.label),
                        fallbackValue: "",
                        systemImage: Icons.playCircle,
                        destination: .settings(.animatedAvatars)
                    )
                } header: {
                    Text("Reduce Motion")
                }
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
        .hiddenNavigationTitle("Accessibility")
    }
}
