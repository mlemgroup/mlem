//
//  ImageViewerSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-20.
//

import SwiftUI

struct ImageViewerSettingsView: View {
    @Setting(\.a11y_zoomSliderLocation) var zoomSliderLocation
    @Setting(\.imageViewer_showControls) var showControls
    @Setting(\.imageViewer_showCloseButton) var showCloseButton
    @Setting(\.imageViewer_showZoomIndicator) var showZoomIndicator
    @Setting(\.imageViewer_dismissThreshold) var dismissThreshold

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
            description: "Customize the image viewer's buttons and gestures.",
            icon: .settings.imageViewer
        )
        .gradientTint(.themedColorfulAccent(5))
    }

    @ViewBuilder
    var controlsSectionView: some View {
        Section("Controls") {
            NavigationLink(
                "Show Controls",
                value: .init(localized: showControls.label),
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
                "Dismiss Sensitivity",
                value: .init(localized: dismissSensitivityLabel),
                fallbackValue: "",
                icon: .settings.imageViewerDismissSensitivity,
                destination: .settings(.imageViewerDismissSensitivity)
            )
            NavigationLink(
                "Slide to Zoom",
                value: .init(localized: zoomSliderLocation.label),
                fallbackValue: "",
                icon: .settings.zoomSlider,
                destination: .settings(.zoomSlider)
            )
        }
    }

    var dismissSensitivityLabel: LocalizedStringResource {
        switch dismissThreshold {
        case 1: "Highest"
        case 2...6: "High"
        case 10: "Default"
        case 15...19: "Low"
        case 20: "Lowest"
        default: "Medium"
        }
    }
}

enum ShowImageViewerControls: String, Codable, CaseIterable {
    case immediately, onTap, never

    var label: LocalizedStringResource {
        switch self {
        case .immediately: "Immediately"
        case .onTap: "When I Tap"
        case .never: "Never"
        }
    }
}
