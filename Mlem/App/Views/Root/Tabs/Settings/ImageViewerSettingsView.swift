//
//  ImageViewerSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-20.
//

import SwiftUI

struct ImageViewerSettingsView: View {
    @Setting(\.a11y_zoomSliderLocation) var zoomSliderLocation
    @Setting(\.imageViewer_showOverlayByDefault) var showImageViewerOverlay
    @Setting(\.imageViewer_showCloseButton) var showCloseButton
    @Setting(\.imageViewer_showZoomIndicator) var showZoomIndicator

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Image Viewer",
                description: "Customise the image viewer's buttons and gestures.",
                icon: .settings.imageViewer
            )
            .gradientTint(.themedColorfulAccent(5))
            Section {
                Toggle("Show Overlay", isOn: $showImageViewerOverlay)

                Toggle("Close Button", icon: .general.close, isOn: $showCloseButton)
                Toggle("Zoom Indicator", icon: .general.search, isOn: $showZoomIndicator)
            }
            Section {
                NavigationLink(
                    "Slide to Zoom",
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
