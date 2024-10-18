//
//  AccountAdvancedSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountAdvancedSettingsView: View {
    @Environment(Palette.self) var palette
    
    @State var isBot: Bool = false
    
    init() {
        guard let session = AppState.main.firstSession as? UserSession else {
            assertionFailure()
            return
        }
        guard let person = session.person else { return }
        _isBot = .init(wrappedValue: person.isBot)
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Bot Account", isOn: $isBot)
                    .tint(palette.colorfulAccent(5))
                    .onChange(of: isBot) {
                        Task {
                            guard let person = (AppState.main.firstSession as? UserSession)?.person else { return }
                            do {
                                try await person.updateSettings(isBot: isBot)
                            } catch {
                                handleError(error)
                                isBot = person.isBot
                            }
                        }
                    }
            } footer: {
                Text("Bot accounts are unable to vote.")
            }
        }
        .navigationTitle("Advanced")
    }
}
