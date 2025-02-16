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
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Environment(AppState.self) var appState

    @Setting(\.showFeedWelcomePrompt) var showFeedWelcomePrompt
    @Setting(\.developerMode) var developerMode
    
    @AppStorage("status.firstAppearance") var firstAppearance: Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle(String("Developer Mode"), isOn: $developerMode)
                NavigationLink(String("Error Log"), destination: .settings(.errorLog))
            }
            
            #if DEBUG
                Section {
                    Button(String("Reset Feed Welcome Prompt")) {
                        showFeedWelcomePrompt = true
                    }
                
                    Button(String("Create Error")) {
                        handleError(ApiClientError.insufficientPermissions)
                    }
                    
                    Button(String("Create Silent Error")) {
                        handleError(ApiClientError.noEntityFound, silent: true)
                    }
                    
                    Button(String("Wipe Token")) {
                        Constants.main.keychain[getKeychainId(actorId: appState.firstSession.actorId)] = nil
                    }
                } header: {
                    Text(verbatim: "Debug Tools")
                }
            #endif
            Button(String("Reset Settings State")) {
                do {
                    try persistenceRepository.deleteAllSystemSettings()
                    firstAppearance = true
                } catch {
                    handleError(error)
                }
            }
        }
        .navigationTitle("Developer")
    }
}
