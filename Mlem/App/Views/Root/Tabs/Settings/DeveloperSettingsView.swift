//
//  DeveloperSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import Dependencies
import MlemMiddleware
import SwiftUI

// Strings in this view are intentionally left unlocalized; we shouldn't
// be burdening translators with these when they'll never be used

struct DeveloperSettingsView: View {
    @Environment(NavigationLayer.self) var navigation
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Setting(\.tip_feedWelcomePrompt) var showFeedWelcomePrompt
    @Setting(\.dev_developerMode) var developerMode
    
    @AppStorage("lastBuildNumber") var lastBuildNumber: String?
    
    var body: some View {
        Form {
            Section {
                Toggle(String("Developer Mode"), isOn: $developerMode)
                NavigationLink(String("Error Log"), destination: .settings(.errorLog))
            }
            
            #if DEBUG
                Section {
                    Button(String("Trigger onboarding")) {
                        navigation.openSheet(.onboarding(.recommendInstance))
                    }
                    
                    Button(String("Reset Feed Welcome Banner")) {
                        showFeedWelcomePrompt = true
                    }
                
                    Button(String("Reset Feed TestFlight Banner")) {
                        lastBuildNumber = nil
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
}
