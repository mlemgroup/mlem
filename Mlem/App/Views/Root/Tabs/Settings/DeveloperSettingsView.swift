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
    
    @State var backendStatus: Bool?
    @State var lastBackendStatusCheck: Date?
    
    var body: some View {
        Form {
            Section {
                Toggle(String("Developer Mode"), isOn: $developerMode)
                NavigationLink(String("Error Log"), destination: .settings(.errorLog))
            }
            
            Section {
                HStack {
                    Text(verbatim: "Status")
                    Spacer()
                    if let backendStatus {
                        Image(systemName: Icons.present)
                            .foregroundStyle(backendStatus ? .themedPositive : .themedNegative)
                    } else {
                        ProgressView()
                    }
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
    
    private func checkBackendStatus() {
        Task {
            do {
                backendStatus = try await backendClient.healthCheck()
            } catch {
                handleError(error)
                backendStatus = false
            }
            lastBackendStatusCheck = .now
        }
    }
}
