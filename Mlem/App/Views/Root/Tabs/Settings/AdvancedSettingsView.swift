//
//  AdvancedSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import MlemBackend
import SwiftUI

struct AdvancedSettingsView: View {
    @Environment(BackendClient.self) var backendClient
    @Environment(ErrorsTracker.self) var errorsTracker

    @Setting(\.dev_errorTimeout) var errorToastTimeout

    @Setting(\.dev_developerMode) var developerMode
    
    @State var backendStatus: BackendHealthCheck?
    @State var lastBackendStatusCheck: Date?

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
                title: "Advanced",
                description: nil,
                icon: .settings.advanced
            )
            .gradientTint(.themedNeutralAccent)

            Section {
                NavigationLink(
                    "Cache",
                    value: ByteCountFormatter.string(fromByteCount: Int64(URLCache.shared.currentDiskUsage), countStyle: .file),
                    fallbackValue: "",
                    destination: .settings(.cache)
                )

                NavigationLink(
                    "Error Log",
                    value: .init(localized: errorLogLabel),
                    fallbackValue: String(errorsTracker.errors.count),
                    destination: .settings(.errorLog)
                )

                NavigationLink(
                    "Error Notification Timeout",
                    value: Duration.seconds(errorToastTimeout).formatted(secondsFormat),
                    fallbackValue: "",
                    destination: .settings(.errorToastTimeout)
                )
            }

            backendStatusSection

            Section {
                Toggle("Developer Mode", isOn: $developerMode)
            }
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Advanced")
    }

    @ViewBuilder
    var backendStatusSection: some View {
        Section {
            if let backendStatus {
                if backendStatus.unhealthyReasons.isEmpty {
                    backendStatusRow(isHealthy: true)
                } else {
                    backendStatusRow(isHealthy: false)
                        
                    ForEach(Array(backendStatus.unhealthyReasons.enumerated()), id: \.offset) { _, reason in
                        Text(reason)
                            .padding(.leading, Constants.main.standardSpacing)
                            .foregroundStyle(.themedNegative)
                    }
                }
            } else {
                backendStatusRow(isHealthy: nil)
            }
        } footer: {
            if let lastBackendStatusCheck {
                Text("Refreshed at \(lastBackendStatusCheck, format: .dateTime.hour().minute().second())")
            } else {
                Text("Refreshing...")
            }
        }
        .onAppear { checkBackendStatus() }
    }

    @ViewBuilder
    private func backendStatusRow(isHealthy: Bool?) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Backend Status")
                Text("Tap to refresh")
                    .font(.footnote)
                    .foregroundStyle(.themedSecondary)
            }
            Spacer()
            if let isHealthy {
                Image(icon: .general.circle)
                    .foregroundStyle(isHealthy ? .themedPositive : .themedNegative)
                    .symbolVariant(.fill)
            } else {
                ProgressView()
                    .tint(.themedSecondary)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            checkBackendStatus()
        }
    }
    
    private func checkBackendStatus() {
        Task {
            do {
                backendStatus = nil
                backendStatus = try await backendClient.healthCheck()
            } catch {
                handleError(error)
                backendStatus = nil
            }
            lastBackendStatusCheck = .now
        }
    }

    var errorLogLabel: LocalizedStringResource {
        if errorsTracker.errors.isEmpty {
            "No Errors"
        } else {
            "\(errorsTracker.errors.count) Errors"
        }
    }
}
