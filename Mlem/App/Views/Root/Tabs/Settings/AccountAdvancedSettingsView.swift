//
//  AccountAdvancedSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountAdvancedSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @State var isBot: Bool = false
    
    init() {
        guard let person = AppState.main.firstPerson else { return }
        _isBot = .init(wrappedValue: person.isBot)
    }
    
    var body: some View {
        Form {
            if let updateSettings = appState.firstPerson?.updateSettings {
                Section {
                    Toggle("Bot Account", icon: .lemmy.botFlair, isOn: $isBot)
                        .tint(.themedColorfulAccent(5))
                        .onChange(of: isBot) {
                            Task {
                                do {
                                    try await updateSettings(.init(isBot: isBot))
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
            if let userAccount = appState.firstAccount as? UserAccount {
                Section {
                    Button("Refresh Token") {
                        navigation.openSheet(.logIn(.reauth(userAccount)))
                    }
                }
            }
        }
        .withConditionalLabelStyle()
        .navigationTitle("Advanced")
    }
}
