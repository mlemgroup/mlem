//
//  DeveloperSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import Dependencies
import FediverseEvents
import MlemBackend
import MlemMiddleware
import SwiftUI
import Theming

// Strings in this view are intentionally left unlocalized; we shouldn't
// be burdening translators with these when they'll never be used

struct DeveloperSettingsView: View {
    @Environment(BackendClient.self) var backendClient
    @Environment(EventsTracker.self) var eventsTracker
    
    @Environment(NavigationLayer.self) var navigation
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Setting(\.tip_feedWelcomePrompt) var showFeedWelcomePrompt
    
    @AppStorage("lastTestFlightUpdate") var lastTestFlightUpdate: URL?
    
    var body: some View {
        Form {
            Section {
                Toggle(String("Use QC Mlem Backend"),
                       isOn: .init(get: { backendClient.environment == .qualityControl },
                                   set: { backendClient.changeEnvironment(to: $0 ? .qualityControl : .production) }))
                
                Toggle(String("Use QC Events API"),
                       isOn: .init(get: { eventsTracker.environment == .qualityControl },
                                   set: { eventsTracker.changeEnvironment(to: $0 ? .qualityControl : .production) }))
            } footer: {
                Text(verbatim: "These settings will be cleared when the app restarts.")
            }
            
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
}
