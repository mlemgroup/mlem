//
//  ErrorToastTimeoutSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-08.
//

import SwiftUI

struct ErrorToastTimeoutSettingsView: View {
    @Setting(\.dev_errorTimeout) var errorToastTimeout

    var secondsFormat: Duration.UnitsFormatStyle {
        .units(
            allowed: [.seconds],
            width: .narrow,
            fractionalPart: .show(length: 1)
        )
    }

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Error Notification Timeout",
                description: "Customize how long error notifications remain on-screen.",
                icon: .general.time
            )
            .gradientTint(.themedColorfulAccent(0))
            Section {
                HStack {
                    Text("Timeout")
                    Spacer()

                    Group {
                        if errorToastTimeout == 100_000 {
                            Image(systemName: "infinity")
                        } else {
                            Text(Duration.seconds(errorToastTimeout), format: secondsFormat)
                        }
                    }
                    .foregroundStyle(.themedSecondary)
                }
                Slider(
                    value: .init(
                        get: { errorToastTimeout == 100_000 ? 10 : errorToastTimeout },
                        set: { errorToastTimeout = ($0 == 10 ? 100_000 : $0) }
                    ),
                    in: 0.5...10
                )
            } footer: {
                Text("Default: \(Duration.seconds(1.5), format: secondsFormat)")
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Error Notification Timeout")
    }
}
