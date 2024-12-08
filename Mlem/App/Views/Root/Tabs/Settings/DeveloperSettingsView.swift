//
//  DeveloperSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import SwiftUI

// Strings in this view are intentionally left unlocalized; we shouldn't
// be burdening translators with these when they'll never be used

struct DeveloperSettingsView: View {
    @Setting(\.showFeedWelcomePrompt) var showFeedWelcomePrompt
    @Setting(\.developerMode) var developerMode
    
    var body: some View {
        Form {
            Toggle(String("Developer Mode"), isOn: $developerMode)
            Button(String("Reset Feed Welcome Prompt")) {
                showFeedWelcomePrompt = true
            }
        }
        .navigationTitle("Developer")
    }
}
