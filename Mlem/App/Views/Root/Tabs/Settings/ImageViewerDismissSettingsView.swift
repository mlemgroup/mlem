//
//  ImageViewerDismissSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-20.
//

import SwiftUI

struct ImageViewerDismissSettingsView: View {
    @Setting(\.imageViewer_dismissThreshold) var dismissThreshold

    @State var sliderValue: Double = 0

    var body: some View {
        Form {
            headerView
            sliderView
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Dismiss Sensitivity")
    }

    @ViewBuilder
    var headerView: some View {
        SettingsHeaderView(
            title: "Dismiss Sensitivity",
            description: "Choose how far you have to drag to dismiss the image viewer.",
            icon: .settings.imageViewerDismissSensitivity
        )
        .gradientTint(.themedColorfulAccent(5))
    }

    @ViewBuilder
    var sliderView: some View {
        Section {
            VStack(spacing: 5) {
                HStack {
                    Text("Drag Less")
                    Spacer()
                    Text("Drag More")
                }
                .font(.footnote)
                .foregroundStyle(.themedSecondary)

                // I tried using Binding(get: set:) here, but it caused haptics to be
                // spammed if you move the handle to either end of the slider.
                Slider(
                    value: $sliderValue,
                    in: 2...20,
                    step: 1
                )
                .onChange(of: sliderValue) {
                    self.dismissThreshold = Int(sliderValue.rounded())
                }
            }
        }
    }
}
