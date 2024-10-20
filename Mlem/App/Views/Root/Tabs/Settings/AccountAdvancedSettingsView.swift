//
//  AccountAdvancedSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountAdvancedSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @State var isBot: Bool = false
    
    init() {
        guard let person = AppState.main.firstPerson else { return }
        _isBot = .init(wrappedValue: person.isBot)
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Bot Account", isOn: $isBot)
                    .tint(palette.colorfulAccent(5))
                    .onChange(of: isBot) {
                        Task {
                            do {
                                try await appState.firstPerson?.updateSettings(isBot: isBot)
                            } catch {
                                handleError(error)
                                isBot = appState.firstPerson?.isBot ?? false
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
