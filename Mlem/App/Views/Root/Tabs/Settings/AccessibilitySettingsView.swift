//
//  AccessibilitySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-19.
//

import SwiftUI
import Theming

struct AccessibilitySettingsView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor: Bool

    @Setting(\.a11y_readPostIndicator) var readPostIndicator
    @Setting(\.a11y_websiteThumbnailIcon) var websiteThumbnailIcon
    @Setting(\.a11y_showSettingsIcons) var showSettingsIcons
    @Setting(\.a11y_zoomSliderLocation) var zoomSliderLocation
    @Setting(\.media_animatedAvatars) var animatedAvatars
    @Setting(\.a11y_showInteractionBarButtonOutline) var showInteractionBarButtonOutline
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Accessibility",
                description: "Customize Mlem to work best for you. Some features are tied to system-wide accessibility settings.",
                icon: .settings.accessibility
            )
            .gradientTint(.themedColorfulAccent(2))
            if differentiateWithoutColor {
                Section {
                    NavigationLink(
                        "Post Read Indicator",
                        value: .init(localized: readPostIndicator.label),
                        fallbackValue: "",
                        icon: .settings.readIndicatorSetting,
                        destination: .settings(.postReadIndicator)
                    )
                } header: {
                    Text("Differentiate Without Color")
                }
            }
            
            Section {
                Toggle("Website Thumbnail Indicator", icon: .general.browser, isOn: $websiteThumbnailIcon)
                Toggle("Settings Icons", icon: .settings.settingsIcons, isOn: $showSettingsIcons)
            } header: {
                Text("Non-Text Indicators")
            }
                       
            if #available(iOS 18, *) {
                Section {
                    NavigationLink(
                        "Animated Avatars",
                        value: .init(localized: animatedAvatars.label),
                        fallbackValue: "",
                        icon: .general.playCircle,
                        destination: .settings(.animatedAvatars)
                    )
                } header: {
                    Text("Reduce Motion")
                }
            }

            Section {
                Toggle("Button Outlines", icon: .general.circle, isOn: $showInteractionBarButtonOutline)
            } header: {
                Text("Contrast")
            }
            
            Section {
                NavigationLink(
                    "Slide to Zoom Images",
                    value: .init(localized: zoomSliderLocation.label),
                    fallbackValue: "",
                    icon: .settings.zoomSlider,
                    destination: .settings(.zoomSlider)
                )
            } header: {
                Text("Gestures")
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Accessibility")
    }
}
