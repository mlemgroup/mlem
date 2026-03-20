//
//  ImageViewerDismissSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-20.
//

import SwiftUI

struct ImageViewerDismissSettingsView: View {
    @Setting(\.imageViewer_dismissThreshold) var dismissThreshold

    @State var sliderValue: Double

    init() {
        let threshold = Settings.get(\.imageViewer_dismissThreshold)
        self._sliderValue = .init(initialValue: 21 - Double(threshold))
    }

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
                    Text("Low")
                    Spacer()
                    Text("High")
                }
                .font(.footnote)
                .foregroundStyle(.themedSecondary)

                // I tried using Binding(get: set:) here, but it caused haptics to be
                // spammed if you move the handle to either end of the slider.
                Slider(
                    value: $sliderValue,
                    in: 1...20
                ) { pressed in
                    if !pressed {
                        self.dismissThreshold = 21 - Int(sliderValue.rounded())
                    }
                }
            }
        } footer: {
            Button("Reset", icon: .general.refresh) {
                self.dismissThreshold = 10
                sliderValue = 21 - 10
            }
            .font(.footnote)
            .labelStyle(.titleAndIcon)
        }
    }
}
