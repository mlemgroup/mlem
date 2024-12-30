//
//  DeveloperSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import SwiftUI
import MlemMiddleware

// Strings in this view are intentionally left unlocalized; we shouldn't
// be burdening translators with these when they'll never be used

struct DeveloperSettingsView: View {
    @Setting(\.showFeedWelcomePrompt) var showFeedWelcomePrompt
    @Setting(\.developerMode) var developerMode
    
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
            } header: {
                Text(verbatim: "Debug Tools")
            }
            #endif
        }
        .navigationTitle("Developer")
    }
}
