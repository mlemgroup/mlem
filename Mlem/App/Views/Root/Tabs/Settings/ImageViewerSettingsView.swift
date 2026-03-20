//
//  ImageViewerSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-20.
//

import SwiftUI

struct ImageViewerSettingsView: View {
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Image Viewer",
                description: "Customise the image viewer.",
                icon: .general.image
            )
            .gradientTint(.themedColorfulAccent(4))
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Media & Links")
    }
}
