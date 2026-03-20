//
//  ImageViewerSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-20.
//

import SwiftUI

struct ImageViewerSettingsView: View {
    @Setting(\.a11y_zoomSliderLocation) var zoomSliderLocation

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Image Viewer",
                description: "Customise the image viewer.",
                icon: .general.image
            )
            .gradientTint(.themedColorfulAccent(4))
            Section {
                NavigationLink(
                    "Slide to Zoom Images",
                    value: .init(localized: zoomSliderLocation.label),
                    fallbackValue: "",
                    icon: .settings.zoomSlider,
                    destination: .settings(.zoomSlider)
                )
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Media & Links")
    }
}
