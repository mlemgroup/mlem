//
//  ImageViewerDismissSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-20.
//

import SwiftUI

struct ImageViewerDismissSettingsView: View {
    @Setting(\.imageViewer_dismissThreshold) var dismissThreshold

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Dismiss Sensitivity",
                description: "Choose how far you have to drag to dismiss the image viewer.",
                icon: .settings.imageViewerDismissSensitivity
            )
            .gradientTint(.themedColorfulAccent(5))

            Slider(
                value: .init(
                    get: { Double(dismissThreshold) },
                    set: { dismissThreshold = Int($0) }
                ),
                in: 2...20,
                step: 1
            )
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Dismiss Sensitivity")
    }
}
