//
//  ImageViewerShowControlsSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-20.
//

import SwiftUI

struct ImageViewerShowControlsSettingsView: View {
    @Setting(\.imageViewer_showControls) var showControls

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Show Controls",
                description: "Choose when the image viewer controls should appear.",
                icon: .settings.imageViewerControls
            )
            .gradientTint(.themedColorfulAccent(5))
            Picker("Show Controls", selection: $showControls) {
                ForEach(ShowImageViewerControls.allCases, id: \.self) { value in
                    Text(value.label)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Show Controls")
    }
}
