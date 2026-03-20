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
            headerView
            controlsSectionView
            gesturesSectionView
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Image Viewer")
    }

    @ViewBuilder
    var headerView: some View {
        SettingsHeaderView(
            title: "Image Viewer",
            description: "Customise the image viewer's buttons and gestures.",
            icon: .settings.imageViewer
        )
        .gradientTint(.themedColorfulAccent(5))
    }

    @ViewBuilder
    var controlsSectionView: some View {
        Section("Controls") {
            NavigationLink(
                "Show Controls",
                value: showImageViewerOverlay ? "Immediately" : "When I Tap",
                fallbackValue: "",
                icon: .general.circle,
                destination: .settings(.imageViewerControls)
            )
            Toggle("Close Button", icon: .general.close, isOn: $showCloseButton)
            Toggle("Zoom Indicator", icon: .general.search, isOn: $showZoomIndicator)
        }
    }

    @ViewBuilder
    var gesturesSectionView: some View {
        Section("Gestures") {
            NavigationLink(
                "Slide to Zoom",
                value: .init(localized: zoomSliderLocation.label),
                fallbackValue: "",
                icon: .settings.zoomSlider,
                destination: .settings(.zoomSlider)
            )
        }
    }
}
