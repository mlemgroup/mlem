//
//  ImageViewerShowControlsSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-20.
//

import SwiftUI

struct ImageViewerShowControlsSettingsView: View {
    @Setting(\.imageViewer_showOverlayByDefault) var showImageViewerOverlay

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Show Controls",
                description: "Choose when the image viewer controls should appear.",
                icon: .settings.imageViewerControls
            )
            .gradientTint(.themedColorfulAccent(5))
            Picker("Show Controls", selection: $showImageViewerOverlay) {
                Text("Immediately")
                    .tag(true)
                Text("When I Tap")
                    .tag(false)
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Show Controls")
    }
}
