//
//  DeveloperSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import Dependencies
import MlemMiddleware
import SwiftUI
import Theming

// Strings in this view are intentionally left unlocalized; we shouldn't
// be burdening translators with these when they'll never be used

struct DeveloperSettingsView: View {
    @Environment(BackendClient.self) var backendClient
    
    @Environment(NavigationLayer.self) var navigation
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Setting(\.tip_feedWelcomePrompt) var showFeedWelcomePrompt
    @Setting(\.dev_developerMode) var developerMode
    
    @AppStorage("lastTestFlightUpdate") var lastTestFlightUpdate: URL?
    
    @State var backendStatus: BackendHealthCheck?
    @State var lastBackendStatusCheck: Date?
    
    var body: some View {
        Form {
            Section {
                Toggle(String("Developer Mode"), isOn: $developerMode)
                NavigationLink(String("Error Log"), destination: .settings(.errorLog))
            }
            
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
                
                Button("Refresh") { checkBackendStatus() }
            } header: {
                Text(verbatim: "Backend")
            } footer: {
                if let lastBackendStatusCheck {
                    Text(verbatim: "Refreshed \(lastBackendStatusCheck.formatted(date: .abbreviated, time: .standard))")
                } else {
                    Text(verbatim: "Refreshing...")
                }
            }
            .onAppear { checkBackendStatus() }
            
            #if DEBUG
                Section {
                    Toggle("Use QC Backend",
                           isOn: .init(get: { BackendClient.main.environment == .qc },
                                       set: { BackendClient.main.changeEnvironment(to: $0 ? .qc : .prod) }))
                    
                    Button(String("Trigger Onboarding")) {
                        navigation.showFullScreenCover(.onboarding)
                    }
                    
                    Button(String("Reset Feed Welcome Banner")) {
                        showFeedWelcomePrompt = true
                    }
                    
                    Button(String("Reset Feed TestFlight Banner")) {
                        lastTestFlightUpdate = nil
                    }
                
                    Button(String("Create Error")) {
                        handleError(ApiClientError.insufficientPermissions)
                    }
                
                    Button(String("Create Silent Error")) {
                        handleError(ApiClientError.noEntityFound, silent: true)
                    }
                    
                    NavigationLink(String("New Inbox"), destination: .testInbox)
                } header: {
                    Text(verbatim: "Debug Tools")
                }
            #endif
            Button(String("Reset Settings State")) {
                do {
                    try persistenceRepository.deleteAllSystemSettings()
                } catch {
                    handleError(error)
                }
            }
        }
        .navigationTitle("Developer")
    }
    
    @ViewBuilder
    private func backendStatusRow(isHealthy: Bool?) -> some View {
        HStack {
            Text(verbatim: "Status")
            Spacer()
            if let isHealthy {
                Image(icon: .general.circle)
                    .foregroundStyle(isHealthy ? .themedPositive : .themedNegative)
                    .symbolVariant(.fill)
            } else {
                ProgressView()
            }
        }
    }
    
    private func checkBackendStatus() {
        Task {
            do {
                backendStatus = try await backendClient.healthCheck()
            } catch {
                handleError(error)
                backendStatus = nil
            }
            lastBackendStatusCheck = .now
        }
    }
}
