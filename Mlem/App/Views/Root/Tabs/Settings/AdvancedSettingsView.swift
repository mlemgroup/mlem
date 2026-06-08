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

    @Setting(\.dev_developerMode) var developerMode
    
    @State var backendStatus: BackendHealthCheck?
    @State var lastBackendStatusCheck: Date?

    var body: some View {
        Form {
            Section {
                NavigationLink("Cache", destination: .settings(.cache))
                NavigationLink("Error Log", destination: .settings(.errorLog))
                NavigationLink("Error Notification Timeout", destination: .settings(.errorToastTimeout))
            }

            backendStatusSection

            Section {
                Section {
                    Toggle("Developer Mode", isOn: $developerMode)
                }

                NavigationLink("Developer", destination: .settings(.developer))
            }
        }
        .navigationTitle("Advanced")
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
}
