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
    
    // var labelStyle: any LabelStyle { showSettingsIcons ? .titleAndIcon : .titleOnly }
    
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
            
            Section {
                Toggle("Website Thumbnail Indicator", systemImage: Icons.browser, isOn: $websiteThumbnailIcon)
                Toggle("Settings Icons", systemImage: Icons.icon, isOn: $showSettingsIcons)
            }
            .labelStyle(ConditionalIconLabelStyle())
        }
        .navigationTitle("Accessibility")
    }
}
